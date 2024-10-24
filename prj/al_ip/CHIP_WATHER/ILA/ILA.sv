module ILA
(
  input   [0:0]                 probe0,
  input   [7:0]                 probe1,
  input                         clk
);

  ChipWatcher_4524b2acec17  ChipWatcher_4524b2acec17_Inst
  (
      .probe0(probe0),
      .probe1(probe1),
      .clk(clk)
  );
endmodule
