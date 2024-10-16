/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // 2x2, each value is 8-bits
  reg [15:0] line1;
  reg [15:0] line2;
  
  reg [31:0] weights;
  reg [17:0] convolution;
  reg [9:0] outputState;
  
  // Stores if the clock counts are odd or even
  reg odd = 1'b0;
  
  assign uio_oe[1:0] = 1;
  assign uio_oe[7:2] = 0;

  assign uio_out[7:2] = 0;

  always @ (posedge clk) begin
    if (!rst_n) begin
      inputs <= 32'b0;
      weights <= 32'b0;
      odd <= 1'b0;
    end else if (uio_in[7]) begin
      outputState <= {odd, odd ? convolution[17:9] : convolution[8:0]};
      odd <= !odd;
    end else if (uio_in[6]) begin
      weights <= {ui_in[7:0], weights[31:8]};
    end else begin
      if (uio_in[5]) begin
        line1 <= {ui_in[7:0], line1[15:8]};
      end else begin
        line2 <= {ui_in[7:0], line2[15:8]};
      end
    end
    
    convolution <= (line1[7:0] * weights[7:0]) + (line1[15:8] * weights[15:8]) + (line2[23:16] * weights[23:16]) + (line2[31:24] * weights[31:24]);
  end

  assign uo_out = outputState[7:0];
  assign uio_out[1:0] = outputState[9:8];

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[4:0], 1'b0};

endmodule