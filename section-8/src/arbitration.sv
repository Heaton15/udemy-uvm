`include "uvm_macros.svh"
import uvm_pkg::*;

// Same transaction class we have been using

/*
* SEQ_ARB_FIFO (def) first in first out.. priority won't work
* SEQ_ARB_WEIGHTED: Weight is use for priority
* SEQ_ARB_RANDOM: Strictly random
* SEQ_ARB_STRICT_FIFO: support pri
* SEQ_ARB_STRICT_RANDOM: support pri
* SEQ_ARB_SUER
*/

class sequence_arbitration_0 extends uvm_sequence #(transaction);
  `uvm_object_utils(sequence_arbitration_0)

  transaction trans;

  function new(input string name = "sequence_arbitration_0");
    super.new(name);
  endfunction

  virtual task body();
    trans = transaction::type_id::create("trans");
    `uvm_info("sequence_arbitration_0", "sequence_arbitration_0 Started", UVM_NONE);
    start_item(trans);
    trans.randomize();
    finish_item(trans);
    `uvm_info("sequence_arbitration_0", "sequence_arbitration_0 Ended", UVM_NONE);
  endtask
endclass

class sequence_arbitration_1 extends uvm_sequence #(transaction);
  `uvm_object_utils(sequence_arbitration_1)

  transaction trans;

  function new(input string name = "sequence_arbitration_1");
    super.new(name);
  endfunction

  virtual task body();
    trans = transaction::type_id::create("trans");
    `uvm_info("sequence_arbitration_1", "sequence_arbitration_1 Started", UVM_NONE);
    start_item(trans);
    trans.randomize();
    finish_item(trans);
    `uvm_info("sequence_arbitration_1", "sequence_arbitration_1 Ended", UVM_NONE);
  endtask
endclass

// Notice how we pass the transaction class to the uvm_driver_arbitration now
class driver_arbitration extends uvm_driver #(transaction);
  `uvm_component_utils(driver_arbitration)

  transaction t;

  function new(input string name = "driver_arbitration", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    t = transaction::type_id::create("trans");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(t);
      seq_item_port.item_done();
    end
  endtask
endclass

class agent_arbitration extends uvm_agent;
  `uvm_component_utils(agent_arbitration)

  function new(input string name = "agent_arbitration", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  driver_arbitration d;
  uvm_sequencer #(transaction) seq;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d   = driver_arbitration::type_id::create("d", this);
    seq = uvm_sequencer#(transaction)::type_id::create("seq", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(seq.seq_item_export);
  endfunction
endclass

class env_arbitration extends uvm_env;
  `uvm_component_utils(env_arbitration)

  agent_arbitration a;

  function new(input string name = "env_arbitration", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent_arbitration::type_id::create("a", this);
  endfunction
endclass

class test_arbitration extends uvm_test;
  `uvm_component_utils(test_arbitration);

  function new(input string name = "test_arbitration", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  sequence_arbitration_0 s0;
  sequence_arbitration_1 s1;

  env_arbitration e;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e  = env_arbitration::type_id::create("e", this);
    s0 = sequence_arbitration_0::type_id::create("s0", this);
    s1 = sequence_arbitration_1::type_id::create("s1", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Commenting this out, but this should work...
    // for some reason it won't let me pass the set_arbitration() options
    e.a.seq.set_arbitration(SEQ_ARB_RANDOM);

    fork
      repeat (5)
        s0.start(e.a.seq, null, 100);  // sequencer, parent sequence, priority, call_pre_post
      repeat (5) s1.start(e.a.seq, null, 200);  // The combined threshold amount will become 300
      // Case 1: Threshold = 50, s0 will run first because 100 > 50
      // Case 2: Threshold = 250, s0 will not run, but s1 will not have 100
      // + 200 = 300 > 250 so it will run. 
    join

    phase.drop_objection(this);
  endtask
endclass
