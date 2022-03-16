`timescale 1ns/1ps

module top (
    input               CLK100MHZ, 
    input               btnC, 
   
    //GPIO signals
    input   [15:0]      sw,
    output  [15:0]      LED,

    //SPI signals
    inout [7:0]         JC

    );

//map Basys3 signals to internal signals
logic clk;
logic rst;
logic sck;
logic mosi;
logic ss;

logic sck_;
logic ss_;
logic mosi_;
logic miso;

assign clk  = CLK100MHZ;
assign rst  = btnC;
assign sck  = JC[6]; //Sch JC9
assign mosi = JC[5]; //Sch JC8
assign JC[4]= miso;  //Sch JC7
assign ss   = JC[7]; //Sch JC10

assign JC[0] = miso;
assign JC[1] = mosi_;
assign JC[2] = sck_;
assign JC[3] = ss_;

debounce db_sclk(
    .clk,
    .rst, 
    .bouncy(sck),
    .stable(sck_)
    );

debounce db_ss(
    .clk,
    .rst,
    .bouncy(ss),
    .stable(ss_)
    );

debounce db_mosi(
    .clk,
    .rst,
    .bouncy(mosi),
    .stable(mosi_)
    );

//this just buffers the last
//recieved byte from SPI and 
//sends it back out next time
logic [7:0] din;
logic       done;
logic [7:0] dout;

spi spi0(
    .clk,
    .rst,

    .sck(sck_),
    .ss(ss_),
    .mosi(mosi_),
    .miso(miso),
    
    .dout,
    .din,
    .done
    );

ctrlr ctrlr0(
    .clk,
    .rst,
    .switches(sw),
    .leds(LED),
    
    .new_data(done),
    .din,
    .dout
);

endmodule
   
