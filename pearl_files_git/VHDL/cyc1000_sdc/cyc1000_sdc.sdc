create_clock -period 83.333 [get_ports {pil_clk_12MHz}]
derive_pll_clocks
derive_clock_uncertainty
set_false_path -from * -to [get_ports {pbv_P0*}]
set_false_path -from * -to [get_ports {pbv_P1*}]
set_false_path -from * -to [get_ports {pov_OR*}]