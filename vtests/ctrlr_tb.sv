`timescale 1ns/1ps

module ctrlr_tb();

logic   clk;
logic   rst; 

    //GPIO interface
logic [15:0]    switches;
logic [15:0]    leds;

    //MMIO interface 
logic           dvalid;
logic [7:0]     din;
logic [7:0]     dout;

ctrlr DUT (
    .clk,
    .rst,
    .switches,
    .leds,
    .dvalid,
    .din,
    .dout
    );

always #10 clk = ~clk;

task initialize ();
    clk = 'h0; rst = 'h1;
    switches = 'h0; 
    dvalid ='h1;
    din = 'h0;
    #1 ;   
endtask

task txRxByte(
    input logic [7:0] tx_byte,
    output logic [7:0] rx_byte
    );

    //dout is what will get transmitted via SPI. 
    // this occurs BEFORE the actual SPI transmission
    //hence we sample it here.
    rx_byte = dout;    
    @(posedge clk) #1;
    dvalid = 'h0; // SPI starts
    repeat(11) @(posedge clk) #1;

    //now send in a new byte
    din = tx_byte;
    dvalid = 'h1;     

    @(posedge clk) #1;
    
    //and wait a few cycles for good measure
    repeat(2) @(posedge clk) #2;
    
endtask: txRxByte 

task test_dvalid();
    @(posedge clk) #2;
    dvalid = 'h0;     
    
    $display("Checking dvalid by incorrectly writing to LEDs ");
    assert( leds == 'h0) else $fatal(1, "bad initial condition for leds: expect:%h got:%h", 16'h0, leds);
    @(posedge clk) #2 din = 'h03;
    repeat (2) 
        @(posedge clk) #2 ;
    @(posedge clk) #2 din = 'hff;
    repeat (2) 
        @(posedge clk) #2 ;
    assert( leds == 'h0000) else $fatal(1, "dvalid not set, write should not be valid: LEDs expect:%h got:%h.",
                        16'h0000, leds); 
    din = 'h0;                           
    repeat(2) 
        @(posedge clk) #2 ;
endtask: test_dvalid

task test_chip_id ();
    automatic logic [7:0] rx_byte;
    localparam chip_id = 8'h07;

    repeat(2) begin
        $display("Checking chip_id");
        txRxByte('b10000000,rx_byte); //READ - 0x0
        txRxByte('b00000000,rx_byte); //dummy byte
        assert(rx_byte ==  chip_id ) else $fatal(1, "bad chip_id:  expect:%h got:%h", chip_id, rx_byte);
    end

endtask: test_chip_id;

task test_switches();
    automatic logic [7:0] rx_byte;

    $display("Checking switches");
    switches = 'h00ff; 
    repeat(2) txRxByte('h81,rx_byte);
    assert( rx_byte == 8'hff) else $fatal(1, "bad switches[7:0]:  expect: %h, got:%h", 8'hff, rx_byte);

    repeat(2) txRxByte('h82,rx_byte);
    assert( rx_byte == 8'h00) else $fatal(1, "bad switches[15:8]:  expect: %h, got:%h", 8'hff, rx_byte);

endtask: test_switches

task test_leds();
    automatic logic [7:0] rx_byte;

    $display("Checking LEDs");
    assert( leds == 'h0) else $fatal(1, "bad initial condition for leds: expect:%h got:%h", 16'h0, leds);
    txRxByte('h03,rx_byte);
    txRxByte('hff,rx_byte);
    assert( leds == 'h00ff) else $fatal(1, "bad write leds[7:0]: expect:%h got:%h", 16'h00ff, leds);
    txRxByte('h04,rx_byte);
    txRxByte('haa,rx_byte);
    assert( leds == 'haaff) else $fatal(1, "bad write leds[15:8]: expect:%h got:%h", 16'haaff, leds);

    repeat(2) txRxByte('h83, rx_byte); 
    assert (rx_byte == 'hff) else $fatal(1, "bad read leds[7:0]:  expect:%h got:%h", 8'hff, rx_byte);
    repeat(2) txRxByte('h84, rx_byte); 
    assert (rx_byte == 'haa) else $fatal(1, "bad read leds[15:0]:  expect:%h got:%h", 8'haa, rx_byte);

    //set back to 'h0000
    txRxByte('h03,rx_byte);
    txRxByte('h00,rx_byte);
    txRxByte('h04,rx_byte);
    txRxByte('h00,rx_byte);
    assert( leds == 'h0) else $fatal(1, "bad leds: expect:%h got:%h", 16'h0, leds);
endtask: test_leds

initial begin
    
    initialize();

    repeat(10) @(posedge clk) #2;
    rst = 'h0;

    repeat(10) @(posedge clk) #2;
    
    test_dvalid();
    
    test_chip_id();
    test_switches();
    test_leds();
   
    $display("@@@Passed");
    $finish;
end

endmodule
