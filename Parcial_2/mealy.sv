`timescale 1ns / 1ps

module mealy(
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

    typedef enum logic [1:0] {
        S0 = 2'b00,
        S1 = 2'b01,
        S2 = 2'b10,
        S3 = 2'b11
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
                    default: nextstate = S0;
                endcase
            end

            S1: begin
                case ({M1, M2})
                    2'b00: nextstate = S1;
                    2'b10: nextstate = S2;
                    2'b01: nextstate = S3;
                    default: nextstate = S1;
                endcase
            end

            S2: begin
                case ({M1, M2})
                    2'b00: nextstate = S2;
                    2'b10: nextstate = S3;
                    2'b01: nextstate = S3;
                    default: nextstate = S2;
                endcase
            end

            S3: begin
                case ({SEL1, SEL0})
                    2'b00: nextstate = S3;
                    2'b01: nextstate = S0;
                    2'b10: nextstate = S0;
                    2'b11: nextstate = S0;
                endcase
            end

            default: nextstate = S0;
        endcase
    end

    // Mealy outputs (dependen del estado actual y selector)
    always_comb begin
        A = 1'b0;
        B = 1'b0;
        C = 1'b0;

        if (state == S3) begin
            case ({SEL1, SEL0})
                2'b01: A = 1'b1;
                2'b10: B = 1'b1;
                2'b11: C = 1'b1;
                default: begin
                    A = 1'b0;
                    B = 1'b0;
                    C = 1'b0;
                end
            endcase
        end
    end

endmodule
