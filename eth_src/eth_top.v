//--###############################################################################################
//--#
//--# File Name     : eth_top.v
//--# Designer      : ssh
//--# Tool          : Vscode
//--# Design Date   : 2024-10-23
//--# Description   : 实现arp、icmp、udp协议的发送和接收，
//--#                 平台: anlogi PH1A90 FPGA
//--# Version       : 0
//--# Coding scheme : UTF-8(If the Chinese comment of the file is garbled, please do not save it and check whether the file is opened in GBK encoding mode)
//--#
//--###############################################################################################

module eth_top #(
    parameter       BOARD_MAC       =   48'h00_11_22_33_44_55       ,//开发板MAC地址 00-11-22-33-44-55；
    parameter       BOARD_IP        =   {8'd192,8'd168,8'd1,8'd10}  ,//开发板IP地址 192.168.1.10；
    parameter       DES_MAC         =   48'hff_ff_ff_ff_ff_ff       ,//目的MAC地址 ff_ff_ff_ff_ff_ff；
    parameter       DES_IP          =   {8'd192,8'd168,8'd1,8'd102} ,//目的IP地址 192.168.1.102；
    parameter       BOARD_PORT      =   16'd1234                    ,//开发板的UDP端口号；
    parameter       DES_PORT        =   16'd5678                    ,//目的端口号；
    parameter       IP_TYPE         =   16'h0800                    ,//16'h0800表示IP协议；
    parameter       ARP_TYPE        =   16'h0806                     //16'h0806表示ARP协议；
)(  
    input               rst_n           ,//复位信号，低电平有效。
    //以太网RGMII接口   
    input               rgmii_rxc       ,//RGMII接收时钟
    input               rgmii_rx_ctl    ,//RGMII接收数据控制信号
    input       [3:0]   rgmii_rxd       ,//RGMII接收数据
    output              rgmii_txc       ,//RGMII发送时钟    
    output              rgmii_tx_ctl    ,//RGMII发送数据控制信号
    output      [3:0]   rgmii_txd        //RGMII发送数据  
);
    
    wire                gmii_rx_clk     ;//GMII接收时钟
    wire                gmii_rx_dv      ;//GMII接收数据有效信号
    wire        [7:0]   gmii_rxd        ;//GMII接收数据
    wire                gmii_tx_clk     ;//GMII发送时钟
    wire                gmii_tx_en      ;//GMII发送数据使能信号
    wire        [7:0]   gmii_txd        ;//GMII发送数据  

    rgmii_to_gmii u_rgmii_to_gmii(   
        .rst_n            (rst_n        ),  //input               rst_n           ,//异步复位信号，低电平有效；
        //以太网GMII接口     
        .gmii_rx_clk      (gmii_rx_clk  ),  //output              gmii_rx_clk     ,//GMII接收时钟
        .gmii_rx_dv       (gmii_rx_dv   ),  //output              gmii_rx_dv      ,//GMII接收数据有效信号
        .gmii_rxd         (gmii_rxd     ),  //output      [7:0]   gmii_rxd        ,//GMII接收数据
        .gmii_tx_clk      (gmii_tx_clk  ),  //output              gmii_tx_clk     ,//GMII发送时钟
        .gmii_tx_en       (gmii_tx_en   ),  //input               gmii_tx_en      ,//GMII发送数据使能信号
        .gmii_txd         (gmii_txd     ),  //input       [7:0]   gmii_txd        ,//GMII发送数据            
        //以太网RGMII接口   
        .rgmii_rxc        (rgmii_rxc   ), //input               rgmii_rxc       ,//RGMII接收时钟
        .rgmii_rx_ctl     (rgmii_rx_ctl ), //input               rgmii_rx_ctl    ,//RGMII接收数据控制信号
        .rgmii_rxd        (rgmii_rxd    ), //input       [3:0]   rgmii_rxd       ,//RGMII接收数据
        .rgmii_txc        (rgmii_txc    ), //output              rgmii_txc       ,//RGMII发送时钟    
        .rgmii_tx_ctl     (rgmii_tx_ctl ), //output              rgmii_tx_ctl    ,//RGMII发送数据控制信号
        .rgmii_txd        (rgmii_txd    )  //output      [3:0]   rgmii_txd        //RGMII发送数据          
    );
    

    wire                  udp_tx_en         ;//UDP发送使能信号。
    wire      [7 : 0]     udp_tx_data       ;//udp需要发送的数据信号，滞后tx_req信号一个时钟；
    wire      [15 : 0]    udp_tx_data_num   ;//udp一帧数据需要发送的个数；
    wire                  udp_tx_req        ;//请求输入udp发送数据；
    wire                  udp_rx_done       ;//udp数据报接收完成信号；
    wire      [7 : 0]     udp_rx_data       ;//udp数据接收的数据；
    wire      [15 : 0]    udp_rx_data_num   ;//udp接收一帧数据的长度；
    wire                  udp_rx_data_vld   ;//udp接收数据有效指示信号；
    wire                  tx_rdy            ;//以太网发送模块忙闲指示信号；
    eth #(
        .BOARD_MAC        (BOARD_MAC        ), //parameter       BOARD_MAC       =   48'h00_11_22_33_44_55       ,//开发板MAC地址 00-11-22-33-44-55；
        .BOARD_IP         (BOARD_IP         ), //parameter       BOARD_IP        =   {8'd192,8'd168,8'd1,8'd10}  ,//开发板IP地址 192.168.1.10；
        .DES_MAC          (DES_MAC          ), //parameter       DES_MAC         =   48'hff_ff_ff_ff_ff_ff       ,//目的MAC地址 ff_ff_ff_ff_ff_ff；
        .DES_IP           (DES_IP           ), //parameter       DES_IP          =   {8'd192,8'd168,8'd1,8'd102} ,//目的IP地址 192.168.1.102；
        .BOARD_PORT       (BOARD_PORT       ), //parameter       BOARD_PORT      =   16'd1234                    ,//开发板的UDP端口号；
        .DES_PORT         (DES_PORT         ), //parameter       DES_PORT        =   16'd5678                    ,//目的端口号；
        .IP_TYPE          (IP_TYPE          ), //parameter       IP_TYPE         =   16'h0800                    ,//16'h0800表示IP协议；
        .ARP_TYPE         (ARP_TYPE         )  //parameter       ARP_TYPE        =   16'h0806                     //16'h0806表示ARP协议；
    )u_eth(       
        .rst_n            (rst_n            ), //input                               rst_n                       ,//复位信号，低电平有效。
        //GMII接口      
        .gmii_rx_clk      (gmii_rx_clk      ), //input                               gmii_rx_clk                 ,//GMII接收数据时钟。
        .gmii_rx_dv       (gmii_rx_dv       ), //input                               gmii_rx_dv                  ,//GMII输入数据有效信号。
        .gmii_rxd         (gmii_rxd         ), //input           [7 : 0]             gmii_rxd                    ,//GMII输入数据。
        .gmii_tx_clk      (gmii_tx_clk      ), //input                               gmii_tx_clk                 ,//GMII发送数据时钟。
        .gmii_tx_en       (gmii_tx_en       ), //output                              gmii_tx_en                  ,//GMII输出数据有效信号。
        .gmii_txd         (gmii_txd         ), //output          [7 : 0]             gmii_txd                    ,//GMII输出数据。
        .arp_req          (1'b0             ), //input                               arp_req                     ,//arp请求数据报发送信号。
        //UDP相关的用户接口；
        .udp_tx_en        (udp_tx_en        ), //input                               udp_tx_en                   ,//UDP发送使能信号。
        .udp_tx_data      (udp_tx_data      ), //input           [7 : 0]             udp_tx_data                 ,//udp需要发送的数据信号，滞后tx_req信号一个时钟；
        .udp_tx_data_num  (udp_tx_data_num  ), //input           [15 : 0]            udp_tx_data_num             ,//udp一帧数据需要发送的个数；
        .udp_tx_req       (udp_tx_req       ), //output                              udp_tx_req                  ,//请求输入udp发送数据；
        .udp_rx_done      (udp_rx_done      ), //output                              udp_rx_done                 ,//udp数据报接收完成信号；
        .udp_rx_data      (udp_rx_data      ), //output          [7 : 0]             udp_rx_data                 ,//udp数据接收的数据；
        .udp_rx_data_num  (udp_rx_data_num  ), //output          [15 : 0]            udp_rx_data_num             ,//udp接收一帧数据的长度；
        .udp_rx_data_vld  (udp_rx_data_vld  ), //output                              udp_rx_data_vld             ,//udp接收数据有效指示信号；
        .tx_rdy           (tx_rdy           )  //output                              tx_rdy                       //以太网发送模块忙闲指示信号；
    );
endmodule //eth_top