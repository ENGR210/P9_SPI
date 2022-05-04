`timescale 1ns/1ps

module ctrlr(
    input                   clk,
    input                   rst, 

    //GPIO interface
    input           [15:0]  switches,
    output logic    [15:0]  leds,

    //
    //SPI Command Interface
    //

    //Used to indicate that the data from SPI is currently
    // valid and wont change randomly
    // i.e. there is no ongoing SPI transaction
    input                   dvalid,
    
    //input from SPI
    // coming from the Raspberry Pi
    input           [7:0]   din,

    //output to SPI
    // to be sent to Raspberry Pi
    output logic    [7:0]   dout
);

localparam chip_id = 8'h07;

// How to intrepret the first byte:
// =====================================
// | W | - | - | - | - | A2 | A1 | A0 |
// =====================================

//What to do with the 2nd byte: 
// 
// IF W == 1 (READ)
//
// A2A1A0 == 'h0:  dout = chip_id
// A2A1A0 == 'h1:  dout = switches[7:0]
// A2A1A0 == 'h2:  dout = switches[15:8]
// A2A1A0 == 'h3:  dout = leds[7:0]
// A2A1A0 == 'h4:  dout = leds[15:8]
//
// IF W == 0 (WRITE)
//
// A2A1A0 == 'h0:  ignore 
// A2A1A0 == 'h1:  ignore
// A2A1A0 == 'h2:  ignore
// A2A1A0 == 'h3:  set leds[7:0] = din
// A2A1A0 == 'h4:  set leds[15:8] = din

//fixme!
assign dout = chip_id; 

endmodule
