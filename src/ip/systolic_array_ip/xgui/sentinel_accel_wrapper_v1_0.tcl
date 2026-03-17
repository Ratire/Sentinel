# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "K" -parent ${Page_0}
  ipgui::add_param $IPINST -name "N" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PE_ACCUM_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PE_INP_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.K { PARAM_VALUE.K } {
	# Procedure called to update K when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.K { PARAM_VALUE.K } {
	# Procedure called to validate K
	return true
}

proc update_PARAM_VALUE.N { PARAM_VALUE.N } {
	# Procedure called to update N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N { PARAM_VALUE.N } {
	# Procedure called to validate N
	return true
}

proc update_PARAM_VALUE.PE_ACCUM_WIDTH { PARAM_VALUE.PE_ACCUM_WIDTH } {
	# Procedure called to update PE_ACCUM_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PE_ACCUM_WIDTH { PARAM_VALUE.PE_ACCUM_WIDTH } {
	# Procedure called to validate PE_ACCUM_WIDTH
	return true
}

proc update_PARAM_VALUE.PE_INP_WIDTH { PARAM_VALUE.PE_INP_WIDTH } {
	# Procedure called to update PE_INP_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PE_INP_WIDTH { PARAM_VALUE.PE_INP_WIDTH } {
	# Procedure called to validate PE_INP_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.K { MODELPARAM_VALUE.K PARAM_VALUE.K } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.K}] ${MODELPARAM_VALUE.K}
}

proc update_MODELPARAM_VALUE.N { MODELPARAM_VALUE.N PARAM_VALUE.N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N}] ${MODELPARAM_VALUE.N}
}

proc update_MODELPARAM_VALUE.PE_INP_WIDTH { MODELPARAM_VALUE.PE_INP_WIDTH PARAM_VALUE.PE_INP_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PE_INP_WIDTH}] ${MODELPARAM_VALUE.PE_INP_WIDTH}
}

proc update_MODELPARAM_VALUE.PE_ACCUM_WIDTH { MODELPARAM_VALUE.PE_ACCUM_WIDTH PARAM_VALUE.PE_ACCUM_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PE_ACCUM_WIDTH}] ${MODELPARAM_VALUE.PE_ACCUM_WIDTH}
}

