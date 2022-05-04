`timescale 1ns/1ps

module spi_tb();

`define SPI_DELAY #500

logic clk;
logic rst;
logic sck;
logic ss;
logic mosi;
logic miso;
logic [7:0] din;
logic [7:0] dout;
logic busy;

spi DUT (
    .clk,
    .rst,
    .sck,
    .ss,
    .mosi,
    .miso,
    .din,
    .dout,
    .busy
);

always #10 clk = ~clk;

task initialize ();
    clk = 'h0; rst = 'h1; 
    sck = 'h0; ss = 'h1; mosi = 'h0;
    din = 'h0;
endtask: initialize

task sendByte (
    input logic [7:0] tx_data,
    output logic [7:0] rx_data
    );
    $display("@PI:  Send:  %h", tx_data);

    assert (busy == 0) else $fatal(1, "busy high before SPI transmission start");

    fork
        // this thread runs the SPI transmission
        begin // this thread runs the SPI transmission
            for (int i = 7; i >= 0; --i) begin
                mosi = tx_data[i];
                `SPI_DELAY;
                @(posedge clk) #1;
                sck = 'h1;
                rx_data[i] = miso;
                `SPI_DELAY;
                @(posedge clk) #1;
                sck = 'h0;        
                //assert (done == 0) else $fatal(1, "bad done: expect:0 got: %h", done);  
            end
        end 
    

        //this thread monitors busy 
        begin
            @(posedge sck) #1; //wait for SCK to go high
            @(posedge clk) #1; //then give it another clock cycle
            assert(busy == 1) else $fatal(1, "busy should be high during SPI transmission");
            repeat (8) begin //wait for 8 more falling edge of SCK
                @(negedge sck) #1;
                assert(busy == 1) else $fatal(1, "busy should stay high during SPI transmission");
            end 
            @(posedge clk) #1;
            assert(busy == 0) else $fatal(1, "busy should go low after SPI transmission");
            @(posedge clk) #1;
            assert(busy == 0) else $fatal(1, "busy should stay low after SPI transmission");
        end
   
        join

    `SPI_DELAY;
    
    $display("@PI: Recv:  %h", rx_data);
endtask: sendByte

task setByte(
    input logic [7:0] tx_data
    );
    $display("@Basys:  setting byte: %h", tx_data);
    din = tx_data;
endtask: setByte

task checkByte (
    input logic [7:0] rx_data
    );
    $display("@Basys: checking byte: %h", rx_data);
    assert( dout == rx_data) else $fatal(1, "BAD byte: %h", dout);
endtask: checkByte

initial begin

    automatic logic [7:0] rx_data; 
    
    initialize();

    repeat(10) @(posedge clk);
    rst = 'h0;
    repeat(10) @(posedge clk);

    ss = 'h0;
    `SPI_DELAY 
   
    //just to get the ball rolling
    setByte(8'h0);
    sendByte(8'haa, rx_data);
    checkByte (8'haa);

    //now we should get 0xaa
    setByte(8'haa);
    sendByte(8'hff, rx_data);
    checkByte (8'hff);
    assert(rx_data == 'haa) else $fatal(1, "bad rx_data %h", rx_data);

    //and 0xff
    setByte(8'hff);
    sendByte(8'h00, rx_data);
    checkByte (8'h00);
    assert(rx_data == 'hff) else $fatal(1, "bad rx_data %h", rx_data);

    //and 0xbe
    setByte(8'hbe);
    sendByte(8'haa, rx_data);
    checkByte (8'haa);
    assert(rx_data == 'hbe) else $fatal(1, "bad rx_data %h", rx_data);
    
    `SPI_DELAY
    ss = 'h1;
    `SPI_DELAY

    $display("@@@Passed");
    $finish;
end


endmodule
