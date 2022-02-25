module top_tb();

`define SPI_DELAY #500

logic clk;
logic rst;
wire  [7:0] JC;
logic sck; //map to JC
logic ss;//map to JC
logic mosi;//map to JC
logic miso;//map to JC
logic [15:0] switches;
logic [15:0] leds;

//remap SPI to JC
assign JC[6] = sck;     //Sch JC9
assign JC[5] = mosi;    //Sch JC8
assign miso  = JC[4];   //Sch JC7
assign JC[7] = ss;      //Sch JC10




top DUT (
    .CLK100MHZ(clk),
    .btnC(rst),
    .sw(switches),
    .LED(leds),
    .JC
);

always #10 clk = ~clk;

task initialize ();
    clk = 'h0; rst = 'h1; 
    switches = 'h0;
    sck = 'h0; ss = 'h1; mosi = 'h0;
endtask: initialize

task txRxByte (
    input logic [7:0] tx_data,
    output logic [7:0] rx_data
    );
    $display("SPI Send:  %h", tx_data);
    for (int i = 7; i >= 0; --i) begin
        mosi = tx_data[i];
        `SPI_DELAY;
        sck = 'h1;
        rx_data[i] = miso;
        `SPI_DELAY;
        sck = 'h0;
    end
    `SPI_DELAY;
    $display("SPI Recv:  %h", rx_data);
endtask: txRxByte

task test_chip_id ();
    automatic logic [7:0] rx_byte;
    localparam chip_id = 8'h07;

    repeat(2) begin
        $display("Checking chip_id");
        txRxByte('h80,rx_byte);
        txRxByte('h00,rx_byte);
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
    assert( leds == 'h0) else $fatal(1, "bad leds: expect:%h got:%h", 16'h0, leds);
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

    automatic logic [7:0] rx_data; 
    
    initialize();

    repeat(10) @(posedge clk) #2;
    rst = 'h0;
    repeat(10) @(posedge clk) #2;

    ss = 'h0;
    `SPI_DELAY 

    test_chip_id();
    test_switches();
    test_leds();
   
    `SPI_DELAY
    ss = 'h1;
    `SPI_DELAY

    $display("@@@Passed");
    $finish;
end


endmodule
