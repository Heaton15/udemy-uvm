`include "uvm_macros.svh"
import uvm_pkg::*;
/*
*************************************************
*******This section will cover uvm_object********
*************************************************

uvm_object and uvm_component are the 2 base classes which everything is built
out of 

Driver, Scoreboard, Monitor will always be present for an entire simulation time (static components)
Transaction have a life time where they cause a pass or fail (dynamic components)

There are pre-defined classes which are derived from uvm_object and
uvm_component that users use

dynamic components -> uvm_object
- uvm_sequence_item

static components -> uvm_component
- uvm_driver

Note that a uvm_component is derived from uvm_objects
uvm_tree can be made with a uvm_component but not uvm_object

phases in UVM only exist for uvm_component. Phases cannot exist for uvm_objects


uvm_object                      ----              uvm_component




Used to interact with dynamic components 
Transaction object spans independemtn of time and included print, compare,
create object, etc

uvm_object have a set of methods known as core methods
uvm_object
 - uvm_transaction
 - uvm_sequence_item
 - uvm_sequence



Used to build the static environment
uvm_component
 - uvm_driver
 - uvm_sequencer
 - uvm_monitor
 - uvm_agent 
 - uvm_scoreboard
 - uvm_env
 - uvm_test

Core Methods (Field Macros for uvm_object)
  - print
  - record
  - copy
  - compare
  - create
  - clone
  - pack / unpack

The core methods expand into general inline code that is not as run-time efficient nor as flexible as 
direct implementations of the do_* methods.

// They are basically abstract methods you have to create yourself
You could make user defined do_* methods to do similar things
  - do_print
  - do_record
  - do_copy
  - do_compare
  - do_pack / do_unpack

Using these requires you to specify how they will work
  
// There are 2 ways to access Core Methods 
// 1. Field Macros, call method but don't have to define implementation
// 2. do_* methods and don't have to register data member with a field macor but
// must define implementation

// We will learn how to build the uvm_object classes and the field macros / do methods
*/

module tb;
  first f;
  initial begin
    f = new();
    f.randomize(); // randomize all rand items
    $display("Value of data: %0d", f.data);
  end
endmodule

module tb_obj;
  obj o;

  initial begin
    o = new("obj");
    o.randomize();
    `uvm_info("TB_TOP", $sformatf("a: %0d", o.a), UVM_NONE);
  end

endmodule
