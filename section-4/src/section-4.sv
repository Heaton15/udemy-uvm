`include "uvm_macros.svh"
import uvm_pkg::*;

/* static components exist for the entire time of the simulation
*   - driver
*   - monitor
*   - scoreboard
*   - agent
*   - env
*
* When referring to static components, we start dealing with uvm_trees.
* These can be used to debug the verification environment.
*
*/


/* Test Structure
*
* - uvm_top -> Root of the entire tree
* - test (root component)
*   - env (leaf)
*     - scoreboard (comparisons)
*     - agent 
*       - monitor
*       - driver
*       - sequencer
* 
*
*
* uvm_test -> child, uvm_top -> parent
*
*/

module tb_comp;
  //comp c;
  //initial begin
  //  c = comp::type_id::create("c", null); // -> This becomes a child to uvm_top bc of null
  //  c.build_phase(null); // No uvm_phase
  //end

  initial begin
    run_test("comp");  // automatically execute comp class. Automatically creates the constructor
  end
endmodule


// Look into how to create a hierarchy of components
// uvm_root
//  - c
//    - a
//    - b
// For this example we will create the above UVM tree

module tb_uvmtree1;
  initial begin
    run_test("c");
  end
endmodule

module tb_uvmtree2;
  c c_inst;

  // We do not need to create a instance of uvm test top, so do not do it this
  // way
  initial begin
    c_inst = c::type_id::create("c_inst", null); //Recall null makes child of root
    c_inst.build_phase(null);
  end
endmodule


