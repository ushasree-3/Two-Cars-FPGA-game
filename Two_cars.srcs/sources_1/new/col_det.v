
module collision_detector (
    input wire clk,
    input wire rst,
    input wire [9:0] car1_x,
    input wire [9:0] car2_x,
    input wire [8:0] car_y,
    input wire object_is_square,
    input wire object_is_square2,
    input wire [9:0] object_x,
    input wire [9:0] object_x2,
    input wire [8:0] object_y,
    output reg RST1,
    output reg RST2  // For score
);

    always @(posedge clk or posedge rst) begin
        RST2 <= 0;
        RST1 <= 0;
        
        if (rst) begin
            RST1 <= 0;
            RST2 <= 0;
        
        end else begin
            if ((object_is_square && object_y >= car_y && object_y <= car_y + 34 &&
                 (object_x - 6 >= car1_x && object_x + 6 <= car1_x + 17)) || (object_is_square2 && object_y >= car_y && object_y <= car_y + 34 &&
                 (object_x2 - 6 >= car2_x && object_x2 + 6 <= car2_x + 17)) || (~object_is_square && object_y >= car_y && object_y <= car_y + 34 &&
                 ~(object_x - 6 >= car1_x && object_x + 6 <= car1_x + 17)) || (~object_is_square2 && object_y >= car_y && object_y <= car_y + 34 &&
                 ~(object_x2 - 6 >= car2_x && object_x2 + 6 <= car2_x + 17))) begin
              // Collision case 
                RST1 <= 1; 
                RST2 <= 0;
                
            end else if ((~object_is_square && object_y >= car_y && object_y <= car_y + 34 &&
                  (object_x - 6 >= car1_x && object_x + 6 <= car1_x + 17)) || (~object_is_square2 && object_y >= car_y && object_y <= car_y + 34 &&
                  (object_x2 - 6 >= car2_x && object_x2 + 6 <= car2_x + 17))) begin
                // Scoring case
                  RST2 <= 1; 
                  RST1 <= 0;
            
            end else begin
                RST1 <= 0;
            end
       end
    end
endmodule
