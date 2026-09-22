`timescale 1ns / 1ps

module moore(
    input  logic clk,
    input  logic reset,
    input  logic M1,
    input  logic M2,
    input  logic SEL1,
    input  logic SEL0,
    output logic A,
    output logic B,
    output logic C
);

    typedef enum logic [2:0] {
        S0 = 3'b000,
        S1 = 3'b001,
        S2 = 3'b010,
        S3 = 3'b011,
        S4 = 3'b100,
        S5 = 3'b101,
        S6 = 3'b110
    } statetype;

    statetype state, nextstate;

    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            state <= S0;
        else
            state <= nextstate;
    end

    // Next-state logic
    always_comb begin
        nextstate = state;

        case (state)
            S0: begin
                case ({M1, M2})
                    2'b00: nextstate = S0;
                    2'b10: nextstate = S1;
                    2'b01: nextstate = S2;
                    default: nextstate = S0; // Default por si M1=M2=1 
                endcase
            end

            S1: begin
                case ({M1, M2})
                    2'b00: nextstate = S1;
                    2'b10: nextstate = S2;
                    2'b01: begin
                        case ({SEL1, SEL0})
                            2'b00: nextstate = S3;
                            2'b01: nextstate = S4;
                            2'b10: nextstate = S5;
                            2'b11: nextstate = S6;
                        endcase
                    end
                    default: nextstate = S1;
                endcase
            end

            S2: begin
                case ({M1, M2})
                    2'b00: nextstate = S2;
                    2'b10, 2'b01: begin
                        case ({SEL1, SEL0})
                            2'b00: nextstate = S3;
                            2'b01: nextstate = S4;
                            2'b10: nextstate = S5;
                            2'b11: nextstate = S6;
                        endcase
                    end
                    default: nextstate = S2;
                endcase
            end

            S3: begin
                case ({SEL1, SEL0})
                    2'b00: nextstate = S3;
                    2'b01: nextstate = S4;
                    2'b10: nextstate = S5;
                    2'b11: nextstate = S6;
                endcase
            end

            S4: nextstate = S0;
            S5: nextstate = S0;
            S6: nextstate = S0;

            default: nextstate = S0;
        endcase
    end

    // Moore outputs(depende solo del estado actual)
    always_comb begin
        A = 1'b0;
        B = 1'b0;
        C = 1'b0;

        case (state)
            S4: A = 1'b1;
            S5: B = 1'b1;
            S6: C = 1'b1;
            default: begin
                A = 1'b0;
                B = 1'b0;
                C = 1'b0;
            end
        endcase
    end

endmodule
