`timescale 1ns / 1ps

module testbench;

    logic clk;
    logic reset;

    logic M1, M2;
    logic SEL1, SEL0;

    logic A_mealy, B_mealy, C_mealy;
    logic A_moore, B_moore, C_moore;

    integer errores = 0;


    top dut (
        .CLK100MHZ (clk),
        .reset     (reset),

        .M1        (M1),
        .M2        (M2),

        .SEL1      (SEL1),
        .SEL0      (SEL0),

        .A_mealy   (A_mealy),
        .B_mealy   (B_mealy),
        .C_mealy   (C_mealy),

        .A_moore   (A_moore),
        .B_moore   (B_moore),
        .C_moore   (C_moore)
    );


    // CLOCK
    // 100 MHz -> periodo de 10 ns

    initial begin
        clk = 1'b0;
    end

    always #5 clk = ~clk;


    // TESTS

    initial begin

        // VALORES INICIALES

        reset = 1'b1;

        M1 = 1'b0;
        M2 = 1'b0;

        SEL1 = 1'b0;
        SEL0 = 1'b0;

        #12;

        reset = 1'b0;


        // TEST 1
        //
        // S0 --M1--> S1
        // S1 --M2--> credito suficiente
        // Seleccion = 01
        // Producto esperado = A

        $display("");
        $display("========================================");
        $display("TEST 1 - PRODUCTO A");
        $display("========================================");


        // S0 -> S1
        @(negedge clk);

        M1 = 1'b1;
        M2 = 1'b0;


        // S1 -> estado de seleccion
        // seleccionamos A = 01
        @(negedge clk);

        M1 = 1'b0;
        M2 = 1'b1;

        SEL1 = 1'b0;
        SEL0 = 1'b1;


        // Esperamos el flanco para que Moore actualice estado
        @(posedge clk);
        #1;


        // COMPROBAR MEALY

        if (
            A_mealy === 1'b1 &&
            B_mealy === 1'b0 &&
            C_mealy === 1'b0
        )
            $display("PASS: Mealy dispenso producto A");

        else begin

            $error(
                "FAIL: Mealy producto A. Salidas = %b%b%b",
                A_mealy,
                B_mealy,
                C_mealy
            );

            errores = errores + 1;

        end


        // COMPROBAR MOORE

        if (
            A_moore === 1'b1 &&
            B_moore === 1'b0 &&
            C_moore === 1'b0
        )
            $display("PASS: Moore dispenso producto A");

        else begin

            $error(
                "FAIL: Moore producto A. Salidas = %b%b%b",
                A_moore,
                B_moore,
                C_moore
            );

            errores = errores + 1;

        end


        // Limpiar entradas
        @(negedge clk);

        M1 = 1'b0;
        M2 = 1'b0;

        SEL1 = 1'b0;
        SEL0 = 1'b0;



        // RESET ENTRE TESTS

        reset = 1'b1;

        #10;

        reset = 1'b0;



        // TEST 2
        //
        // S0 --M2--> S2
        // S2 --M1--> credito suficiente
        // Seleccion = 10
        // Producto esperado = B

        $display("");
        $display("========================================");
        $display("TEST 2 - PRODUCTO B");
        $display("========================================");


        // S0 -> S2
        @(negedge clk);

        M1 = 1'b0;
        M2 = 1'b1;


        // S2 -> estado de seleccion
        // seleccionamos B = 10
        @(negedge clk);

        M1 = 1'b1;
        M2 = 1'b0;

        SEL1 = 1'b1;
        SEL0 = 1'b0;


        @(posedge clk);
        #1;


        // COMPROBAR MEALY

        if (
            A_mealy === 1'b0 &&
            B_mealy === 1'b1 &&
            C_mealy === 1'b0
        )
            $display("PASS: Mealy dispenso producto B");

        else begin

            $error(
                "FAIL: Mealy producto B. Salidas = %b%b%b",
                A_mealy,
                B_mealy,
                C_mealy
            );

            errores = errores + 1;

        end


        // COMPROBAR MOORE

        if (
            A_moore === 1'b0 &&
            B_moore === 1'b1 &&
            C_moore === 1'b0
        )
            $display("PASS: Moore dispenso producto B");

        else begin

            $error(
                "FAIL: Moore producto B. Salidas = %b%b%b",
                A_moore,
                B_moore,
                C_moore
            );

            errores = errores + 1;

        end


        // Limpiar entradas
        @(negedge clk);

        M1 = 1'b0;
        M2 = 1'b0;

        SEL1 = 1'b0;
        SEL0 = 1'b0;



        // RESET ENTRE TESTS

        reset = 1'b1;

        #10;

        reset = 1'b0;



        // TEST 3
        //
        // Llegar al estado de seleccion
        // Seleccion = 11
        // Producto esperado = C
        //
        // Aqui comprobamos Mealy ANTES del flanco
        // y Moore DESPUES del flanco.

        $display("");
        $display("========================================");
        $display("TEST 3 - PRODUCTO C");
        $display("========================================");


        // S0 -> S1
        @(negedge clk);

        M1 = 1'b1;
        M2 = 1'b0;


        // S1 -> S3
        // Todavia no seleccionar producto
        @(negedge clk); //(Espera hasta el siguiente flanco de bajada para continuar)

        M1 = 1'b0;
        M2 = 1'b1;

        SEL1 = 1'b0;
        SEL0 = 1'b0;


        // Esperar a que se actualice el estado a S3
        @(posedge clk);
        #1; // Espera una unidad de tiempo


        // En el siguiente negedge colocamos selector 11
        @(negedge clk);

        M1 = 1'b0;
        M2 = 1'b0;

        SEL1 = 1'b1;
        SEL0 = 1'b1;


        // MEALY
        //
        // La salida depende del estado ACTUAL + entradas.
        // Como ya estamos en S3 y SEL = 11,
        // C debe activarse inmediatamente.

        #1;

        if (
            A_mealy === 1'b0 &&
            B_mealy === 1'b0 &&
            C_mealy === 1'b1
        )
            $display("PASS: Mealy dispenso producto C");

        else begin

            $error(
                "FAIL: Mealy producto C. Salidas = %b%b%b",
                A_mealy,
                B_mealy,
                C_mealy
            );

            errores = errores + 1;

        end


        // MOORE
        //
        // Necesita el siguiente flanco para cambiar de
        // S3 -> S6.

        @(posedge clk);
        #1;


        if (
            A_moore === 1'b0 &&
            B_moore === 1'b0 &&
            C_moore === 1'b1
        )
            $display("PASS: Moore dispenso producto C");

        else begin

            $error(
                "FAIL: Moore producto C. Salidas = %b%b%b",
                A_moore,
                B_moore,
                C_moore
            );

            errores = errores + 1;

        end


        // Limpiar selector
        @(negedge clk);

        SEL1 = 1'b0;
        SEL0 = 1'b0;



        // RESULTADO

        #20;

        $display("");
        $display("========================================");

        if (errores == 0) begin

            $display(
                "TODAS LAS PRUEBAS PASARON CORRECTAMENTE"
            );

        end

        else begin

            $display(
                "PRUEBAS FINALIZADAS CON %0d ERROR(ES)",
                errores
            );

        end

        $display("========================================");
        $display("");


        $finish;

    end

endmodule