`include "uvm_macros.svh"
import uvm_pkg::*;

// Notice that the uvm_sequence#(T), T = type
class sequence_flow_steps extends uvm_sequence #(transaction);
  `uvm_object_utils(sequence_flow_steps)

  transaction trans;

  function new(input string name = "sequence_flow_steps");
    super.new(name);
  endfunction


  // This is demoing the flow steps in the OneNote UDEMY-UVM/UVM section
  // We can see how to wait for a grant, randomize data, send a request, and
  // then wait for it to be done. 
  virtual task body();
    `uvm_info("SEQ1", "Trans obj Created", UVM_NONE);
    trans = transaction::type_id::create("trans");
    `uvm_info("SEQ1", "Waiting for Grant from Driver", UVM_NONE);
    wait_for_grant();
    `uvm_info("SEQ1", "Rcvd Grant..Randomizing Data", UVM_NONE);
    assert (trans.randomize());
    `uvm_info("SEQ1", "Randomization Done -> Sent Req to Drv", UVM_NONE);
    send_request(trans);
    `uvm_info("SEQ1", "Waiting for Item Done Resp from Driver", UVM_NONE);
    wait_for_item_done();
    `uvm_info("SEQ1", "SEQ1 Ended", UVM_NONE);
  endtask
endclass

// Notice how we pass the transaction class to the uvm_driver_flow_demo now
class driver_flow_demo extends uvm_driver #(transaction);
  `uvm_component_utils(driver_flow_demo)

  transaction t;

  virtual adder_if aif;

  function new(input string name = "driver_flow_demo", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    t = transaction::type_id::create("t");
    if (!uvm_config_db#(virtual adder_if)::get(this, "", "aif", aif))
      `uvm_info("driver_flow_demo", "Unable to access interface", UVM_NONE);
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      `uvm_info("Drv", "Sending Grant for Sequence", UVM_NONE);
      seq_item_port.get_next_item(t);
      `uvm_info("Drv", "Applying Seq to DUT", UVM_NONE);
      `uvm_info("Drv", "Sending Item Done Resp for Sequence", UVM_NONE);
      seq_item_port.item_done();
    end
  endtask
endclass

class agent_flow_demo extends uvm_agent;
  `uvm_component_utils(agent_flow_demo)

  function new(input string name = "agent_flow_demo", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  driver_flow_demo d;
  uvm_sequencer #(transaction) seq;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d   = driver_flow_demo::type_id::create("d", this);
    seq = uvm_sequencer#(transaction)::type_id::create("seq", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // We connect the port of the driver_flow_demo to the export of the sequencer
    d.seq_item_port.connect(seq.seq_item_export);
  endfunction
endclass

class env_flow_demo extends uvm_env;
  `uvm_component_utils(env_flow_demo)

  agent_flow_demo a;

  function new(input string name = "env_flow_demo", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent_flow_demo::type_id::create("a", this);
  endfunction
endclass

class test_flow_demo extends uvm_test;
  `uvm_component_utils(test_flow_demo);

  function new(input string name = "test_flow_demo", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  sequence_flow_steps s1;

  env_flow_demo e;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env_flow_demo::type_id::create("e", this);
    s1 = sequence_flow_steps::type_id::create("s1", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Between the objections, we start the sequencer
    // sequencer is activated from the test_flow_demo
    s1.start(e.a.seq);

    phase.drop_objection(this);
  endtask
endclass
