/**
 * Debounce an incomming signal
 * 
 * Andrew Lukefahr
 * lukefahr@iu.edu
 *
 */

`timescale 1ns / 1ps

// this debounces (for 5 clock cycles)
// and synchronizes an incomming signal
module debounce(
    input           clk,
    input           rst, 

    input           bouncy,
    output logic    stable
    );

    localparam DELAY_CYCLES = 5; 
    localparam CNT_BITS = $clog2( DELAY_CYCLES );
    logic [CNT_BITS-1:0] cnt, nextCnt;

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt <= 'h0;
        end else begin
            cnt <= nextCnt;
        end
    end

    always_comb begin
        nextCnt = 'h0; 

        // post debounce, output depends on input
        if (cnt == DELAY_CYCLES) begin
            nextCnt = ( bouncy ? cnt : 'h0 ); 
        //during debounce, ignore input
        end else if (cnt != 'h0) begin
            nextCnt = cnt + 'h1;
        //pre debounce, accept input
        end else if (bouncy) begin
            nextCnt = cnt + 'h1; 
        end
    end

    assign stable =  ( cnt != 'h0 );

endmodule
