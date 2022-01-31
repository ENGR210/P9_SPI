`timescale 1ns/1ps

module spi(
    input               clk, 
    input               rst, 
    
    //SPI signals
    input               sck, 
    input               ss,  //acts like reset
    input               mosi, 
    output              miso, 

    //hw interface
    input        [7:0]  dout, //output to SPI
    output logic [7:0]  din,  //input from SPI
    output logic        done
);
    
    logic rst_; //local reset

    //This creates a local reset
    assign rst_ = rst | ss;
    //This puts MISO into a HighImpedance state when in reset 
    assign miso = ( rst_ ? 'hz : dout['h0] ); //update only dout

    always_ff @(posedge clk) begin
        if (rst_) begin
            ; //update me
        end else begin
            ; //update me
        end
    end

    assign din = 'h0; //update me
    assign done = 'h0; //update me
    
endmodule
