module Ex_stage (
                    input logic [32-1:0] pc_Ex,
                    input logic [32-1:0] rs1_Ex,
                    input logic [32-1:0] rs2_Ex,
                    input logic [32-1:0] inst_Ex,
                    input logic busA_mux_sel,
                    input logic busB_mux_sel,
                    input logic [3-1:0]imm_sel,
                    input logic BrUn,
  input logic [3-1:0] alu_sel,
  					input logic [3-1:0] alu_op,

                    output logic BrEq,
                    output logic BrLT,
                    output logic [32-1:0] pc_Ma,
  					output logic [32-1:0] alu_out_Ma,
                    output logic [32-1:0] rs2_Ma,
                    output logic [32-1:0] inst_Ma
													);
  
  //parameter for immediate generation
  parameter I=1; //Load instruction
  parameter S=2; //Store instruction
  parameter B = 3; //branch 
  parameter J = 4; //jump
  parameter U = 5; //LUI
  
  logic [32-1:0] imm_32;//for immediate genator to mux
  logic [32-1:0] mux_a_out; //from mux to ALU as RS1
  logic [32-1:0] mux_b_out; //from mux to ALU as RS2
  logic [32-1:0] hold_reg;//used in alu for SRA
  
  //mux out
  assign mux_b_out = busB_mux_sel?imm_32: rs2_Ex;
  assign mux_a_out = busA_mux_sel? pc_Ex :rs1_Ex;
  assign rs2_Ma = rs2_Ex;
  assign pc_Ma = pc_Ex;
  
  //Branch comparision
  always @ (*) begin
    if (BrUn == 1 ) begin
      if(rs1_Ex == rs2_Ex)
        BrEq = 1;
      else 
         BrEq = 0;
    
      if(rs1_Ex<rs2_Ex)
      	 BrLT = 1;
      else 
          BrLT = 0;
    end
    else if (BrUn == 0 ) begin
      if(rs1_Ex == rs2_Ex)
        BrEq = 1;
      else 
         BrEq = 0;
      
      if(rs1_Ex<rs2_Ex)
      	 BrLT = 1;
      else 
          BrLT = 0;
      
    end
  end
  
  //Immediate Generator
  always @ (*) begin
      imm_32[0] = (imm_sel == B | imm_sel == J | imm_sel == U)? 0/*if B, J , U*/ : imm_sel == I? inst_Ex[20]: inst_Ex[7] /*not B J U and I then it will be S*/;
    imm_32[4:1]= imm_sel == J? /*if J*/ inst_Ex[24:21] : /*not J*/(imm_sel == S | imm_sel == B)? inst_Ex[11:8] : imm_sel == I? inst_Ex[24:21] :0 /*if not J S B I then do it U*/;           
    imm_32[10:5]=imm_sel == U? 0/*if U*/ : inst_Ex[30:25];//same for all format
    imm_32[11] = imm_sel == B? /*if b*/inst_Ex[7]:/*if not b*/imm_sel == J? /*if J*/inst_Ex[20] :imm_sel == U? 0/*if U*/ : inst_Ex[31] /*if not B J U then it will be S and I*/;
      for(int i = 12; i<20 ; i++)
        imm_32[i] = (imm_sel==J | imm_sel==U)? inst_Ex[i] : inst_Ex[31];// mux selection
      for(int i = 20; i<32 ; i++)
        imm_32[i] = imm_sel == U? inst_Ex[i]/*If U*/ : inst_Ex[31] /*Not U type*/;
  end//always
  
  
  //ALU
  always @ (*) begin
    if(alu_sel==1 | alu_sel == 0) begin
    	case(alu_op)
      		3'b000 :begin //Subtraction
              if(alu_sel ==0 /*addition*/  )
                      	alu_out_Ma = mux_a_out +  mux_b_out;
                		
              		else  //subtraction 
                      	alu_out_Ma = mux_a_out - mux_b_out;
            end
            	
	  		3'b001 : begin//sll(shifts on the value in register rs1 by the shift amount held in the lower 5 bits of register rs2.0
              /*if(wb_sel == 1 && mem_rw==0 && pc_sel ==0)*/ /*unknow*/
              			alu_out_Ma = mux_a_out << mux_b_out[4:0];
              			//alu_out_Ma =20;
          			
            end
    		3'b010 :begin//slt set less than
              /*if(wb_sel==1) begin*/ //unknown
                      if(mux_a_out<mux_b_out)
          					alu_out_Ma = 1;
      					else
          					alu_out_Ma = 0;
                    //end/
            end
		    3'b011 :begin //sltu set less than unsigned
              			if(mux_a_out<mux_b_out)
	   		       			alu_out_Ma = 1;
    	  			 	else
        	  				alu_out_Ma = 0;
            end
		    3'b100 :begin //XOR
              			//if(wb_sel==1 && pc_sel ==0) //unknown
    		   		 	alu_out_Ma = mux_a_out ^ mux_b_out;
            end
			3'b101 :begin //SRL shift right logic or shift logic right (shifts on the value in register rs1 by the shift amount held  in the lower 5 bits of register rs2.    	    					  
              if(alu_sel==0) 
                     	alu_out_Ma = mux_a_out >> mux_b_out[4:0];		     	
              else if (alu_sel==1) begin //else block for shift right arithmetic
	                	hold_reg = mux_a_out;
                for (int i =0, temp =0; i< mux_b_out[4:0]; i++) begin//important only use lower five bit of immediate generator to shift the value
        	    	   		temp=hold_reg[0];           
            	       		hold_reg = hold_reg >>1;
                	   		hold_reg[31]=temp;              		    		
	               	  	end//for loop
                   		alu_out_Ma = hold_reg;
                   	end//else block
            end 
    	 	3'b110 :begin
              			//if(pc_sel == 0) unknown
       					alu_out_Ma = mux_a_out | mux_b_out;
            end
	     	3'b111 :begin
              			//if(pc_sel == 0) unknown
    	   	     		alu_out_Ma = mux_a_out & mux_b_out;
            end
    	endcase  
    end
   else if(inst_Ex[6:0] == 7'b0110111 /*LUI*/)
      alu_out_Ma = mux_b_out;
  else if( inst_Ex [6:0] == 7'b0000011 /*Load type*/ | inst_Ex [6:0] == 7'b0100011 /*Store type*/ | (alu_op == 3'b000 && (BrEq))/*BEQ and comparision*/ | (alu_op == 3'b001 && (!BrEq))/*BNE and comparision*/ | (alu_op == 3'b100 && (BrLT))/*BLT and comparision*/ | (alu_op == 3'b101 && (!BrLT))/*BGE and comparision*/  | (alu_op == 3'b101 && (!BrLT))/*BGE and comparision*/ | (alu_op == 3'b110 && (BrUn && BrLT)/*BLTU and comparision*/) | (alu_op == 3'b111 && (BrUn && !BrLT)/*BGEU and comparision*/) | inst_Ex [6:0] == 7'b1100111 /*JALR*/|imm_sel == J /*JAL*/ | inst_Ex[6:0] == 7'b0110111/*AUIPC*/  )
      alu_out_Ma = mux_a_out + mux_b_out; //branch taken /*For AUIPC branch not taken*/
 
  else
      alu_out_Ma = mux_a_out + 4;//branch not taken and JALR
    //
  end//always block end
  
endmodule