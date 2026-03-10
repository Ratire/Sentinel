#define XPAR_AXIDMA_0_DEVICE_ID 0

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "xparameters.h"
#include "xaxidma.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "golden_vectors.h"  // Generated from my vitis export program

// DMA Object
XAxiDma AxiDma;

// These are the buffer addresses that we will be placing our memory in to be read out to the DDR and then read from the DDR
// right now we are just working with the cache associated with this baremetal application.
#define TX_BUFFER_BASE (0x10000000)  // 256 MB offset in the cache/DDR
#define RX_BUFFER_BASE (0x10010000)  // 64 KB after the TX

// Array of pointers to test vectors (same ones as the one in the golden vectors header)
const int32_t *input_vectors[NUM_TEST_VECTORS] = {
    input_q17_vec0,  // IMPULSE_AT_START
    input_q17_vec1,  // IMPULSE_IN_MIDDLE
    input_q17_vec2,  // POSITIVE_DC_0_5
    input_q17_vec3,  // NEGATIVE_DC_0_5
    input_q17_vec4,  // MAX_POS_DC
    input_q17_vec5   // MAX_NEG_DC
};

const uint64_t *golden_vectors[NUM_TEST_VECTORS] = {
    golden_packed_vec0,
    golden_packed_vec1,
    golden_packed_vec2,
    golden_packed_vec3,
    golden_packed_vec4,
    golden_packed_vec5
};

// grab the 54 bit values that are received by DDR memory (and thus our cache) from the axi_shim in our PL logic
void unpack_54bit(uint64_t word, int32_t *real, int32_t *imag) {
    uint32_t r_raw = (word >> 27) & 0x7FFFFFF;   // each real and imag variable is 27 bits
    uint32_t i_raw = word & 0x7FFFFFF;           
    
    // sign extend these values to their 32-bit versions
    *real = (r_raw & 0x4000000) ? (r_raw | 0xF8000000) : r_raw;
    *imag = (i_raw & 0x4000000) ? (i_raw | 0xF8000000) : i_raw;
}

int init_dma() {
    XAxiDma_Config *CfgPtr;
    int Status;

    CfgPtr = XAxiDma_LookupConfig(XPAR_AXIDMA_0_DEVICE_ID);
    if (!CfgPtr) {
        xil_printf("No DMA config found\r\n");
        return XST_FAILURE;
    }

    Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
    if (Status != XST_SUCCESS) {
        xil_printf("DMA init failed\r\n");
        return XST_FAILURE;
    }

    // Ensure Simple Mode is enabled and not the scatter gather one
    if (XAxiDma_HasSg(&AxiDma)) {
        xil_printf("Error: SG mode enabled\r\n");
        return XST_FAILURE;
    }

    // Disable interrupts since we will be using polling mode (to avoid the complexity and handling logic of interrupts)
    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

    return XST_SUCCESS;
}

int run_fft_single_vector(int vec_idx, uint64_t *TxBuffer, uint64_t *RxBuffer) {
    const int32_t *input_q17 = input_vectors[vec_idx];
    const uint64_t *golden_packed = golden_vectors[vec_idx];
    int Status;
    int max_error = 0;
    int error_idx = 0;

    xil_printf("\r\n--- Test Vector %d/%d ---\r\n", vec_idx + 1, NUM_TEST_VECTORS);

    // load the 18-bit input vectors into the 64 bit words of the cache
    for (int i = 0; i < N_SAMPLES; i++) {
        TxBuffer[i] = (uint64_t)(input_q17[i] & 0x3FFFF);  // Mask to 18 bits
    }

    // flush TX buffer (which basically means copying it to the DDR so that the DMA sees it)
    Xil_DCacheFlushRange((UINTPTR)TxBuffer, N_SAMPLES * sizeof(uint64_t));
    
    // invalidate RX buffer (which means get rid of the stale cache lines that may be in the place of where
    // we'd like to receive our observed output vectors)
    Xil_DCacheInvalidateRange((UINTPTR)RxBuffer, N_SAMPLES * sizeof(uint64_t));

    xil_printf("Starting DMA transfers...\r\n");
    
    xil_printf("DMA Idle check: TX=%d, RX=%d\r\n", 
                XAxiDma_Busy(&AxiDma, XAXIDMA_DMA_TO_DEVICE) ? 0 : 1,
                XAxiDma_Busy(&AxiDma, XAXIDMA_DEVICE_TO_DMA) ? 0 : 1);

    // start RX first (S2MM), then TX (MM2S) since if TX is too lightning fast before RX is even ready to read
    // it all, well that would just cause problems.
    Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)RxBuffer, 
                                    N_SAMPLES * sizeof(uint64_t), 
                                    XAXIDMA_DEVICE_TO_DMA);
    if (Status != XST_SUCCESS) {
        xil_printf("RX setup failed\r\n");
        return XST_FAILURE;
    }

    Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)TxBuffer, 
                                    N_SAMPLES * sizeof(uint64_t), 
                                    XAXIDMA_DMA_TO_DEVICE);
    if (Status != XST_SUCCESS) {
        xil_printf("TX setup failed\r\n");
        return XST_FAILURE;
    }

    // poll for completion
    int timeout = 10000000;
    while (XAxiDma_Busy(&AxiDma, XAXIDMA_DMA_TO_DEVICE) && timeout--) {}
    if (timeout <= 0) {
        xil_printf("ERROR: TX timeout\r\n");
        return XST_FAILURE;
    }

    timeout = 10000000;
    while (XAxiDma_Busy(&AxiDma, XAXIDMA_DEVICE_TO_DMA) && timeout--) {}
    if (timeout <= 0) {
        xil_printf("ERROR: RX timeout\r\n");
        return XST_FAILURE;
    }

    xil_printf("DMA complete. Validating...\r\n");

    // invalidate cache to see DMA-written data (once again get rid of the stale RX values and
    // for us to check the new values from DDR within our cache)
    Xil_DCacheInvalidateRange((UINTPTR)RxBuffer, N_SAMPLES * sizeof(uint64_t));

    // compare against golden
    for (int i = 0; i < N_SAMPLES; i++) {
        int32_t hw_real, hw_imag, gold_real, gold_imag;
        
        unpack_54bit(RxBuffer[i], &hw_real, &hw_imag);
        unpack_54bit(golden_packed[i], &gold_real, &gold_imag);
        
        int err_real = abs(hw_real - gold_real);
        int err_imag = abs(hw_imag - gold_imag);
        int total_err = err_real + err_imag;
        
        if (total_err > max_error) {
            max_error = total_err;
            error_idx = i;
        }
    }

    xil_printf("Max absolute error: %d at bin %d\r\n", max_error, error_idx);
    
    if (max_error <= 3) {
        xil_printf("Vector %d: PASSED (Bit-accurate within tolerance)\r\n", vec_idx);
        return XST_SUCCESS;
    } else {
        xil_printf("Vector %d: FAILED (Check ILA for AXI-Stream timing)\r\n", vec_idx);
        xil_printf("Expected: 0x%016llx, Got: 0x%016llx\r\n", 
                   (unsigned long long)golden_packed[error_idx], 
                   (unsigned long long)RxBuffer[error_idx]);
        return XST_FAILURE;
    }
}

// pick any number between 0-5 to test all input vector case (all input vectors match the same ones from RTL logic testbenches)
#define TEST_VECTOR 5

int main() {
    uint64_t *TxBuffer = (uint64_t *)TX_BUFFER_BASE;
    uint64_t *RxBuffer = (uint64_t *)RX_BUFFER_BASE;

    xil_printf("\r\n=== FFT512 Test - Vector %d ===\r\n", TEST_VECTOR);

    if (init_dma() != XST_SUCCESS) {
        xil_printf("DMA init failed\r\n");
        return -1;
    }

    // run just the one vector we want
    int result = run_fft_single_vector(TEST_VECTOR, TxBuffer, RxBuffer);
    
    if (result == XST_SUCCESS) {
        xil_printf("\r\n>>> PASSED <<<\r\n");
        return 0;
    } else {
        xil_printf("\r\n>>> FAILED <<<\r\n");
        return -1;
    }
}