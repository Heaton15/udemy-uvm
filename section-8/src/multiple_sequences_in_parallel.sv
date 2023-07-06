`include "uvm_macros.svh"
import uvm_pkg::*;

// Same transaction class we have been using

class sequence_parallel_0 extends uvm_sequence #(transaction);
  `uvm_object_utils(sequence_parallel_0)

  transaction trans;

  function new(input string name = "sequence_parallel_0");
    super.new(name);
  endfunction

  virtual task body();
    trans = transaction::type_id::create("trans");
    `uvm_info("sequence_parallel_0", "sequence_parallel_0 Started", UVM_NONE);
    start_item(trans);
    trans.randomize();
    finish_item(trans);
    `uvm_info("sequence_parallel_0", "sequence_parallel_0 Ended", UVM_NONE);
  endtask
endclass

class sequence_parallel_1 extends uvm_sequence #(transaction);
  `uvm_object_utils(sequence_parallel_1)

  transaction trans;

  function new(input string name = "sequence_parallel_1");
    super.new(name);
  endfunction

  virtual task body();
    trans = transaction::type_id::create("trans");
    `uvm_info("sequence_parallel_1", "sequence_parallel_1 Started", UVM_NONE);
    start_item(trans);
    trans.randomize();
    finish_item(trans);
    `uvm_info("sequence_parallel_1", "sequence_parallel_1 Ended", UVM_NONE);
  endtask
endclass

// Notice how we pass the transaction class to the uvm_driver_parallel now
class driver_parallel extends uvm_driver #(transaction);
  `uvm_component_utils(driver_parallel)

  transaction t;

  function new(input string name = "driver_parallel", uvm_component parent = null);
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

class agent_parallel extends uvm_agent;
  `uvm_component_utils(agent_parallel)

  function new(input string name = "agent_parallel", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  driver_parallel d;
  uvm_sequencer #(transaction) seq;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d   = driver_parallel::type_id::create("d", this);
    seq = uvm_sequencer#(transaction)::type_id::create("seq", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(seq.seq_item_export);
  endfunction
endclass

class env_parallel extends uvm_env;
  `uvm_component_utils(env_parallel)

  agent_parallel a;

  function new(input string name = "env_parallel", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent_parallel::type_id::create("a", this);
  endfunction
endclass

class test_parallel extends uvm_test;
  `uvm_component_utils(test_parallel);

  function new(input string name = "test_parallel", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  sequence_parallel_0 s0;
  sequence_parallel_1 s1;

  env_parallel e;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e  = env_parallel::type_id::create("e", this);
    s0 = sequence_parallel_0::type_id::create("s0", this);
    s1 = sequence_parallel_1::type_id::create("s1", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // e.a.seq.set_arbitration(UVM_SEQ_ARB_STRICT_RANDOM);

    // The fork join will allow us to run them in parallel and wait for both to
    // be done before moving forward

    // Since we do not specify the arbitration directly in this case, we get
    // a FIFO scheme which is first in first out. == UVM_SEQ_ARB_FIFO
    fork
      s0.start(e.a.seq);
      s1.start(e.a.seq);
    join


    phase.drop_objection(this);
  endtask
endclass
