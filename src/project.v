/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    
    output wire [7:0] uo_out,   
    input  wire [7:0] uio_in,   
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);

  reg [31:0] inputs;
  reg [31:0] weights;
  reg [17:0] convolution;
  reg [9:0] outputState;
  reg odd = 1'b0;
  
  assign uio_oe[1:0] = 1;
  assign uio_oe[7:2] = 0;
  
  wire [7:0] mul0 = inputs[7:0] * weights[7:0];
  wire [7:0] mul1 = inputs[15:8] * weights[15:8];
  wire [7:0] mul2 = inputs[23:16] * weights[23:16];
  wire [7:0] mul3 = inputs[31:24] * weights[31:24];
  
  always @ (posedge clk) begin
    if (!rst_n) begin
      inputs <= 32'b0;
      weights <= 32'b0;
      odd <= 1'b0;
      convolution <= 18'b0;
    end else if (uio_in[7]) begin
      outputState <= {odd, odd ? convolution[17:9] : convolution[8:0]};
      odd <= !odd;
    end else if (uio_in[6]) begin
      weights <= {ui_in[7:0], weights[31:8]};
    end else begin
      inputs <= {ui_in[7:0], inputs[31:8]};
    end
    
    convolution <= (inputs[7:0] * weights[7:0]) + (inputs[15:8] * weights[15:8]) + (inputs[23:16] * weights[23:16]) + (inputs[31:24] * weights[31:24]);
  end

  assign uo_out = outputState[7:0];
  assign uio_out[1:0] = outputState[9:8];

  wire _unused = &{ena, uio_in[5:0], 1'b0};

endmodule