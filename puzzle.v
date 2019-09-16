module puzzle(
input             clk, resetn,
	input             pcpi_valid,
	input      [31:0] pcpi_insn,
	input      [31:0] pcpi_rs1,
	input      [31:0] pcpi_rs2,
	output reg        pcpi_wr,
	output reg [31:0] pcpi_rd,
	output reg        pcpi_wait,
	output reg        pcpi_ready,
	//memory interface
	input      [31:0] mem_rdata,
	input             mem_ready,
	output            mem_write,
	output     [31:0] mem_wdata,
	output            mem_valid,
	output reg [31:0] mem_addr
);
	reg rand, done, flag;
	reg [1:0] last, zero_x, zero_y, target_x, target_y, now_x, now_y;
	reg [3:0] state, next_state;
	reg [5:0] cnt;
	reg [31:0] x, y, case_num;
	reg [5:0] distance [0:3];
	reg [3:0] puzzle [0:8];
	reg [3:0] next_puzzle [0:8];
	reg [3:0] temp_puzzle [0:8];
	parameter [3:0] READ_POS = 4'd0, READ_DATA = 4'd1, RIGHT = 4'd2, LEFT = 4'd3, UP = 4'd4, DOWN = 4'd5, CALC = 4'd6, MOVE = 4'd7, CHECK = 4'd8, PRINT = 4'd9;
	parameter [14:0] IMAGE_OFFSET = 15'd16384;
	integer i,j;
	wire pcpi_insn_valid = pcpi_valid && pcpi_insn[6:0] == 7'b0101011 && pcpi_insn[31:25] == 7'b0000001;

	//TODO: Memory interface. Modify these values to fit your needs
	assign mem_write = 0;
	assign mem_wdata = 0;
	assign mem_valid = 1;
	//assign mem_addr = 0;
	
	always @(posedge clk or negedge resetn) begin
		if(!resetn) begin
			flag = 1;
			state <= READ_POS;
			for(i=0;i<9;i=i+1)
				puzzle[i] <= 0;
		end else begin
			state <= next_state;
			for(i=0;i<9;i=i+1)
				puzzle[i] <= next_puzzle[i];
		end
	end

	always @* begin
		pcpi_wr = 0;
		pcpi_wait = 1;
		pcpi_ready = 0;
		pcpi_rd = 0;
		mem_addr = 0;
		cnt = 0;
		done = 1;
		for(i=0;i<9;i=i+1)
			next_puzzle[i] = puzzle[i];	
		case(state)
			READ_POS : begin
				if(pcpi_insn_valid) begin
					x = pcpi_rs1;
					y = pcpi_rs2;
					if(y == 4) begin
						case_num = x;
						pcpi_ready = 1;
						next_state = READ_POS;
					end
					else if(x == 0 && y == 3) next_state = RIGHT;
					else if(x == 1 && y == 3) next_state = LEFT;
					else if(x == 2 && y == 3) next_state = UP;
					else if(x == 3 && y == 3) next_state = DOWN;
					else if(x == 4 && y == 4) next_state = CHECK;
					else begin
						mem_addr = (IMAGE_OFFSET + (x+case_num*3)*3 + y) * 4;
						next_state = READ_DATA;
					end
				end else
					next_state = READ_POS;
			end

			READ_DATA : begin
				next_puzzle[x*3 + y] = mem_rdata;
				if(mem_rdata == 0) begin
				  zero_x = x;
				  zero_y = y;
				end
				if(x*3 + y == 8) next_state = PRINT;
				else begin
					next_state = READ_POS;
					pcpi_ready = 1;
				end
			end

			RIGHT : begin
				if(zero_y == 2'd2 || last == 2'd1) begin
					pcpi_ready = 1;
					next_state = READ_POS;
				end else begin
					next_state = CALC;
					for(i=0;i<9;i=i+1) begin
						if(puzzle[i] == 0) begin
							temp_puzzle[i] = puzzle[i+1];
							temp_puzzle[i+1] = 0;
							i = i+1;
						end else 
							temp_puzzle[i] = puzzle[i];
					end
				end
			end

			LEFT : begin
				if(zero_y == 2'd0 || last==2'd0) begin
					pcpi_ready = 1;
					next_state = READ_POS;
				end else begin
					next_state = CALC;
					for(i=0;i<9;i=i+1) begin
						if(puzzle[i] == 0) begin
							temp_puzzle[i] = puzzle[i-1];
							temp_puzzle[i-1] = 0;
						end else 
							temp_puzzle[i] = puzzle[i];
					end
				end
			end

			UP : begin
				if(zero_x == 2'd0 || last==2'd3) begin
					pcpi_ready = 1;
					next_state = READ_POS;
				end else begin
					next_state = CALC;
					for(i=0;i<9;i=i+1) begin
						if(puzzle[i] == 0) begin
							temp_puzzle[i] = puzzle[i-3];
							temp_puzzle[i-3] = 0;
						end else 
							temp_puzzle[i] = puzzle[i];
					end
				end
			end

			DOWN : begin
				if(zero_x == 2'd2 || last == 2'd2) begin
					next_state = MOVE;
				end else begin
					next_state = CALC;
					for(i=0;i<9;i=i+1) begin
						if(puzzle[i] == 0) begin
							temp_puzzle[i] = puzzle[i+3];
							j = i+3;
						end else 
							temp_puzzle[i] = puzzle[i];
					end
					temp_puzzle[j] = 0;
				end
			end

			CALC : begin
				/*$display("dir %d",x);
				$display("%d %d %d\n",temp_puzzle[0],temp_puzzle[1],temp_puzzle[2]);
				$display("%d %d %d\n",temp_puzzle[3],temp_puzzle[4],temp_puzzle[5]);
				$display("%d %d %d\n",temp_puzzle[6],temp_puzzle[7],temp_puzzle[8]);*/
				for(i=0;i<9;i=i+1) begin
					if(temp_puzzle[i]!=0) begin
						target_x = (temp_puzzle[i] - 1) / 3;
						target_y = (temp_puzzle[i] - 1) % 3;
						now_x = i / 3;
						now_y = i % 3;
						//$display("tar_x %d tar_y %d now_x %d now_y %d",target_x,target_y,now_x, now_y);
						if(now_x >= target_x && now_y >= target_y) cnt = cnt + now_x - target_x + now_y - target_y;
						else if(now_x >= target_x && now_y <= target_y) cnt = cnt + now_x - target_x + target_y - now_y;
						else if(now_x <= target_x && now_y >= target_y) cnt = cnt + target_x - now_x + now_y - target_y;
						else cnt = cnt + target_x - now_x + target_y - now_y;
					end
				end
				distance[x] = cnt;
				//$display("%d %d %d %d",distance[0],distance[1],distance[2],distance[3]); 
				if(x == 3 && y == 3) begin
					if(distance[0] == distance[1] || distance[0] == distance[2] || distance[0] == distance[3]) begin
						rand = {$random} % 2;
						if(rand) distance[0] = 6'b111111;  
					end
					if(distance[1] == distance[2] || distance[1] == distance[3]) begin
						rand = {$random} % 2;
						if(rand) distance[1] = 6'b111111;   
					end
					if(distance[2] == distance[3]) begin
						rand = {$random} % 2;
						if(rand) distance[2] = 6'b111111;   
					end
					next_state = MOVE;
				end else begin
				  next_state = READ_POS;
				  pcpi_ready = 1;
				end
			end

			MOVE : begin
				//$display("after random : %d %d %d %d",distance[0],distance[1],distance[2],distance[3]); 
				// hanlde special case 8 2 3 1 0 x 7 x x
				if(puzzle[0] == 8 && puzzle[1] == 2 && puzzle[2] == 3 && puzzle[3] == 1 && puzzle[4] == 0 && puzzle[6] == 7) begin 
					next_puzzle[zero_x*3 + zero_y - 1] = 0;
					next_puzzle[zero_x*3 + zero_y] = puzzle[zero_x*3 + zero_y - 1]; 
					zero_y = zero_y - 1;  
					last = 2'd1; 	
				end else if(distance[0] <= distance[1] && distance[0] <= distance[2] && distance[0] <= distance[3]) begin
					next_puzzle[zero_x*3 + zero_y + 1] = 0;
					next_puzzle[zero_x*3 + zero_y] = puzzle[zero_x*3 + zero_y + 1]; 
					zero_y = zero_y + 1;
					last = 2'd0;
				end else if(distance[1] <= distance[0] && distance[1] <= distance[2] && distance[1] <= distance[3]) begin
					next_puzzle[zero_x*3 + zero_y - 1] = 0;
					next_puzzle[zero_x*3 + zero_y] = puzzle[zero_x*3 + zero_y - 1]; 
					zero_y = zero_y - 1;  
					last = 2'd1; 
				end else if(distance[2] <= distance[0] && distance[2] <= distance[1] && distance[2] <= distance[3]) begin
					next_puzzle[(zero_x-1)*3 + zero_y] = 0;
					next_puzzle[zero_x*3 + zero_y] = puzzle[(zero_x-1)*3 + zero_y]; 
					zero_x = zero_x - 1;
					last = 2'd2; 
				end else if(distance[3] <= distance[0] && distance[3] <= distance[1] && distance[3] <= distance[2]) begin
					next_puzzle[(zero_x+1)*3 + zero_y] = 0;
					next_puzzle[zero_x*3 + zero_y] = puzzle[(zero_x+1)*3 + zero_y];  
					zero_x = zero_x + 1;
					last = 2'd3; 
				end	
				$display("---------\n");
				$display("%d %d %d\n",next_puzzle[0],next_puzzle[1],next_puzzle[2]);
				$display("%d %d %d\n",next_puzzle[3],next_puzzle[4],next_puzzle[5]);
				$display("%d %d %d\n",next_puzzle[6],next_puzzle[7],next_puzzle[8]);
				next_state = CHECK;
			end

			CHECK : begin
				for(i=0;i<4;i=i+1)
					distance[i] = 6'b111111;
				for(i=0;i<8;i=i+1) begin
				  if(puzzle[i] != i+1) done = 0;
				end
				if(puzzle[8] != 0) done = 0;
				next_state = READ_POS;
				pcpi_rd = done;
				pcpi_wr = 1;
				pcpi_wait = 0;
				pcpi_ready = 1;
			end

			PRINT : begin
				if(flag) begin
					$display("Initial Puzzle\n");
					$display("%d %d %d\n",puzzle[0],puzzle[1],puzzle[2]);
					$display("%d %d %d\n",puzzle[3],puzzle[4],puzzle[5]);
					$display("%d %d %d\n",puzzle[6],puzzle[7],puzzle[8]);
					flag = 0;
				end
				next_state = CHECK;
			end
		endcase
	end
	
endmodule
