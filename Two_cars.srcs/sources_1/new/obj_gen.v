module object_generator (
    input wire pix_stb1,
    input wire RST,
    input wire active,
    input wire [2:0] rand,
    input wire RST1,
    output reg [9:0] object_x,
    output reg [9:0] object_x2,
    output reg [8:0] object_y,
    output reg object_generated,
    output reg object_is_square,
    output reg object_is_square2,
    output reg path,
    output reg path2
);

   initial object_generated = 0;
   parameter OBJECT_SPEED = 1; // Speed of object movement

    always @(posedge pix_stb1) begin
     
         if (RST) begin
             object_generated <= 1'b0;
         
         end else  if (active && ~object_generated || (active && object_generated && object_y > 360)) begin
             // generates the object randomly and on different paths
             object_generated <= 1'b1;
             object_is_square <= rand[1];
             path <= rand[0];
             object_is_square2 <= rand[2];
             path2 <= rand[1];
             object_x <= path ? 10'd299:10'd259; 
             object_x2 <= path2 ? 10'd378:10'd339;
             object_y <= 9'd9; 

         end else if (active && object_generated && object_y < 293) begin
             // increment the y position for object
             object_y <= object_y + OBJECT_SPEED;   
                      
         end else if (active && object_generated && object_y >= 293) begin
            if (RST1) begin // Collision detected
              object_generated <= 1'b1;          
            end else begin 
              object_y <= object_y + OBJECT_SPEED;  
            end
            
         end else object_y <= object_y;
         
    end

endmodule



