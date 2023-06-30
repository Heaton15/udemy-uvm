`include "uvm_macros.svh"
import uvm_pkg::*;

/* In this section, we will be looking at how to share resources with the
* config_db with set / get methods
*/

module tb_configdb1;
  initial begin
    run_test("test");
  end
endmodule

module tb_demo1;
  int data = 256;

  initial begin
    uvm_config_db#(int)::set(null, "uvm_test_top", "data", data);
    run_test("test_demo1"); // Remember to use a string for the name
  end
endmodule
