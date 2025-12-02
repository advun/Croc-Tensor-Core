`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 01:30:12 AM
// Design Name: 
// Module Name: state_machine
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module state_machine(
    input wire [31:0] inA, 
    input wire [31:0] inB,
    input wire signed [16:0] size,
    input wire reset,
    input wire clk,
    input wire start,
    output wire push11,
    output wire pushedge,
    output wire push22,
    output wire valid, //entire operation is done
    output wire signed [7:0] a1X, 
    output wire signed [7:0] a2X,
    output wire signed [7:0] bX1,
    output wire signed [7:0] bX2
    );

    //inA and inB are written to in alternating clock cycles (inA, inB, inA, etc
    
    reg [7:0] hold_a1X [2:0];
    reg [7:0] hold_a2X [3:0];  
    reg [7:0] hold_bX1 [1:0];  
    reg [7:0] hold_bX2 [2:0];   
    logic AnB;  //True if A, False if B
    logic [16:0] step; //which partial product. 17 bits to allow for max size matrix 32 bit outputs allows us to guarentee no overflow (131071x131071)
    //131071/2 (in 2x2 matrixes) = 65535.5.  Max (in 2x2 matrixes) is 65535.5x65535.5 = 4294901760 2x2 matrixes, thus 4294901760 iterations -> 32 bits
    logic [31:0] iter; //which 2x2 matrix it is on.
    logic shiftenable;
    assign shiftenable = ((state == RUN)|(state == PUSH11)|(state == PUSHEDGE)|(state == PUSH22)); //only shift if in certain states

    //Shift Reg Logic
    always_ff @ (posedge clk) begin
        if (reset) begin
            foreach (hold_a1X[i]) hold_a1X[i] <= 8'd0;
            foreach (hold_a2X[i]) hold_a2X[i] <= 8'd0;
            foreach (hold_bX1[i]) hold_bX1[i] <= 8'd0;
            foreach (hold_bX2[i]) hold_bX2[i] <= 8'd0;
            AnB <= 1'b1; //start with A true
        end

        else if (shiftenable) begin
            if (AnB) begin //If inA is being written in this cycle
                //Bring in inA values to shift registers, shift older values through other regs as normal
                hold_a1X[0] <= inA[31:24]; //11
                hold_a1X[1] <= inA[23:16];//12
                hold_a1X[2] <= hold_a1X[1];
                
                hold_a2X[0] <= inA[15:8];//21
                hold_a2X[1] <= inA[7:0];//22
                hold_a2X[2] <= hold_a2X[1];
                hold_a2X[3] <= hold_a2X[2];
    
                //Shift B values
                hold_bX1[1] <= hold_bX1[0];
    
                hold_bX2[1] <= hold_bX2[0];
                hold_bX2[2] <= hold_bX2[1];
                
                AnB <= ~AnB;
            end  
    
            else if (~AnB) begin //If inB is being written in this cycle
                //shift A values
                hold_a1X[1] <= hold_a1X[0];
                hold_a1X[2] <= hold_a1X[1];
                
                hold_a2X[1] <= hold_a1X[0];
                hold_a2X[2] <= hold_a1X[1];
                hold_a2X[3] <= hold_a1X[2];
                
                //Bring in inB values to shift registers, shift older values through other regs as normal
                hold_bX1[0] <= inB[31:24]; //11
                hold_bX1[1] <= inB[15:8];//21
                
                hold_bX2[0] <= inB[23:16];//12
                hold_bX2[1] <= inB[7:0];//22
                hold_bX2[2] <= hold_bX2[1];
                
                AnB <= ~AnB;
            end 
        end
    end

    //========OUTPUTS FOR SHIFT REGS===========
    assign a1X = hold_a1X[2];
    assign a2X = hold_a2X[3];
    assign bX1 = hold_bX1[1];
    assign bX2 = hold_bX2[2];
    //=========================================
    
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end


        // FSM states
    typedef enum logic [2:0] {
        IDLE = 3'd0,
        RUN  = 3'd1,
        PUSH11 = 3'd2,
        PUSHEDGE = 3'd3,
        PUSH22 = 3'd4,
        DONE = 3'd5
    } state_t;
    
    state_t state, next_state;

    
    //next_state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = RUN;
                end
            end
            
            RUN: begin
                if (step >= (size-3))
                    next_state = PUSH11;
            end

            PUSH11: begin
                next_state = PUSHEDGE;
            end

            PUSHEDGE: begin
                next_state = PUSH22;
            end

            PUSH22: begin
                if (iter <= (size/2)*(size/2)) //if iter is greater than/equal to the square of 1/2 the size, it's finished
                    next_state = DONE;
                else
                    next_state = RUN;
            end
            
            DONE: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end


    //state machine
    always_ff @ (posedge clk) begin
        if (reset) begin
            iter <= 0;
            step <= 0;
            shiftenable <= 0;
        end

        else begin
            case (state)
                IDLE: begin
                    iter <= 0;
                    step <= 0;
                end

                RUN: begin
                    step <= step + 1;
                end

                PUSH11: begin
                    iter <= iter + 1; //iteration goes up 1
                    step <= 0; //reset step for next iteration
                end

                PUSHEDGE: begin
                end

                PUSH22: begin
                end

                DONE: begin
                end
                
            endcase
        end
    end


    //========OUTPUTS FOR PUSHES===========
    assign push11 = (state == PUSH11); //change to next_state if giving issues
    assign pushedge = (state == PUSHEDGE);
    assign push22 = (state == PUSH22);
    assign valid = (state == DONE);
    //=====================================
    
endmodule
