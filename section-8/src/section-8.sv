`include "uvm_macros.svh"
import uvm_pkg::*;

// Section-8 will specifically focus on how the sequences are built up

module tb;
  initial run_test("test");
endmodule

module tb_flow_demo;
  adder_if aif ();

  initial begin
    uvm_config_db#(virtual adder_if)::set(null, "*", "aif", aif);
    run_test("test_flow_demo");
  end
endmodule

module tb_data_to_sequencer;
  initial begin
    run_test("test_data_to_sequencer");
  end
endmodule

/*
* 1. Covered sending sequence to driver with `uvm_do(tr)
* 2. Covered how sequence / sequencer / driver work with
*   - create_item
*   - wait_for_grant
*   - assert(tr.randomize)
*   - send_request
*   - wait_for_item.done
*
* 3. Now, we want to look at option 3 with start_item / finish_item.
*
* Option 1 is difficult to use when you want to add corrupt data on purpose. 
* Option 3 is verbose and has a lot of overhead to get something simple
*
* Option 2 is more abstract from 3 and more flexible than 1
*
*
*
* Option 3
*   - create
*   - start_item(tr)
*   - assert(tr.randomize)
*   - finish_item(tr)
*/

module tb_data_to_driver_p2;
  initial begin
    run_test("test_data_to_driver_p2");
  end
endmodule


module tb_parallel;
  initial begin
    run_test("test_parallel");
  end
endmodule

module tb_arbitration;
  initial begin
    run_test("test_arbitration");
  end
endmodule
