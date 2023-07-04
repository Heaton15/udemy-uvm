`include "uvm_macros.svh"
import uvm_pkg::*;


class subproducer extends uvm_component;
  `uvm_component_utils(subproducer)

  int data = 12;
  uvm_blocking_put_port #(int) subport;

  function new(string name = "subproducer", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    subport = new("subport", this);
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("subproducer", $sformatf("Data Sent: %0d", data), UVM_NONE);
    subport.put(data);
    phase.drop_objection(this);
  endtask
endclass

class producer_2 extends uvm_component;
  `uvm_component_utils(producer_2)

  // subproducer is instantiated
  subproducer s;

  uvm_blocking_put_port #(int) port;


  function new(input string path = "producer_2", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  // Put object creation inside of the build_phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Add the constructor for the class
    port = new("port", this);  // min/max interface size is 1 and 1
    s = subproducer::type_id::create("s", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // This is a port -> port connection
    s.subport.connect(port);  // connect subport to port
  endfunction
endclass

class consumer_2 extends uvm_component;
  `uvm_component_utils(consumer_2)

  uvm_blocking_put_imp #(int, consumer_2) imp;

  function new(input string path = "consumer_2", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  task put(int datar);
    `uvm_info("consumer_2", $sformatf("data: %0d", datar), UVM_NONE);
  endtask

endclass

class env_2 extends uvm_env;
  `uvm_component_utils(env_2)

  producer_2 p;
  consumer_2 c;

  function new(input string path = "env_2", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = producer_2::type_id::create("p", this);
    c = consumer_2::type_id::create("c", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    p.port.connect(c.imp);
  endfunction
endclass

class test_port_to_port_to_imp extends uvm_test;
  `uvm_component_utils(test_port_to_port_to_imp)
  env_2 e;

  function new(input string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env_2::type_id::create("e", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass
