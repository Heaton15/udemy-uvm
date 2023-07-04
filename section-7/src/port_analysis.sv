`include "uvm_macros.svh"
import uvm_pkg::*;

class producer_6 extends uvm_component;
  `uvm_component_utils(producer_6)

  // Our analysis point which sends integers
  uvm_analysis_port #(int) port;

  int data = 12;

  function new(input string path = "producer_6", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);  // min/max interface size is 1 and 1
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(phase);
    `uvm_info("producer_6", $sformatf("Data Broadcasted: %0d", data), UVM_NONE);
    // Notice that the write method is what you must call for analysis ports
    port.write(data);
    phase.drop_objection(phase);
  endtask
endclass

class consumer_6a extends uvm_component;
  `uvm_component_utils(consumer_6a)

  uvm_analysis_imp #(int, consumer_6a) imp;

  function new(input string path = "consumer_6a", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  virtual function void write(int datar);
    `uvm_info("consumer_6a", $sformatf("Data Recv: %0d", datar), UVM_NONE);
  endfunction
endclass

class consumer_6b extends uvm_component;
  `uvm_component_utils(consumer_6b)

  uvm_analysis_imp #(int, consumer_6b) imp;

  function new(input string path = "consumer_6b", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  virtual function void write(int datar);
    `uvm_info("consumer_6b", $sformatf("Data Recv: %0d", datar), UVM_NONE);
  endfunction
endclass

class env_6 extends uvm_env;
  `uvm_component_utils(env_6)

  producer_6 p;
  consumer_6a c0;
  consumer_6b c1;

  function new(input string path = "env_6", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = producer_6::type_id::create("p", this);
    c0 = consumer_6a::type_id::create("c0", this);
    c1 = consumer_6b::type_id::create("c1", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    p.port.connect(c0.imp);
    p.port.connect(c1.imp);
  endfunction
endclass

class test_analysis extends uvm_test;
  `uvm_component_utils(test_analysis)
  env_6 e;

  function new(input string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env_6::type_id::create("e", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass
