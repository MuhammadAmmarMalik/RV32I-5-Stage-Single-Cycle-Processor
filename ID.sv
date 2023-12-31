
module Id_stage (
					input clk,
  					input reset,
  					input logic reg_write_en,
  					input logic [32-1:0]pc_ID,
  					input logic [32-1:0]inst_ID,
  					input logic [32-1:0] inst_Wb,
  					input logic [32-1:0] wb_mux_out_Wb,
  					output logic [32-1:0] pc_Ex,
  					output logic [32-1:0] rs1_Ex,
  					output logic [32-1:0] rs2_Ex,
  					output logic [32-1:0] inst_Ex
  

						);
  assign pc_Ex = pc_ID	;
  assign inst_Ex = inst_ID;
  
  
  logic [32-1:0] output_var;
  assign output_var = reg_mem[8];
  
  logic [5-1:0] addrA; //address for register rs1
  logic [5-1:0] addrB; //address for register rs2
  logic [5-1:0] addrD; //address for destination resgister
  
  
  logic [3-1:0] alu_op; //ALU operating selection after decoding
  
  logic [32-1:0] reg_mem [32-1:0]; //Register inside processor
  
  
  
   ////reg_mem initialization  
   always @ (posedge clk) begin
      
    	if(reset) begin
     	 for (int i = 0; i<32; i++)
       		reg_mem [i] <= i;
  		end
  	end
  
  
  //Decoder
  always @ (*) begin
	//addresses
    addrA = inst_ID[19:15];
    addrB = inst_ID[24:20];
    addrD = inst_ID[11:7];
      
    //alu operation
    alu_op = inst_ID[14:12];
      
    //register data for alu
     rs1_Ex = reg_mem [addrA];
     rs2_Ex = reg_mem [addrB];
    
  end//always
  
  always @ (posedge clk) begin
    
    if(reg_write_en)
      reg_mem[addrD] <= wb_mux_out_Wb; //newly defined
  end
  //DMEM BLOCK
endmodule