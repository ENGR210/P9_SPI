`timescale 1ns/1ps

module spi(
    input               clk, 
    input               rst, 
    
    //SPI interface 
    // Signals to/from the Raspberry Pi
    input               sck, //Serial Clock
    input               ss,  //Serial Reset Not
    input               mosi, //Serial input from Pi
    output              miso, //Serial output to Pi

    //
    //Hardware interface
    //Signals to/from the rest of the Basys3
    //

    // this is the parallel input from the Basys3
    // it's what gets sent out over the SPI on the next
    // transaction
    input        [7:0]  din, 

    //this is the parallel output to the Basys3
    // it's what was recieved from SPI over the last
    // transaction
    output logic [7:0]  dout,

    //this tells the Basys3 that a SPI transaction is ongoing. 
    // it should go high at the FIRST rising edge of a SPI transaction
    // and stay high until the LAST falling edge of the SPI transaction
    output logic        busy 
);
    
    logic rst_; //local reset
    logic last; //previous SCK
    assign rst_ = rst | ss;

    //fixme:  'h0 is wrong!
    assign miso = ( rst_ ? 'hz : 'h0 ); 

    always_ff @(posedge clk) begin
        if (rst_) begin
            last <= 'h0;
            ; //fixme!
        end else begin
            last <= sck;
            ; //fixme!
        end
    end

    always_comb begin
        ; //fixme
    end
    
endmodule
