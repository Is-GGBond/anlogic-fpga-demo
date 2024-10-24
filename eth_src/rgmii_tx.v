//--###############################################################################################
//--#
//--# File Name     : rgmii_tx.v
//--# Designer      : youName
//--# Tool          : Vscode
//--# Design Date   : dateTime
//--# Description   : GMII发送端口
//--# Version       : 0
//--# Coding scheme : GBK(If the Chinese comment of the file is garbled, please do not save it and check whether the file is opened in GBK encoding mode)
//--#
//--###############################################################################################
module rgmii_tx(
    //GMII发送端口
    input                   gmii_tx_clk     ,//GMII发送时钟;      
    input                   rst_n           ,//异步复位信号，低电平有效；
    input       [7:0]       gmii_txd        ,//GMII输出数据;
    input                   gmii_tx_en      ,//GMII输出数据有效信号，高电平有效；
    
    //RGMII发送端口
    output                  rgmii_txc       ,//RGMII发送数据时钟；
    output                  rgmii_tx_ctl    ,//RGMII输出数据有效信号；
    output      [3:0]       rgmii_txd        //RGMII输出数据；
);
    assign rgmii_txc = gmii_tx_clk;
    assign tx_reset  = ~rst_n;

    //输出双沿采样寄存器 (rgmii_tx_ctl)
    PH1_LOGIC_ODDR #(
        .ASYNCRST     ( "ENABLE"   )  //  "ENABLE", "DISABLE".  Asynchronous reset enable.  
    )u_PH1_LOGIC_ODDR(
        .q            ( rgmii_tx_ctl       ), //  1-Bit output. 1 bit DDR edge output data.    
        .clk          ( gmii_tx_clk        ), //  1-Bit input. Synchronous clock.             
        .d1           ( gmii_tx_en         ), //  1-Bit input. 1 bit negedge input data.      
        .d0           ( gmii_tx_en         ), //  1-Bit input. 1 bit posedge input data.      
        .rst          ( tx_reset           )  //  1-Bit input. Reset,high active.             
    );

    generate
        genvar i;
        for(i=0; i<4; i=i+1)begin : TXDATA_BUS
            //输出双沿采样寄存器 (rgmii_txd)
            PH1_LOGIC_ODDR #(
                .ASYNCRST     ( "ENABLE"   )  //  "ENABLE", "DISABLE".  Asynchronous reset enable.  
            )u_PH1_LOGIC_ODDR(
                .q            ( rgmii_txd[i]     ), //  1-Bit output. 1 bit DDR edge output data.    
                .clk          ( gmii_tx_clk      ), //  1-Bit input. Synchronous clock.             
                .d1           ( gmii_txd[4+i]    ), //  1-Bit input. 1 bit negedge input data.      
                .d0           ( gmii_txd[i]      ), //  1-Bit input. 1 bit posedge input data.      
                .rst          ( tx_reset          )  //  1-Bit input. Reset,high active.             
            );        
        end
    endgenerate

endmodule