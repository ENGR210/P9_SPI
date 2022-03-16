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
    output logic        done //logical 1 for 1 cycle indicating new data 
);
    
    logic rst_; //local reset


    //combine the chip and SPI resets 
    assign rst_ = rst | ss;

    //replace this with actual logic
    logic fixme; 
    assign fixme = 'h0;

    //tri-state miso when not in use.  
    // keep this line
    assign miso = ( rst_ ? 'hz : fixme );

    always_ff @(posedge clk) begin
        if (rst_) begin
            ; //finish me
       end else begin
            ; //finish me
       end
    end
    
    always_comb begin
        ; //finish me
    end

endmodule
