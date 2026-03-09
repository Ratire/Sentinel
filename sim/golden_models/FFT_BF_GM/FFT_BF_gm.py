from pathlib import Path

QDATA_I = 12
QDATA_F = 15

QDATAW_I = 1
QDATAW_F = 17

Q_DATA_WIDTH = QDATA_I + QDATA_F
Q_DATAW_WIDTH = QDATAW_I + QDATAW_F

def to_signed(val, width):
    mask = (1 << width) - 1
    val &= mask
    if val & (1 << (width - 1)):
        val -= 1 << width #Subtract by sign-extended bit to sign-extend
    return val

def saturate(val, width):
    maxv = (1 << (width - 1)) - 1
    minv = - (1 << (width - 1))
    return max(min(val, maxv), minv)

def grab_values(filepath, width):
    results = []
    with open(filepath, "r") as file:
        for line in file:
            line = line.strip()
            if not line:
                continue  #Skip empty lines

            #Cut off comments starting with //
            if "//" in line:
                line = line.split("//", 1)[0].strip()
                if not line:
                    continue  #Line was only a comment

            parts = line.split()
            if len(parts) < 2:
                continue  #Not enough data tokens on this line

            #Just take the first two tokens as hex values
            var1_hex, var2_hex = parts[0], parts[1]

            var1 = to_signed(int(var1_hex, 16), width)
            var2 = to_signed(int(var2_hex, 16), width)

            results.append((var1, var2))

    return results


def output_values(filepath, values):
    with open(filepath, "w") as file:
        mask = (1 << Q_DATA_WIDTH) - 1 #Mask for making potential negative ints only 27 bits in width

        for val in values:
            u0 = val[0] & mask
            u1 = val[1] & mask
            line = f"{u0:07x} {u1:07x}"

            file.write(line + "\n")

def butterfly(data_in_file, delay_out_file, tw_file, data_out_file, delay_in_file):
    di_vals = grab_values(data_in_file, Q_DATA_WIDTH) #Grabs all values
    delo_vals = grab_values(delay_out_file, Q_DATA_WIDTH)
    tw_vals = grab_values(tw_file, Q_DATAW_WIDTH)

    data_out_vals = []
    delay_in_vals = []

    for bf_on in (0, 1):
        for di, delo, tw in zip(di_vals, delo_vals, tw_vals): #Both cases are just imitating the operation of the RTL logic
            if(bf_on == 0):
                do_temp, delin_temp = di, di
                data_out_vals.append(do_temp); delay_in_vals.append(delin_temp)
            else:
                do_temp = (saturate((delo[0] + di[0]), Q_DATA_WIDTH), saturate((delo[1] + di[1]), Q_DATA_WIDTH))
                
                diff_r, diff_i = delo[0] - di[0], delo[1] - di[1]
                
                twiddle_prod1, twiddle_prod2 = diff_r * tw[0], diff_i * tw[1]
                delin_temp_r = twiddle_prod1 - twiddle_prod2
                
                twiddle_prod1, twiddle_prod2 = diff_r * tw[1], diff_i * tw[0]
                delin_temp_i = twiddle_prod1 + twiddle_prod2

                #By this point, delin_temp's real and imag parts are in Q15.32 format, so to
                #convert it back we just shift it back into place, discarding unnecessary bits.
                #Afterwards, we saturate the Q15.15 back to Q12.15 format.
                delin_temp_r, delin_temp_i = saturate(delin_temp_r >> QDATAW_F, Q_DATA_WIDTH), saturate(delin_temp_i >> QDATAW_F, Q_DATA_WIDTH)

                delin_temp = (delin_temp_r, delin_temp_i)

                data_out_vals.append(do_temp); delay_in_vals.append(delin_temp)
    
    output_values(data_out_file, data_out_vals)
    output_values(delay_in_file, delay_in_vals)

  
def main():
    script_dir = Path(__file__).resolve().parent  #Directory containing this .py file
    data_in_path = script_dir / "data_in.txt"
    delay_out_path = script_dir / "delay_out.txt"
    twiddles_path = script_dir / "twiddles.txt"

    data_out_path = script_dir / "data_out.txt"
    delay_in_path = script_dir / "delay_in.txt"

    butterfly(data_in_path, delay_out_path, twiddles_path, data_out_path, delay_in_path)


if __name__ == "__main__":
    main()