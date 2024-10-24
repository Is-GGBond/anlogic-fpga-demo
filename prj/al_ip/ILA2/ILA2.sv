module ILA2
(
  input   [1:0]                 probe0,
  input   [0:0]                 probe1,
  input                         clk
);

  ChipWatcher_aa8a906c90d0  ChipWatcher_aa8a906c90d0_Inst
  (
      .probe0(probe0),
      .probe1(probe1),
      .clk(clk)
  );
endmodule
