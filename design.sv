module single_cycle_processor (
								input logic reset,
								input logic clk
													);
  wire pc_sel_wire;
  wire [32-1:0] alu_out_Ma_wire;
  wire [32-1:0] pc_ID_wire;
  wire [32-1:0] pc_Ex_wire;
  wire [32-1:0] pc_Ma_wire;
  wire [32-1:0] inst_ID_wire;
  wire [32-1:0] inst_Ex_wire;
  wire [32-1:0] inst_Ma_wire;
  wire [32-1:0] inst_Wb_wire;
  wire [32-1:0] inst_at_Wb_wire;
  wire reg_write_en_wire;
  wire [32-1:0] wb_mux_out_wire;
  wire [32-1:0] wb_mux_out_Wb_wire;
  wire [32-1:0] rs1_Ex_wire;
  wire [32-1:0] rs2_Ex_wire;
  wire [32-1:0] rs2_Ma_wire;
  wire busA_mux_sel_wire;
  wire busB_mux_sel_wire;
  wire [3-1:0] imm_sel_wire;
  wire BrUn_wire;
  wire [3-1:0]alu_sel_wire;
  wire [3-1:0] alu_op_wire;
  wire BrEq_wire;
  wire BrLT_wire;
  wire mem_rw_wire;
  wire [2-1:0]wb_sel_wire;
 
  
  single_cycle_processor_cl SCP_cl_inst ( .instruction(inst_ID_wire), .BrEq(BrEq_wire), .BrLT(BrLT_wire), .alu_op(alu_op_wire), .pc_sel(pc_sel_wire), .imm_sel(imm_sel_wire), .reg_write_en(reg_write_en_wire), .BrUn(BrUn_wire), .busA_sel_mux(busA_mux_sel_wire), .busB_sel_mux(busB_mux_sel_wire), .alu_sel(alu_sel_wire), .mem_rw(mem_rw_wire), .wb_sel(wb_sel_wire));
  
  If_stage If_stage_inst (.clk(clk), .reset(reset), .pc_sel(pc_sel_wire), .alu_out(alu_out_Ma_wire), .pc_ID(pc_ID_wire), .inst_ID(inst_ID_wire));
  
  Id_stage Id_stage_inst (.clk(clk), .reset(reset), .reg_write_en(reg_write_en_wire), .pc_ID(pc_ID_wire), .inst_ID(inst_ID_wire), .inst_Wb(inst_at_Wb_wire), .wb_mux_out_Wb(wb_mux_out_Wb_wire), .pc_Ex(pc_Ex_wire), .rs1_Ex(rs1_Ex_wire), .rs2_Ex(rs2_Ex_wire), .inst_Ex(inst_Ex_wire));
  
  Ex_stage Ex_stage_inst ( .pc_Ex(pc_Ex_wire), .rs1_Ex(rs1_Ex_wire), .rs2_Ex(rs2_Ex_wire), .inst_Ex(inst_Ex_wire), .busA_mux_sel(busA_mux_sel_wire), .busB_mux_sel(busB_mux_sel_wire), .imm_sel(imm_sel_wire), .BrUn(BrUn_wire),.alu_sel(alu_sel_wire), .alu_op(alu_op_wire), .BrEq(BrEq_wire), .BrLT(BrLT_wire), .pc_Ma(pc_Ma_wire), .alu_out_Ma(alu_out_Ma_wire), .rs2_Ma(rs2_Ma_wire), .inst_Ma(inst_Ma_wire));
  
  Ma_stage Ma_stage_inst ( .clk(clk), .reset(reset), .pc_Ma(pc_Ma_wire), .alu_out_Ma(alu_out_Ma_wire), .rs2_Ma(rs2_Ma_wire), .inst_Ma(inst_Ma_wire), .mem_rw(mem_rw_wire), .alu_op(alu_op_wire), .wb_sel(wb_sel_wire), .reg_write_en(reg_write_en_wire), .wb_mux_out(wb_mux_out_wire), .inst_Wb(inst_Wb_wire));
  
  Wb_stage Wb_stage_inst ( .wb_mux_out(wb_mux_out_wire), .inst_Wb(inst_Wb_wire), .wb_mux_out_Wb(wb_mux_out_Wb_wire), .inst_at_Wb(inst_at_Wb_wire));
  
 
endmodule


`include "single_cycle_processor_cl.sv"
`include "IF.sv"
`include "ID.sv"
`include "EX.sv"
`include "MA.sv"
`include "WB.sv"

