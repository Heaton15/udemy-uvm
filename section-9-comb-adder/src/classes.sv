`include "uvm_macros.svh"
import uvm_pkg::*;

/* Now, we will go over all of the components and put everything together for
* a UVM simulation
*
* 1. Transaction: Keep track of all the I/O present in the DUT (uvm_sequence_item)
* 2. Sequence: Combination of transactions to verify specific test case (uvm_sequence)
* 3. Sequencer: Manage sequences. Send sequence to driver after request (uvm_sequencer)
* 4. Driver: Send request to driver for sequence, apply sequence to the DUT (uvm_driver)
* 5. Monitor: Collect response of DUT and forward to scoreboard (uvm_monitor)
* 6. Scoreboard: Compare response with golden data (uvm_scoreboard)
* 7. Agent: Encapsulate driver, sequencer, monitor. Connection of
*           driver/sequencer/tlm ports (uvm_agent)
* 8. Env: Encapsulate Agent / Scoreboard. Connection of analysis_port of mon,
*         scorboard (uvm_env)
* 9. Test: Encapsulate env. Start sequence (uvm_test)
*
*
*/


// transaction should have the DUT IO, and register the fields with the macros
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

class generator extends uvm_sequence #(transaction);
  `uvm_object_utils(generator)

  transaction t;

  // Counter variable 
  integer i;

  function new(input string path = "generator");
    super.new(path);
  endfunction

  virtual task body();
    t = transaction::type_id::create("t");
    repeat (10) begin
      start_item(t);
      t.randomize();
      `uvm_info("GEN", $sformatf("Data send to driver a: %0d, b: %0d", t.a, t.b), UVM_NONE);
      finish_item(t);
    end
  endtask
endclass

class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)

  function new(input string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  transaction tc;
  virtual adder_if aif;  // The driver must have the interface to connect to the DUT.

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tc = transaction::type_id::create("tc");

    if (!uvm_config_db#(virtual adder_if)::get(this, "", "aif", aif))
      `uvm_error("DRV", "Unable to access uvm_config_db");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(tc);
      // When triggering a interface use non-blocking
      aif.a <= tc.a;
      aif.b <= tc.b;
      `uvm_info("DRV", $sformatf("Trigger DUT a: %0d, b: %0d", tc.a, tc.b), UVM_NONE);
      seq_item_port.item_done();
      #10;
    end
  endtask
endclass

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  uvm_analysis_port #(transaction) send;

  function new(input string inst = "monitor", uvm_component parent = null);
    super.new(inst, parent);
    send = new("send", this);
  endfunction

  transaction t;

  // The monitor needs to have a interface that we can tap as well.
  virtual adder_if aif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    t = transaction::type_id::create("t");
    if (!uvm_config_db#(virtual adder_if)::get(this, "", "aif", aif))
      `uvm_error("MON", "Unable to access uvm_config_db");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      // Our first value will be valid after #10, so the monitor needs to wait
      // 10
      #10;
      t.a = aif.a;
      t.b = aif.b;
      t.y = aif.y;
      `uvm_info("MON", $sformatf("Data send to scoreboard a: %0d, b: %0d, y: %0d", t.a, t.b, t.y),
                UVM_NONE);
      send.write(t);
    end
  endtask
endclass

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp #(transaction, scoreboard) recv;

  transaction tr;

  function new(input string path = "scoreboard", uvm_component parent = null);
    super.new(path, parent);
    recv = new("recv", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
  endfunction

  virtual function void write(input transaction t);
    tr = t;
    `uvm_info("SCO", $sformatf("Data rcvd from Monitor a: %0d, b: %0d, y: %0d", tr.a, tr.b, tr.y),
              UVM_NONE);
    if (tr.y == tr.a + tr.b) begin
      `uvm_info("SCO", "Test Passed", UVM_NONE);
    end else begin
      `uvm_info("SCO", "Test Failed", UVM_NONE);
    end
  endfunction
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)

  function new(input string name = "agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  monitor m;
  driver d;

  // In the agent, we add the sequencer that does the connections to the driver
  uvm_sequencer #(transaction) seqr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m = monitor::type_id::create("MON", this);
    d = driver::type_id::create("DRV", this);
    seqr = uvm_sequencer#(transaction)::type_id::create("SEQ", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Driver to sequencer connection yee haw
    d.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)

  function new(input string name = "ENV", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  scoreboard s;
  agent a;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    s = scoreboard::type_id::create("s", this);
    a = agent::type_id::create("a", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Here, we connect the uvm_analysis_port to the imp in the scoreboard.
    a.m.send.connect(s.recv);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)

  function new(input string name = "TEST", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  generator gen;
  env e;

  virtual function void build_phase(uvm_phase phase);
    gen = generator::type_id::create("gen");  // sequence does not need this
    e   = env::type_id::create("e", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // Notice here how we start the sequence and connect it to the sequncer in
    // the agent
    gen.start(e.a.seqr);
    #50ns;  // Can also use drain time 
    phase.drop_objection(this);
  endtask
endclass

//*******************************
//        Adder_seq data
//*******************************

class driver_seq extends uvm_driver #(transaction);
  `uvm_component_utils(driver_seq)

  function new(input string name = "driver_seq", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  transaction tc;
  virtual adder_seq_if aif;  // The driver_seq must have the interface to connect to the DUT.

  task reset_dut();
    aif.rst <= 1'b1;
    aif.a   <= 0;
    aif.b   <= 0;
    repeat (5) @(posedge aif.clk);
    aif.rst <= 1'b0;
    `uvm_info("DRV", "Reset Done", UVM_NONE);
  endtask

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tc = transaction::type_id::create("tc");

    if (!uvm_config_db#(virtual adder_seq_if)::get(this, "", "aif", aif))
      `uvm_error("DRV", "Unable to access uvm_config_db");
  endfunction

  virtual task run_phase(uvm_phase phase);
    reset_dut();  // Start by resetting the system
    forever begin
      seq_item_port.get_next_item(tc);
      // When triggering a interface use non-blocking
      aif.a <= tc.a;
      aif.b <= tc.b;
      `uvm_info("DRV", $sformatf("Trigger DUT a: %0d, b: %0d", tc.a, tc.b), UVM_NONE);
      seq_item_port.item_done();
      repeat (2) @(posedge aif.clk);
    end
  endtask
endclass

class monitor_seq extends uvm_monitor;
  `uvm_component_utils(monitor_seq)

  uvm_analysis_port #(transaction) send;

  function new(input string inst = "monitorseq", uvm_component parent = null);
    super.new(inst, parent);
    send = new("send", this);
  endfunction

  transaction t;

  // The monitor_seq needs to have a interface that we can tap as well.
  virtual adder_seq_if aif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    t = transaction::type_id::create("t");
    if (!uvm_config_db#(virtual adder_seq_if)::get(this, "", "aif", aif))
      `uvm_error("MON", "Unable to access uvm_config_db");
  endfunction

  virtual task run_phase(uvm_phase phase);
    @(negedge aif.rst);  // We wait for reset to de-assert before we start monitoring
    forever begin
      repeat (2) begin
        @(posedge aif.clk);  // In the driver, we wait 2 clock ticks to apply transaction, so wait 2
      end
      t.a = aif.a;
      t.b = aif.b;
      t.y = aif.y;
      `uvm_info("MON", $sformatf("Data send to scoreboard a: %0d, b: %0d, y: %0d", t.a, t.b, t.y),
                UVM_NONE);
      // Notice that the scoreboardi s called by this function basically. The
      // monitor "writes" a result to the scoreboard and it checks if it is
      // correct. 
      send.write(t);
    end
  endtask
endclass

class agent_seq extends uvm_agent;
  `uvm_component_utils(agent_seq)

  function new(input string name = "agent_seq", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  monitor_seq m;
  driver_seq d;

  // In the agent_seq, we add the sequencer that does the connections to the driver
  uvm_sequencer #(transaction) seqr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m = monitor_seq::type_id::create("MON", this);
    d = driver_seq::type_id::create("DRV", this);
    seqr = uvm_sequencer#(transaction)::type_id::create("SEQ", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Driver to sequencer connection yee haw
    d.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass

class env_seq extends uvm_env;
  `uvm_component_utils(env_seq)

  function new(input string name = "ENV", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  scoreboard s;
  agent_seq a;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    s = scoreboard::type_id::create("s", this);
    a = agent_seq::type_id::create("a", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Here, we connect the uvm_analysis_port to the imp in the scoreboard.
    a.m.send.connect(s.recv);
  endfunction
endclass

class test_seq extends uvm_test;
  `uvm_component_utils(test_seq)

  function new(input string name = "TEST", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  generator gen;
  env_seq e;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase)
    gen = generator::type_id::create("gen");  // sequence does not need this
    e   = env_seq::type_id::create("e", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // Notice here how we start the sequence and connect it to the sequncer in
    // the agent
    gen.start(e.a.seqr);
    #60ns;  // Can also use drain time 
    phase.drop_objection(this);
  endtask
endclass
