`include "uvm_macros.svh"
import uvm_pkg::*;

// Notice that the uvm_sequence#(T), T = type
class sequence3 extends uvm_sequence #(transaction);
  `uvm_object_utils(sequence3)

  transaction trans;

  function new(input string name = "sequence3");
    super.new(name);
  endfunction


  virtual task body();
    repeat (5) begin;
      trans = transaction::type_id::create("trans");
      start_item(trans);
      assert(trans.randomize);
      finish_item(trans);
      `uvm_info("SEQ", $sformatf("a: %0d, b: %0d", trans.a, trans.b), UVM_NONE);
    end
  endtask
endclass

class test_data_to_driver_p2 extends uvm_test;
  `uvm_component_utils(test_data_to_driver_p2);

  function new(input string name = "test_data_to_driver_p2", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  sequence3 s1;

  env2 e;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e  = env2::type_id::create("e", this);
    s1 = sequence3::type_id::create("s1", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Between the objections, we start the sequencer
    // sequencer is activated from the test_data_to_sequencer
    s1.start(e.a.seq);

    phase.drop_objection(this);
  endtask
endclass
