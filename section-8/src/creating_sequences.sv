`include "uvm_macros.svh"
import uvm_pkg::*;
/*
* We can see a special port is used to transmit transactions from a sequencer to
* a driver. The contents of the TLM is a sequence that we can put together.
*
* Arbitration
* Lock / Unlock
* Grab / Ungrab 
*
*
* A sequence is where we add all possible combinations of the input signals
*   - It is a class which gives us the ability to test a combination of inputs,
*     and they are applied to the DUT. 
*
* A sequencer handles the event of sending a sequence to the driver over the
* port / export (TLM) setup. We like to simplify the verification environment by
* having an independent sequence for each test case. We like to simplify the
* verification environment by having an independent sequence for each test case. 
*
* In UVM, everything is handled by a library, so a lot of the sequnce building
* is boilerplate code. The sequencer is the only class we do not need our
* implementation for.  
* 
* A transaction is defined and built into a sequence that is sent to
* a sequencer. The sequencer then sends the stimulus to the Driver which sends
* the data over an interface to the DUT. 
*
* The output of the DUT then goes to the Monitor / Scoreboard where we can find
* out if we pass. 
*
*/

// Note that a uvm_sequence_item is an object
class transaction extends uvm_sequence_item;
  rand bit [3:0] a;
  rand bit [3:0] b;
  bit [4:0] y;

  function new(input string name = "transaction");
    super.new(name);
  endfunction

  `uvm_object_utils_begin(transaction)
    `uvm_field_int(a, UVM_DEFAULT)
    `uvm_field_int(b, UVM_DEFAULT)
    `uvm_field_int(y, UVM_DEFAULT)
  `uvm_object_utils_end
endclass

// Notice that the uvm_sequence#(T), T = type
class sequence1 extends uvm_sequence #(transaction);
  `uvm_object_utils(sequence1)

  function new(input string name = "sequence1");
    super.new(name);
  endfunction

  // As soon as the start method is called for a sequence, we execute pre, mid,
  // and post body functions

  // Sequences are primarily defined by these functions. They are what you use
  // to build up the sequence that will be sent.
  virtual task pre_body();
    `uvm_info("sequence1", "PRE_BODY EXECUTED", UVM_NONE);
  endtask

  virtual task body();
    `uvm_info("sequence1", "BODY EXECUTED", UVM_NONE);
  endtask

  virtual task post_body();
    `uvm_info("sequence1", "POST_BODY EXECUTED", UVM_NONE);
  endtask
endclass

// Notice how we pass the transaction class to the uvm_driver now
class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)

  transaction t;

  function new(input string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    t = transaction::type_id::create("t");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(t);
      // apply seq to DUT
      seq_item_port.item_done();  //non-blocking in nature
    end
  endtask
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  function new(input string name = "agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  driver d;

  // Note here that we are creating a sequencer that will feed a driver.
  // We actually never have to make a class to inherit from a sequencer since we
  // can use the one that the UVM has built in. 
  uvm_sequencer #(transaction) seqr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d = driver::type_id::create("d", this);
    seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // We connect the port of the driver to the export of the sequencer
    d.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)

  agent a;

  function new(input string name = "env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("a", this);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test);

  function new(input string name = "test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  sequence1 seq1;

  env e;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e", this);
    seq1 = sequence1::type_id::create("seq1", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Between the objections, we start the sequencer
    // sequencer is activated from the test
    seq1.start(e.a.seqr);

    phase.drop_objection(this);
  endtask
endclass
