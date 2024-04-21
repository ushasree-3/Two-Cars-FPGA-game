
module background(
input wire CLK,
input wire active,
input wire RST1,
input wire pix_stb1,
input wire x,
input wire y,
input wire [9:0] car1_x,
input wire [9:0] car2_x,
input wire [8:0] car_y,
input wire object_is_square,
input wire object_is_square2,
input wire [9:0] object_x,
input wire [9:0] object_x2,
input wire [8:0] object_y,
input wire object_generated,
output reg [3:0] VGA_R,
output reg [3:0] VGA_G,
output reg [3:0] VGA_B
    );
    
always @ (posedge CLK) begin
    if (active) begin
       if (RST1 && pix_stb1) begin
           VGA_R <= 4'b0000;
           VGA_G <= 4'b0000;
           VGA_B <= 4'b0000;    

       end

   // Background
       if ((x >= 239-2 && x <= 399+2)) begin
           VGA_R <= 4'b0000;
           VGA_G <= 4'b0000;
           VGA_B <= 4'b1111;
       end else begin
           VGA_R <= 4'b0000;
           VGA_G <= 4'b0000;
           VGA_B <= 4'b0000;    
       end

       // Roads, cars and objects
       if ((x >= 239-2 && x <= 239+2) || (x >= 279-1 && x <= 279+1) || (x >= 319-2 && x <= 319+2) || (x >= 359-1 && x <= 359+1) || (x >= 399-2 && x <= 399+2)) begin
           VGA_R <= 4'b1100;
           VGA_G <= 4'b1111;
           VGA_B <= 4'b1111; // White colour (roads)
       end else if (x >= car1_x && x < car1_x + 17 && y >= car_y && y < car_y + 34) begin
           VGA_R <= 4'b1111; 
           VGA_G <= 4'b0000;
           VGA_B <= 4'b0000; // Red color for car 1
       end else if (x >= car2_x && x < car2_x + 17 && y >= car_y && y < car_y + 34) begin
           VGA_R <= 4'b0000; 
           VGA_G <= 4'b1111;
           VGA_B <= 4'b0000; // Blue color for car 2
       end else if (object_generated && object_is_square && x >= object_x-7 && x < object_x + 7 && y >= object_y-7 && y < object_y + 7) begin
           VGA_R <= 4'b1111;
           VGA_G <= 4'b0000;
           VGA_B <= 4'b0000; // Red color for square object
       end else if (object_generated && object_is_square2 && x >= object_x2-7 && x < object_x2 + 7 && y >= object_y-7 && y < object_y + 7) begin
           VGA_R <= 4'b1111;
           VGA_G <= 4'b0000;
           VGA_B <= 4'b0000;  // Red color for square object for car2
       end else if (object_generated && ~object_is_square && ((x - object_x)*(x - object_x) + (y - object_y)*(y - object_y) <= 64)) begin
           VGA_R <= 4'b0000;
           VGA_G <= 4'b1111;
           VGA_B <= 4'b0000; // Green color for circular object
       end else if (object_generated && ~object_is_square2 && ((x - object_x2)*(x - object_x2) + (y - object_y)*(y - object_y) <= 64)) begin
           VGA_R <= 4'b0000;
           VGA_G <= 4'b1111;
           VGA_B <= 4'b0000;  // Green color for circular object for car2
       end else begin
           VGA_R <= 4'b0000;
           VGA_G <= 4'b0000;
           VGA_B <= 4'b1111; 
       end
   end else begin
       VGA_R <= 4'b0000;
       VGA_G <= 4'b0000;
       VGA_B <= 4'b0000;    
   end
end
endmodule
