module rgmii_rx #(
    parameter   IDELAY_VALUE = 0  //输入数据IO延时(如果为n,表示延时n*78+600ps);
)(
    input                       rst_n           ,//复位信号，低电平有效；
    
    //以太网RGMII接口
    input                       rgmii_rxc       ,//RGMII接收时钟
    input                       rgmii_rx_ctl    ,//RGMII接收数据控制信号
    input       [3:0]           rgmii_rxd       ,//RGMII接收数据    

    //以太网GMII接口
    output                      gmii_rx_clk     ,//GMII接收时钟
    output                      gmii_rx_dv      ,//GMII接收数据有效信号
    output      [7:0]           gmii_rxd         //GMII接收数据   
);

    wire        [4 : 0]         din             ;//将接收的数据和控制信号进行拼接；
    wire        [4 : 0]         din_delay       ;//将接收到的数据延时2ns。
    wire        [9 : 0]         gmii_data       ;//双沿转单沿的信号；
    
    //------------------------------------------------------------------------------------------
    // PLL  相位偏移270
    //------------------------------------------------------------------------------------------
    rx_pll u_rx_pll (
        .refclk(rgmii_rxc),
        .clk0_out(),
        .clk1_out (rgmii_rxc_int)   
	);
   
    assign gmii_rx_clk = rgmii_rxc_int;  // 内部信号给到输出端口

    //将输入控制信号和数据进行拼接，便于后面好用循环进行处理。
    assign din[4 : 0] = {rgmii_rx_ctl,rgmii_rxd};

    //rgmii_rx_ctl和rgmii_rxd输入延时与双沿采样
    generate
        genvar i;
        for(i=0 ; i<5 ; i=i+1)begin : RXDATA_BUS
            
            //  ----------------------------
            assign din_delay[i] = din[i];
            
            PH1_LOGIC_IDDR #(
                .ASYNCRST     ( "ENABLE"   ), //  "ENABLE", "DISABLE".  Asynchronous reset.  
                .PIPEMODE     ( "PIPED"    )  //  "PIPED", "NONE".  q0, q1 data alignment mode.  
            )u_PH1_LOGIC_IDDR(
                .q1           ( gmii_data[5 + i]   ), //  1-Bit output. 1 bit negedge data output.     
                .q0           ( gmii_data[i]       ), //  1-Bit output. 1 bit posedge data output.     
                .clk          ( rgmii_rxc_int      ), //  1-Bit input. Sampling clock.                
                .d            ( din_delay[i]       ), //  1-Bit input. DDR data entered on I/O.       
                .rst          ( 1'b0               )  //  1-Bit input. Reset signal,high active.      
            );
        end
    endgenerate

    //通过拼接生成数据信号和数据有效指示信号。
    assign gmii_rxd = {gmii_data[8:5],gmii_data[3:0]};
    assign gmii_rx_dv = gmii_data[4] & gmii_data[9];//只有当上升沿和下降沿采集到的控制信号均为高电平时，数据才有效。
    
endmodule