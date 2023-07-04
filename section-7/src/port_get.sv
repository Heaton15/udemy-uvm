`include "uvm_macros.svh"
import uvm_pkg::*;


class producer_4 extends uvm_component;
  `uvm_component_utils(producer_4)

  int data = 0;
  // Notice how this is a GET port now
  uvm_blocking_get_port #(int) port;

  function new(input string path = "producer_4", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);  // min/max interface size is 1 and 1
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(phase);
    // GET method is used here now
    port.get(data);
    `uvm_info("producer_4", $sformatf("Data Recv: %0d", data), UVM_NONE);
    phase.drop_objection(phase);
  endtask                                                              
endclass

class consumer_4 extends uvm_component;
  `uvm_component_utils(consumer_4)

  // In this example, the consumer will be sending the data
  int data = 12;

  uvm_blocking_get_imp #(int, consumer_4) imp;

  function new(input string path = "consumer_4", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  // The get() method has an output which is implicitly understood to be what
  // connects to the 
  task get(output int datar);
    `uvm_info("consumer_4", $sformatf("data: %0d", data), UVM_NONE);
    datar = data;
  endtask
endclass

class env_4 extends uvm_env;
  `uvm_component_utils(env_4)

  producer_4 p;
  consumer_4 c;

  function new(input string path = "env_4", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = producer_4::type_id::create("p", this);
    c = consumer_4::type_id::create("c", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    p.port.connect(c.imp);
  endfunction
endclass

class test_port_get extends uvm_test;
  `uvm_component_utils(test_port_get )
  env_4 e;

  function new(input string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env_4::type_id::create("e", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass
