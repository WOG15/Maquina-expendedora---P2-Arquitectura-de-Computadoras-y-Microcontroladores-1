`timescale 1ns / 1ps

module top(
    input  logic CLK100MHZ,
    input  logic reset,
    input  logic M1,
    input  logic M2,
    input  logic SEL1,
    input  logic SEL0,
    output logic A_mealy,
    output logic B_mealy,
    output logic C_mealy,
    output logic A_moore,
    output logic B_moore,
    output logic C_moore
);

    // FSM Mealy
    mealy fsm_mealy (
        .clk   (CLK100MHZ),
        .reset (reset),
        .M1    (M1),
        .M2    (M2),
        .SEL1  (SEL1),
        .SEL0  (SEL0),
        .A     (A_mealy),
        .B     (B_mealy),
        .C     (C_mealy)
    );

    // FSM Moore
    moore fsm_moore (
        .clk   (CLK100MHZ),
        .reset (reset),
        .M1    (M1),
        .M2    (M2),
        .SEL1  (SEL1),
        .SEL0  (SEL0),
        .A     (A_moore),
        .B     (B_moore),
        .C     (C_moore)
    );

endmodule
