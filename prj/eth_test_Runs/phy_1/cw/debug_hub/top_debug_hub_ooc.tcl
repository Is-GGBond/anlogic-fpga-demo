import_device ph1_90.db -package PH1A90SBG484
set_param flow ooc_flow on
read_verilog -file "D:/UserApp/TD_6.0.2/ip/apm/apm_cwc/apm_debughub.sv" -global_include "debug_hub_define.v" -top top_debug_hub
optimize_rtl
map_macro
map
pack
report_area -file top_debug_hub_gate.area
export_db -mode ooc "top_debug_hub_ooc.db"
