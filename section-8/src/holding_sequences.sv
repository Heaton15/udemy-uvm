`include "uvm_macros.svh"
import uvm_pkg::*;

/*
* Let's say we have seq1 and seq2
* seq1 wants to send 3 transactions
* seq2 wants to send 3 transactions
*
* If they have equal access, we will get 6 transactions as:
* seq1, seq2, seq1, seq2, seq1, seq2
*
*
* We know we have Priority, where if seq1 has greater priority than seq2, then
* we can control seq1 to fire first since it has a higher priority.
*
* Lock method / Grab method are the alternatives. 
*
* Grab method has higher priority compared to lock method
*
*
*/

class sequence_hold_0 extends uvm_sequence #(transaction);
  `uvm_object_utils(sequence_hold_0)

  transaction trans;

  function new(input string name = "sequence_hold_0");
    super.new(name);
  endfunction


  // lock / unlock method allows you to control what is getting access
  // If both sequences are locked, then the first one ot get access will run 
  // all of its transactions first. 

  virtual task body();
    lock(m_sequencer);
    repeat (3) begin
      trans = transaction::type_id::create("trans");
      `uvm_info("sequence_hold_0", "sequence_hold_0 Started", UVM_NONE);
      start_item(trans);
      assert (trans.randomize);
      finish_item(trans);
      `uvm_info("sequence_hold_0", "sequence_hold_0 Ended", UVM_NONE);
    end
    unlock(m_sequencer);
  endtask
endclass

class sequence_hold_1 extends uvm_sequence #(transaction);
  `uvm_object_utils(sequence_hold_1)

  transaction trans;

  function new(input string name = "sequence_hold_1");
    super.new(name);
  endfunction

  virtual task body();
    lock(m_sequencer);
    repeat (3) begin
      trans = transaction::type_id::create("trans");
      `uvm_info("sequence_hold_1", "sequence_hold_1 Started", UVM_NONE);
      start_item(trans);
      assert (trans.randomize);
      finish_item(trans);
      `uvm_info("sequence_hold_1", "sequence_hold_1 Ended", UVM_NONE);
    end
    unlock(m_sequencer);
  endtask
endclass

// Notice how we pass the transaction class to the uvm_driver_hold now
class driver_hold extends uvm_driver #(transaction);
  `uvm_component_utils(driver_hold)

  transaction t;

  function new(input string name = "driver_hold", uvm_component parent = null);
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

class agent_hold extends uvm_agent;
  `uvm_component_utils(agent_hold)

  function new(input string name = "agent_hold", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  driver_hold d;
  uvm_sequencer #(transaction) seq;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d   = driver_hold::type_id::create("d", this);
    seq = uvm_sequencer#(transaction)::type_id::create("seq", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(seq.seq_item_export);
  endfunction
endclass

class env_hold extends uvm_env;
  `uvm_component_utils(env_hold)

  agent_hold a;

  function new(input string name = "env_hold", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent_hold::type_id::create("a", this);
  endfunction
endclass

class test_hold extends uvm_test;
  `uvm_component_utils(test_hold);

  function new(input string name = "test_hold", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  sequence_hold_0 s0;
  sequence_hold_1 s1;

  env_hold e;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e  = env_hold::type_id::create("e", this);
    s0 = sequence_hold_0::type_id::create("s0", this);
    s1 = sequence_hold_1::type_id::create("s1", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);


    // In this default configuration with the repeat(3) above, we get access
    // back and forth. But this is not what we want. We want to set it up so
    // 3 sequences of seq1 and 3 sequences of seq2 are sent. We can do this with
    // strict fifo.
    // Strict Fifo allows you to have 3 sequences from one then 3 from another
    //e.a.seq.set_arbitration(SEQ_ARB_STRICT_FIFO);

    fork
      s0.start(e.a.seq, null, 100);
      s1.start(e.a.seq, null, 200);
    join


    phase.drop_objection(this);
  endtask
endclass


/* The grab ungrab section did not have video. This is the code accompanied with
* it. Just look into grab / ungrab and how it can be used. 
*
 
`include "uvm_macros.svh"
import uvm_pkg::*;
 
class transaction extends uvm_sequence_item;
  rand bit [3:0] a;
  rand bit [3:0] b;
       bit [4:0] y;
 
 
  function new(input string inst = "transaction");
  super.new(inst);
  endfunction
 
`uvm_object_utils_begin(transaction)
  `uvm_field_int(a,UVM_DEFAULT)
  `uvm_field_int(b,UVM_DEFAULT)
  `uvm_field_int(y,UVM_DEFAULT)
`uvm_object_utils_end
 
endclass
//////////////////////////////////////////////////////
 
class sequence1 extends uvm_sequence#(transaction);
  `uvm_object_utils(sequence1)
 
transaction trans;
 
  function new(input string inst = "seq1");
  super.new(inst);
  endfunction
 
   virtual task body();
     
     
           repeat(3) begin
 
           `uvm_info("SEQ1", "SEQ1 Started" , UVM_NONE); 
            trans = transaction::type_id::create("trans");
            start_item(trans);
            assert(trans.randomize);
            finish_item(trans);
           `uvm_info("SEQ1", "SEQ1 Ended" , UVM_NONE); 
 
           end
     
  
     
     
   endtask
  
  
  
endclass
////////////////////////////////////////////////////////////////
 
 
class sequence2 extends uvm_sequence#(transaction);
  `uvm_object_utils(sequence2)
 
transaction trans;
 
  function new(input string inst = "seq2");
  super.new(inst);
  endfunction
 
  
  virtual task body();
    
    grab(m_sequencer);
    
    repeat(3) begin
    
    `uvm_info("SEQ2", "SEQ2 Started" , UVM_NONE); 
    trans = transaction::type_id::create("trans");
    start_item(trans);
    assert(trans.randomize);
    finish_item(trans);
    `uvm_info("SEQ2", "SEQ2 Ended" , UVM_NONE);
      
    end  
    
    ungrab(m_sequencer);
    
  endtask
  
  
endclass
 
 
////////////////////////////////////////////////////////////////////
 
class driver extends uvm_driver#(transaction);
`uvm_component_utils(driver)
 
transaction t;
virtual adder_if aif;
 
function new(input string inst = "DRV", uvm_component c);
super.new(inst,c);
endfunction
 
  virtual function void build_phase(uvm_phase phase);
  	super.build_phase(phase);
  	t = transaction::type_id::create("TRANS");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
    seq_item_port.get_next_item(t);
    seq_item_port.item_done();
    end    
  endtask
 
 
endclass
 
///////////////////////////////////////////////////////////
 
class agent extends uvm_agent;
`uvm_component_utils(agent)
 
function new(input string inst = "AGENT", uvm_component c);
super.new(inst,c);
endfunction
 
driver d;
uvm_sequencer #(transaction) seq;
 
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
d = driver::type_id::create("DRV",this);
seq = uvm_sequencer #(transaction)::type_id::create("seq",this);
endfunction
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
d.seq_item_port.connect(seq.seq_item_export);
endfunction
endclass
 
/////////////////////////////////////////////////////////////////////////
 
class env extends uvm_env;
`uvm_component_utils(env)
 
function new(input string inst = "ENV", uvm_component c);
super.new(inst,c);
endfunction
 
agent a;
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
  a = agent::type_id::create("AGENT",this);
endfunction
 
endclass
 
///////////////////////////////////////////////////////////////
 
class test extends uvm_test;
`uvm_component_utils(test)
 
function new(input string inst = "TEST", uvm_component c);
super.new(inst,c);
endfunction
 
sequence1 s1;
sequence2 s2;  
env e;
 
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("ENV",this);
    s1 = sequence1::type_id::create("s1");
    s2 = sequence2::type_id::create("s2");  
    endfunction
 
    virtual task run_phase(uvm_phase phase);
 
    phase.raise_objection(this);
   // e.a.seq.set_arbitration(UVM_SEQ_ARB_STRICT_FIFO);
      
      
    fork  
       s1.start(e.a.seq, null, 100); 
       s2.start(e.a.seq, null, 200); 
    join  
      
      
    phase.drop_objection(this);
    endtask
endclass
 
////////////////////////////////////////////////////////
module tb;
 
 
initial begin
  run_test("test");
end
 
endmodule
*/
