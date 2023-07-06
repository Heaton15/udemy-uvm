`include "uvm_macros.svh"
import uvm_pkg::*;

// Notice that the uvm_sequence#(T), T = type
class sequence2 extends uvm_sequence #(transaction);
  `uvm_object_utils(sequence2)

  transaction trans;

  function new(input string name = "sequence2");
    super.new(name);
  endfunction

  virtual task body();
    repeat (5) begin
      // The `uvm_do macro takes a uvm_sequence_item
      // Its purpose is to create the object, randomize it, and then send it to
      // a sequencer. All of the stuff we saw in the understanding_flow.sv file
      // is completed with this macro then. 
      `uvm_do(trans);
      #10;
    end
  endtask
endclass

// Notice how we pass the transaction class to the uvm_driver2 now
class driver2 extends uvm_driver #(transaction);
  `uvm_component_utils(driver2)

  transaction t;

  function new(input string name = "driver2", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    t = transaction::type_id::create("t");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(t);
      // This will print all of the values
      t.print(uvm_default_line_printer);
      // Send ack to the sequencer 
      seq_item_port.item_done();
    end
  endtask
endclass

class agent2 extends uvm_agent;
  `uvm_component_utils(agent2)

  function new(input string name = "agent2", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  driver2 d;
  uvm_sequencer #(transaction) seq;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d   = driver2::type_id::create("d", this);
    seq = uvm_sequencer#(transaction)::type_id::create("seq", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // We connect the port of the driver2 to the export of the sequencer
    d.seq_item_port.connect(seq.seq_item_export);
  endfunction
endclass

class env2 extends uvm_env;
  `uvm_component_utils(env2)

  agent2 a;

  function new(input string name = "env2", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent2::type_id::create("a", this);
  endfunction
endclass

class test_data_to_sequencer extends uvm_test;
  `uvm_component_utils(test_data_to_sequencer);

  function new(input string name = "test_data_to_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  sequence2 s1;

  env2 e;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e  = env2::type_id::create("e", this);
    s1 = sequence2::type_id::create("s1", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Between the objections, we start the sequencer
    // sequencer is activated from the test_data_to_sequencer
    s1.start(e.a.seq);

    phase.drop_objection(this);
  endtask
endclass
