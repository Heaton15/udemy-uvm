`include "uvm_macros.svh"
import uvm_pkg::*;


// Let's start by looking at how to extend the components

class comp extends uvm_component;
  // When registering your class to the factory, the config_db will be updated
  `uvm_component_utils(comp)


  function new(string path = "comp", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  // Before, during, and after simulation we have phases
  // Only will look at some small phases here for a small understanding

  /* build_phase: Before simulation */
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(
        phase);  // Have to call the uvm_component parent and pass it the uvm_phase object
    `uvm_info("COMP", "Build Phase of comp execute", UVM_NONE);
  endfunction
endclass

class a extends uvm_component;
  `uvm_component_utils(a)

  function new(string path = "a", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("a", "Build Phase of a executed", UVM_NONE);
  endfunction
endclass

class b extends uvm_component;
  `uvm_component_utils(b)

  function new(string path = "b", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("b", "Build Phase of b executed", UVM_NONE);
  endfunction
endclass

class c extends uvm_component;
  a a_inst;
  b b_inst;

  `uvm_component_utils(c)

  function new(string path = "c", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a_inst = a::type_id::create("a_inst", this);
    b_inst = b::type_id::create("b_inst", this);
    //a_inst.build_phase(null); -> do not do it this way
    //b_inst.build_phase(null); -> do not do it this way
  endfunction

  // We can also look at the hierarchy
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass
