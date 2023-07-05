`include "uvm_macros.svh"
import uvm_pkg::*;

// Section-8 will specifically focus on how the sequences are built up

module tb;
  initial run_test("test");
endmodule

module tb_flow_demo;
  adder_if aif();

  initial begin
    uvm_config_db #(virtual adder_if)::set(null, "*", "aif", aif);
    run_test("test_flow_demo");
  end
endmodule
