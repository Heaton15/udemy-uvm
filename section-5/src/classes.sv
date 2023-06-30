`include "uvm_macros.svh"
import uvm_pkg::*;

/* What is very important here for the ::get and ::set methods is that the 
* "uvm_test_top" and "data" instance name / key are the same between the
* 2 methods.
* 
* This is what links the get/set methods together.
*/

class env extends uvm_env;
  `uvm_component_utils(env)

  int data;

  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // context -> null or this
    // instance name -> string name
    // key -> Actual data name
    // value -> the object of the data type
    // You can even do wild cards with the "uvm_test_top", like "top.*.module"
    // or something along those lines
    if (uvm_config_db#(int)::get(null, "uvm_test_top", "data", data))
      `uvm_info("ENV", $sformatf("Value of data : %0d", data), UVM_NONE)
    else
      `uvm_error("ENV", "Unable to access the Value");

  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)


  env e_inst;

  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e_inst = env::type_id::create("e_inst", this);

    // This how to access things
    // set(context, instance name, key, value)

    // context -> null or this (null means anything can touch it, this is only
    //            this class can touch it)

    // instance name -> string name 

    // value -> What you are updating the value to be
    uvm_config_db#(int)::set(null, "uvm_test_top", "data", 12);
  endfunction
endclass

