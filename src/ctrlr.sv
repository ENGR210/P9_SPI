`timescale 1ns/1ps

module ctrlr(
    input                   clk,
    input                   rst, 

    //GPIO interface
    input           [15:0]  switches,
    output logic    [15:0]  leds,

    //MMIO interface 
    input                   new_data,
    input           [7:0]   din,
    output logic    [7:0]   dout
);

localparam chip_id = 8'h07;

// How to intrepret the first byte:
// =====================================
// | W | - | - | - | - | A2 | A1 | A0 |
// =====================================

//What to do with the 2nd byte: 
// 
// IF W == 0 (READ)
//
// A2A1A0 == 'h0:  tx_dout = chip_id
// A2A1A0 == 'h1:  tx_dout = switches[7:0]
// A2A1A0 == 'h2:  tx_dout = switches[15:8]
// A2A1A0 == 'h3:  tx_dout = leds[7:0]
// A2A1A0 == 'h4:  tx_dout = leds[15:8]
//
// IF W == 1 (WRITE)
//
// A2A1A0 == 'h0:  ignore 
// A2A1A0 == 'h1:  ignore
// A2A1A0 == 'h2:  ignore
// A2A1A0 == 'h3:  set leds[7:0] = din
// A2A1A0 == 'h4:  set leds[15:8] = din

assign dout = 'h0; //update me!

endmodule
