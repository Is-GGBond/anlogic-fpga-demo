create_clock -name rgmii_rx_clk  -period 8 -waveform {0 4} [get_ports {rgmii_rxc}]

derive_pll_clocks
