`default_nettype none

module top (
    input wire CLK,             // 100 MHz
    input wire RST,
    input wire [1:0] switch_b, 
    input wire on_off,        
    output wire VGA_HS_O,       // Horizontal sync output
    output wire VGA_VS_O,       // Vertical sync output
    output reg [3:0] VGA_R,     
    output reg [3:0] VGA_G,     
    output reg [3:0] VGA_B,
    output wire [0:6] seg,       // 7 segment display segment pattern
    output wire [3:0] digit  
);

    // generating a 25 MHz pixel strobe 
    reg [15:0] cnt;
    reg [16:0] cnt1;
    reg pix_stb;
    reg pix_stb1;
    wire RST1;
    always @(posedge CLK) begin
        {pix_stb, cnt} <= cnt + 16'h4000;  // divide by 4: (2^16)/4 = 0x4000
        {pix_stb1, cnt1} <= cnt1 + 17'b1;  // divide by 2^16
    end

    wire [9:0] x;  // current pixel x position: 10-bit value: 0-1023
    wire [8:0] y;  // current pixel y position:  9-bit value: 0-511
    wire active;   // high during active pixel drawing

    vga640x360 display (
        .i_clk(CLK), 
        .i_pix_stb(pix_stb),
        .i_rst(RST),
        .o_hs(VGA_HS_O), 
        .o_vs(VGA_VS_O), 
        .o_x(x), 
        .o_y(y),
        .o_active(active)
    );

    wire [9:0] car1_x;  // x position of car 1
    wire [9:0] car2_x; //  x position of car 2
    reg [8:0] car_y;    // Y position of both cars
    initial car_y = 296;
    wire object_generated, object_is_square, path, object_is_square2, path2;
    
    wire [9:0] object_x;   // X-coordinate of the object
    wire [8:0] object_y;   // Y-coordinate of the object
    wire [9:0] object_x2;  
    wire [2:0] rand;
    wire RST2;
    
    randomo randomo_ (.clk(pix_stb1),.random(rand));

    object_generator obj_gen (
        .pix_stb1(pix_stb1),
        .RST(RST || ~on_off),
        .active(active),
        .rand(rand),
        .RST1(RST1),
        .object_x(object_x),
        .object_x2(object_x2),
        .object_y(object_y),
        .object_generated(object_generated),
        .object_is_square(object_is_square),
        .object_is_square2(object_is_square2),
        .path(path),
        .path2(path2)
    );

    collision_detector col_detect (
        .clk(CLK),
        .rst(RST || ~on_off),
        .car1_x(car1_x),
        .car2_x(car2_x),
        .car_y(car_y),
        .object_is_square(object_is_square),
        .object_is_square2(object_is_square2),
        .object_x(object_x),
        .object_x2(object_x2),
        .object_y(object_y),
        .RST1(RST1),
        .RST2(RST2)
    );

always @ (posedge CLK) begin

    if (active) begin
      
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
           VGA_B <= 4'b1111; // White colour for roads
       end else if (x >= car1_x && x < car1_x + 17 && y >= car_y && y < car_y + 34) begin
           VGA_R <= 4'b1111; 
           VGA_G <= 4'b0000;
           VGA_B <= 4'b0000; // Red color for car 1
       end else if (x >= car2_x && x < car2_x + 17 && y >= car_y && y < car_y + 34) begin
           VGA_R <= 4'b0000; 
           VGA_G <= 4'b1111;
           VGA_B <= 4'b0000; // Green color for car 2
       end else if (object_generated && object_is_square && x >= object_x-7 && x < object_x + 7 && y >= object_y-7 && y < object_y + 7) begin
           VGA_R <= 4'b1111;
           VGA_G <= 4'b0000;
           VGA_B <= 4'b0000; // Red color for square object for car1
       end else if (object_generated && object_is_square2 && x >= object_x2-7 && x < object_x2 + 7 && y >= object_y-7 && y < object_y + 7) begin
           VGA_R <= 4'b1111;
           VGA_G <= 4'b0000;
           VGA_B <= 4'b0000; // Red color for square object for car2
       end else if (object_generated && ~object_is_square && ((x - object_x)*(x - object_x) + (y - object_y)*(y - object_y) <= 64)) begin
           VGA_R <= 4'b0000;
           VGA_G <= 4'b1111;
           VGA_B <= 4'b0000; // Green color for circular object for car1
       end else if (object_generated && ~object_is_square2 && ((x - object_x2)*(x - object_x2) + (y - object_y)*(y - object_y) <= 64)) begin
           VGA_R <= 4'b0000;
           VGA_G <= 4'b1111;
           VGA_B <= 4'b0000; // Green color for circular object for car2
       end else begin
           VGA_R <= 4'b0000;
           VGA_G <= 4'b0000;
           VGA_B <= 4'b1111; // Blue colour for remaining area
       end
   end else begin
       VGA_R <= 4'b0000;
       VGA_G <= 4'b0000;
       VGA_B <= 4'b0000;    
   end
end
           
car_movement cm(
    .CLK(CLK),
    .RST(RST),
    .switch_b(switch_b),
    .car1_x(car1_x),
    .car2_x(car2_x)
);           

wire [3:0] w_1s, w_10s, w_100s, w_1000s;

digits digs(.RST2(RST2), .reset(RST || RST1 || ~on_off), .ones(w_1s), 
            .tens(w_10s), .hundreds(w_100s), .thousands(w_1000s));

seg7_control seg7(.clk_100MHz(CLK), .reset(RST || ~on_off), .ones(w_1s), .tens(w_10s),
                  .hundreds(w_100s), .thousands(w_1000s), .seg(seg), .digit(digit));


endmodule
