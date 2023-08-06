module single_cycle_processor_cl (
  									
  									input logic [32-1:0] instruction,
  									input logic BrEq,
  									input logic BrLT,
  									output logic [3-1:0] alu_op,
  									output logic pc_sel,
  									output logic [3-1:0] imm_sel,
  									output logic reg_write_en,
  									output logic BrUn,
  									output logic busA_sel_mux,
  									output logic busB_sel_mux,
  output logic [3-1:0]alu_sel,
  									output logic mem_rw,
  output logic [2-1:0] wb_sel
											);
 //0000000 01001 01001 000 01100 1100011 //00948663
 //BEQ x9, x9, 12
  //opcodes
  //0110011  R-type
  //0010011  Immediate type (I type)
  //0000011  Load type (sub type of I)
  //0100011  Story type
  //1100011  Branch type
  //1100111 JALR
  //1101111 JAL
  //0110111 LUI
  //0010111 AUIPC
  
  //parameters for immediate generation
  parameter I = 1;
  parameter S = 2;
  parameter B = 3;
  parameter J = 4;
  parameter U = 5;

  assign alu_op = instruction[14:12];//alu_op
  //pc control
  always @ (*) begin
    if ( ((instruction [6:0] == 7'b1100111 )/*JALR*/ |  (instruction [6:0] == 7'b1101111 ))/*JAL*/ | ((instruction [6:0] == 7'b1100011/*B type*/ )&&(instruction [14:12] == 3'b000 && BrEq) | (instruction [14:12] == 3'b001 && !BrEq) | (instruction [14:12] == 3'b100 && BrLT) | (instruction [14:12] == 3'b101 && !BrLT)  | (instruction [14:12] == 3'b110 && BrLT) | (instruction [14:12] == 3'b111 && !BrLT)) ) //B , JALR , JAL
      	pc_sel = 1;//taken
    else // R, I, L, S, LUI, AUIPC
      pc_sel = 0;//Not Taken
   
  end
  
  //immediate selection
  always @(*) begin
    if(instruction[6:0] ==7'b0010011 | instruction[6:0]==7'b0000011 | instruction [6:0] == 7'b1100111 /*JALR*/) //I, L,JALR
      imm_sel = I;
    else if (instruction[6:0] == 7'b0100011) //S
      imm_sel = S;
    else if (instruction [6:0] == 7'b1100011) //B
      imm_sel = B;
    else if (instruction [6:0] == 7'b1101111 ) //JAL
      imm_sel = J;
    else if ( instruction[6:0] == 7'b0110111 |  instruction[6:0] == 7'b0010111 ) // LUI, AUIPC
      imm_sel = U;
    else //R
      imm_sel = 0;
    
  end

  //register write enable
  always @ (*) begin
    if( instruction[6:0] == 7'b0110011 |  instruction[6:0] == 7'b0010011 | instruction[6:0] == 7'b0000011 | instruction[6:0] == 7'b1100111 | instruction[6:0] == 7'b1101111 | instruction[6:0] == 7'b0110111 | instruction[6:0] == 7'b0010111 ) //R, I, Load, JALR, JAL, LUI, AUIPC
      reg_write_en = 1;
    else if (instruction [6:0] == 7'b0100011 | instruction [6:0] == 7'b1100011 )// S type and B type
      reg_write_en = 0;
    
  end
  
  //BrUN
  always @ (*) begin
    if(instruction [6:0] == 7'b1100011 /*B*/ && (instruction[14:12]==3'b110 /*BrLTU*/ | instruction[14:12]==3'b111/*BGEU*/ ))
       BrUn = 1;
     else 
       BrUn = 0;
  end
  
  //mux A selection
  always @ (*) begin
    if(instruction [6:0] == 7'b1100011 | instruction[6:0] == 7'b1101111 | instruction[6:0] == 7'b0010111 ) // B type, JAL, AUIPC
      busA_sel_mux = 1;
    else //R, I, Load, S,JALR //Don't care for LUI
      busA_sel_mux = 0;
    
  end
  //bus selection from mux and alu selection 
  always @ (*) begin
    if(instruction[6:0] == 7'b0010011 | instruction[6:0] == 7'b0000011 | instruction [6:0] == 7'b0100011 | instruction [6:0] == 7'b1100011 | instruction [6:0] == 7'b1100111 | instruction [6:0] == 7'b1101111 |  instruction[6:0] == 7'b0110111 | instruction[6:0] == 7'b0010111 ) begin //I, L, s, B, JALR, JAL, LUI, AUIPC
      busB_sel_mux = 1;
    end
     else begin //R
        busB_sel_mux = 0;
     end
  end
  
  
  //alu selection
  always @ (*) begin
    if (instruction [6:0] == 7'b0110011 /*R type*/ ) // R type
      if(instruction[30]==1)
      		alu_sel = 1; //subtraction
    	else 
          	alu_sel = 0;
    
    else if( instruction[6:0]==7'b0010011 /*I type*/ )
      if(alu_op == 3'b101 && instruction[30]==1)
        alu_sel = 1;
    else 
      	alu_sel = 0;
    else if( instruction[6:0] == 7'b0110111 )
      alu_sel = B; //B, LUI
  	else
      alu_sel = J;//add//AUIPC
  end
  
  //mem_rw
  always @ (*) begin
    if(instruction[6:0] == 7'b0100011) //S
      mem_rw = 1; //Write
    else //R,I,L,B, JALR, LUI, AUIPC
      mem_rw = 0;//Read
  end
  
  //wb_sel
  always @(*) begin
    if(instruction[6:0]==7'b0000011 ) // L 
      wb_sel = 0;//Dmem
    else if(instruction [6:0] == 7'b1100111 | instruction [6:0] == 7'b1101111 )// JALR , JAL
        wb_sel = 2; //pc+ 4
    else// R, I , S, B, LUI, AUIPC
      	wb_sel = 1; //alu out
  end
endmodule
