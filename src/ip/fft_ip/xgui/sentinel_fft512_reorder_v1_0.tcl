# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_INP" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA { PARAM_VALUE.DATA } {
	# Procedure called to update DATA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA { PARAM_VALUE.DATA } {
	# Procedure called to validate DATA
	return true
}

proc update_PARAM_VALUE.DATA_INP { PARAM_VALUE.DATA_INP } {
	# Procedure called to update DATA_INP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_INP { PARAM_VALUE.DATA_INP } {
	# Procedure called to validate DATA_INP
	return true
}


proc update_MODELPARAM_VALUE.DATA_INP { MODELPARAM_VALUE.DATA_INP PARAM_VALUE.DATA_INP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_INP}] ${MODELPARAM_VALUE.DATA_INP}
}

proc update_MODELPARAM_VALUE.DATA { MODELPARAM_VALUE.DATA PARAM_VALUE.DATA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA}] ${MODELPARAM_VALUE.DATA}
}

