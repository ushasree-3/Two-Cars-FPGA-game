`default_nettype none
// Reference : https://projectf.io/posts/fpga-graphics/

module vga640x360(
    input wire i_clk,           // base clock
    input wire i_pix_stb,       // pixel clock strobe
    input wire i_rst,           // reset: restarts frame
    output wire o_hs,           // horizontal sync
    output wire o_vs,           // vertical sync
    output wire o_blanking,     // high during blanking interval
    output wire o_active,       // high during active pixel drawing
    output wire o_screenend,    // high for one tick at the end of screen
    output wire o_animate,      // high for one tick at end of active drawing
    output wire [9:0] o_x,      // current pixel x position stored as 10 bit number (num of pixels = 800 <2^10 = 1024)
    output wire [8:0] o_y       // current active pixel y position (num of active lines = 360
    );

    localparam HS_STA = 16;              // horizontal sync start / horizontal front porch end
    localparam HS_END = 16 + 96;         // horizontal sync end / horizontal back porch start
    localparam HA_STA = 16 + 96 + 48;    // horizontal active pixel start / horizontal back porch end
    localparam VS_STA = 480 + 10;        // vertical sync start / vertical active pixel + vertical front porch end
    localparam VS_END = 480 + 10 + 2;    // vertical sync end / vertical back porch start
    localparam VA_STA = 60;              // vertical active pixel start. starts from 0 because we are not filling the entire vertical screen
    localparam VA_END = 420;             // vertical active pixel end
    localparam LINE   = 800;             // total number of pixels in one line
    localparam SCREEN = 525;             // total number of lines in the screen

    reg [9:0] h_count;  // line position stored as 10 bit number (num of pixels = 800 <2^10 = 1024) 
    reg [9:0] v_count;  // screen position stored as 10 bit number (num of line = 525 < 2^10 = 1024)

    // generate sync signals (active low for 640x480)
    assign o_hs = ~((h_count >= HS_STA) & (h_count < HS_END)); // 0 when horizontal pixel position on the screen is on syncing region
    assign o_vs = ~((v_count >= VS_STA) & (v_count < VS_END)); // 0 when vertical line position on the screen is on syncing region

    // keep x and y bound within the active pixels
    assign o_x = (h_count < HA_STA) ? 0 : (h_count - HA_STA); // active pixel count starting with 0 from HA_STA, else 0
    assign o_y = (v_count >= VA_END) ? 
                    (VA_END - VA_STA - 1) : (v_count - VA_STA); // active line count starting with 0 from VA_STA, else 359

    // blanking: high within the blanking period
    assign o_blanking = ((h_count < HA_STA) | (v_count > VA_END - 1)); 

    // active: high during active pixel drawing, is not ~o_blanking because the whole vertical region(480) is not covered, only 30 is covered
    assign o_active = ~((h_count < HA_STA) | 
                        (v_count > VA_END - 1) | 
                        (v_count < VA_STA));

    // screenend: high for one tick at the end of the screen
    assign o_screenend = ((v_count == SCREEN - 1) & (h_count == LINE));

    // animate: high for one tick at the end of the final active pixel line
    assign o_animate = ((v_count == VA_END - 1) & (h_count == LINE));

    always @ (posedge i_clk)
    begin
        if (i_rst)  
        begin
            h_count <= 0;
            v_count <= 0;
        end
        if (i_pix_stb)  // once per pixel
        begin
            if (h_count == LINE)  // end of line
            begin
                h_count <= 0; // reset h_count to 0
                v_count <= v_count + 1; // go to new line
            end
            else 
                h_count <= h_count + 1; // continue moving along the line  

            if (v_count == SCREEN)   // end of screen
                v_count <= 0;  // go to new frame
        end
    end
endmodule
