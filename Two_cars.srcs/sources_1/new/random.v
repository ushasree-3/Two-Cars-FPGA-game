`default_nettype none

// Reference : https://github.com/rfotino/verilog-tetris/blob/master/randomizer.v

module randomo(
    input wire       clk,
    output reg [2:0] random
    );

    initial begin
        random = 1;
    end

    always @ (posedge clk) begin
        if (random == 7) begin
            random <= 1;
        end else begin
            random <= random + 1;
        end
    end

endmodule
