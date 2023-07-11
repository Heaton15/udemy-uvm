`include "uvm_macros.svh"

import uvm_pkg::*;

module adder (  /*AUTOARG*/
    // Outputs
    y,
    // Inputs
    a,
    b
);
  input [3:0] a, b;
  output [4:0] y;
  assign y = a + b;
endmodule

interface adder_if ();
  logic [3:0] a;
  logic [3:0] b;
  logic [4:0] y;
endinterface


module adder_tb;

  adder_if aif ();

  // For the Verilog AUTOs, just remember that the regex groups are references
  // with \1, \2, etc. So if you grab all signals names with .\(.*\), then you
  // can reference the signal with \1

  /* adder AUTO_TEMPLATE (
    .\(.*\) (aif.\1[])); */

  adder dut_aif (  /*AUTOINST*/
      // Outputs
      .y(aif.y[4:0]),  // Templated
      // Inputs
      .a(aif.a[3:0]),  // Templated
      .b(aif.b[3:0])
  );  // Templated

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  initial begin
    uvm_config_db#(virtual adder_if)::set(null, "uvm_test_top.e.a*", "aif", aif);
    run_test("test");
  end

endmodule
