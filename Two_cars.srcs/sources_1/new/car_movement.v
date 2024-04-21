
module car_movement(
input wire CLK,
input wire RST,
input wire [1:0]switch_b,
output reg [9:0] car1_x,
output reg [9:0] car2_x
);

initial car1_x = 290;
initial car2_x = 331;

 // Car positions based on switches   
 always @(posedge CLK)
    
    if (RST) begin
         car1_x <= 251;
         car2_x <= 331;
    end else begin
        if (switch_b[1])
           car1_x <= 251;
        else
           car1_x <= 290;
              
        if (switch_b[0])
           car2_x <= 331;
        else
           car2_x <= 370;
    end
  
endmodule
