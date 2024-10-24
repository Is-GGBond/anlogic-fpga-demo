//--###############################################################################################
//--#
//--# File Name     : crc32_d8.v
//--# Designer      : youName
//--# Tool          : Vscode
//--# Design Date   : 2014-10-24 15:00:00
//--# Description   : Description
//--# Version       : 0
//--# Coding scheme : GBK(If the Chinese comment of the file is garbled, please do not save it and check whether the file is opened in GBK encoding mode)
//--#
//--###############################################################################################
module crc32_d8(
    input                   clk         ,//时钟信号
    input                   rst_n       ,//复位信号，低电平有效
    input         [7:0]     data        ,//输入待校验8位数据
    input                   crc_en      ,//crc使能，开始校验标志
    input                   crc_clr     ,//crc数据复位信号            
    output      [31:0]      crc_out      //CRC校验数据
);
    reg  [31 : 0]           crc_data    ;
    //CRC32的生成多项式为：G(x)= x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x^1 + 1
    always@(posedge clk)begin
        if(!rst_n)
            crc_data <= 32'hff_ff_ff_ff;
        else if(crc_clr)//CRC校验值复位
            crc_data <= 32'hff_ff_ff_ff;
        else if(crc_en)begin
            crc_data[0] <= crc_data[24] ^ crc_data[30] ^ data[7] ^ data[1];
            crc_data[1] <= crc_data[24] ^ crc_data[25] ^ crc_data[30] ^ crc_data[31] ^ data[7] ^ data[6] ^ data[1] ^ data[0];
            crc_data[2] <= crc_data[24] ^ crc_data[25] ^ crc_data[26] ^ crc_data[30] ^ crc_data[31] ^ data[7] ^ data[6] ^ data[5] ^ data[1] ^ data[0];
            crc_data[3] <= crc_data[25] ^ crc_data[26] ^ crc_data[27] ^ crc_data[31] ^ data[6] ^ data[5] ^ data[4] ^ data[0];
            crc_data[4] <= crc_data[24] ^ crc_data[26] ^ crc_data[27] ^ crc_data[28] ^ crc_data[30] ^ data[7] ^ data[5] ^ data[4] ^ data[3] ^ data[1];
            crc_data[5] <= crc_data[24] ^ crc_data[25] ^ crc_data[27] ^ crc_data[28] ^ crc_data[29] ^ crc_data[30] ^ crc_data[31] ^ data[7] ^ data[6] ^ data[4] ^ data[3] ^ data[2] ^ data[1] ^ data[0];
            crc_data[6] <= crc_data[25] ^ crc_data[26] ^ crc_data[28] ^ crc_data[29] ^ crc_data[30] ^ crc_data[31] ^ data[6] ^ data[5] ^ data[3] ^ data[2] ^ data[1] ^ data[0];
            crc_data[7] <= crc_data[24] ^ crc_data[26] ^ crc_data[27] ^ crc_data[29] ^ crc_data[31] ^ data[7] ^ data[5] ^ data[4] ^ data[2] ^ data[0];
            crc_data[8] <= crc_data[0] ^ crc_data[24] ^ crc_data[25] ^ crc_data[27] ^ crc_data[28] ^ data[7] ^ data[6] ^ data[4] ^ data[3];
            crc_data[9] <= crc_data[1] ^ crc_data[25] ^ crc_data[26] ^ crc_data[28] ^ crc_data[29] ^ data[6] ^ data[5] ^ data[3] ^ data[2];
            crc_data[10] <= crc_data[2] ^ crc_data[24] ^ crc_data[26] ^ crc_data[27] ^ crc_data[29] ^ data[7] ^ data[5] ^ data[4] ^ data[2];
            crc_data[11] <= crc_data[3] ^ crc_data[24] ^ crc_data[25] ^ crc_data[27] ^ crc_data[28] ^ data[7] ^ data[6] ^ data[4] ^ data[3];
            crc_data[12] <= crc_data[4] ^ crc_data[24] ^ crc_data[25] ^ crc_data[26] ^ crc_data[28] ^ crc_data[29] ^ crc_data[30] ^ data[7] ^ data[6] ^ data[5] ^ data[3] ^ data[2] ^ data[1];
            crc_data[13] <= crc_data[5] ^ crc_data[25] ^ crc_data[26] ^ crc_data[27] ^ crc_data[29] ^ crc_data[30] ^ crc_data[31] ^ data[6] ^ data[5] ^ data[4] ^ data[2] ^ data[1] ^ data[0];
            crc_data[14] <= crc_data[6] ^ crc_data[26] ^ crc_data[27] ^ crc_data[28] ^ crc_data[30] ^ crc_data[31] ^ data[5] ^ data[3] ^ data[4] ^ data[1] ^ data[0];
            crc_data[15] <=  crc_data[7] ^ crc_data[27] ^ crc_data[28] ^ crc_data[29] ^ crc_data[31] ^ data[3] ^ data[4] ^ data[2] ^ data[0];
            crc_data[16] <= crc_data[8] ^ crc_data[24] ^ crc_data[28] ^ crc_data[29] ^ data[7] ^ data[3] ^ data[2];
            crc_data[17] <= crc_data[9] ^ crc_data[25] ^ crc_data[29] ^ crc_data[30] ^ data[6] ^ data[2] ^ data[1];
            crc_data[18] <= crc_data[10] ^ crc_data[26] ^ crc_data[30] ^ crc_data[31] ^ data[5] ^ data[1] ^ data[0];
            crc_data[19] <= crc_data[11] ^ crc_data[27] ^ crc_data[31] ^ data[4] ^ data[0];
            crc_data[20] <= crc_data[12] ^ crc_data[28] ^ data[3];
            crc_data[21] <= crc_data[13] ^ crc_data[29] ^ data[2];
            crc_data[22] <= crc_data[14] ^ crc_data[24] ^ data[7];
            crc_data[23] <= crc_data[15] ^ crc_data[24] ^ crc_data[25] ^ crc_data[30] ^ data[7] ^ data[6] ^ data[1];
            crc_data[24] <= crc_data[16] ^ crc_data[25] ^ crc_data[26] ^ crc_data[31] ^ data[6] ^ data[5] ^ data[0];
            crc_data[25] <= crc_data[17] ^ crc_data[26] ^ crc_data[27] ^ data[5] ^ data[4];
            crc_data[26] <= crc_data[18] ^ crc_data[24] ^ crc_data[27] ^ crc_data[28] ^ crc_data[30] ^ data[7] ^ data[3] ^ data[4] ^ data[1];
            crc_data[27] <= crc_data[19] ^ crc_data[25] ^ crc_data[28] ^ crc_data[29] ^ crc_data[31] ^ data[6] ^ data[3] ^ data[2] ^ data[0];
            crc_data[28] <= crc_data[20] ^ crc_data[26] ^ crc_data[29] ^ crc_data[30] ^ data[5] ^ data[2] ^ data[1];
            crc_data[29] <= crc_data[21] ^ crc_data[27] ^ crc_data[30] ^ crc_data[31] ^ data[4] ^ data[1] ^ data[0];
            crc_data[30] <= crc_data[22] ^ crc_data[28] ^ crc_data[31] ^ data[3] ^ data[0];
            crc_data[31] <= crc_data[23] ^ crc_data[29] ^ data[2];
        end
    end

    //将计算的数据各位取反倒序赋值后输出。
    assign crc_out[31:0] = ~{crc_data[0],crc_data[1],crc_data[2],crc_data[3],crc_data[4],crc_data[5],crc_data[6],crc_data[7],
                            crc_data[8],crc_data[9],crc_data[10],crc_data[11],crc_data[12],crc_data[13],crc_data[14],crc_data[15],
                            crc_data[16],crc_data[17],crc_data[18],crc_data[19],crc_data[20],crc_data[21],crc_data[22],crc_data[23],
                            crc_data[24],crc_data[25],crc_data[26],crc_data[27],crc_data[28],crc_data[29],crc_data[30],crc_data[31]};
endmodule