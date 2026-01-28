
module lift_controller(
input clk,reset,
input [3:0] floor_req,
input emergency_stop,
output reg c_up,c_down,motor_stop,
output reg [1:0] current_floor);
  
  parameter idle = 2'b00;
  parameter move_up = 2'b01;
  parameter move_down = 2'b10;
  parameter emergency = 2'b11;
  
  reg [1:0] current_state,next_state;
  
  reg [1:0] target_floor;
  
  //priority logic
  
  always@(*)
    	begin
          target_floor = current_floor;
          
          if(floor_req[0])
            	target_floor = 2'd0;
          else if(floor_req[1])
            target_floor = 2'd1;
          else if(floor_req[2])
            	target_floor = 2'd2;
          else if(floor_req[3])
            	target_floor = 2'd3;
        end
  
  //present_state_logic
  
  always@(posedge clk)
    	begin
          if(reset)
            	current_state <= idle;
       else
         	current_state <= next_state;
        end
  
  //floor tracking logic
  
  always@(posedge clk or posedge reset) begin
    if(reset)
      	current_floor <= 2'd0;
  	else
      if(current_state == move_up)
        	current_floor <= current_floor + 1'b1;
  	else
      if(current_state == move_down)
        	current_floor <= current_floor - 1'b1;
  
  end
  
  //next state logic
  
  always@(*)
    	begin
          	next_state = current_state;
          
          if(emergency_stop)	
            	begin
                  	next_state = emergency;
                end
          else
            	begin
                  case(current_state)
                    	idle : 
                          begin
                            if(target_floor > current_floor)
                              	next_state = move_up;
                            else if(target_floor < current_floor)
                              next_state = move_down;
                            
                            
                          end
                    
                    
                    	move_up : begin
                          if(current_floor == target_floor)
                            	next_state = idle;
                          else 
                            	next_state = move_up;
                          
                        end
                    
                    
                    	move_down : begin
                          if(current_floor == target_floor)
                            	next_state  = idle;
                          else
                            	next_state = move_down;
                        end
                    
                    	emergency : begin
                          	
                          if(!emergency_stop)
                            	next_state = idle;
                          else
                            	next_state = emergency;
                          
                        end
                    
                    default : next_state = idle;
                    
                  endcase
                end
        end
  
  //output logic :
  
  always@(*)
    	begin
          	c_up = 1'b0;
          	c_down = 1'b0;
          	motor_stop = 1'b0;
          
          
          case(current_state)
            	move_up : c_up = 1'b1;
            	move_down : c_down = 1'b1;
            	emergency : motor_stop = 1'b1;
            	idle : motor_stop = 1'b1;
          endcase
          
        end
endmodule

/* motor stop working weird check 
4 in floor_request means 0100 == 2nd floor
01100 = 2nd and 3rd floor == acc to priority logic 2nd floor will only be selected 

future scope ======
 1. develop registers which can take in multiple floor requests at a time and work on basis of direction along with priority logic 
 */


