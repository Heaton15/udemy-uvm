`include "uvm_macros.svh"
import uvm_pkg::*;

class producer_3 extends uvm_component;
  `uvm_component_utils(producer_3)

  int data = 12;

  uvm_blocking_put_port #(int) port;

  function new(input string path = "producer_3", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);  // min/max interface size is 1 and 1
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    port.put(data);
    `uvm_info("producer_3", $sformatf("Data Sent: %0d", data), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class subconsumer extends uvm_component;
  `uvm_component_utils(subconsumer)

  uvm_blocking_put_imp #(int, subconsumer) imp;

  function new(string name = "subconsumer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  task put(int datar);
    `uvm_info("subconsumer", $sformatf("data: %0d", datar), UVM_NONE);
  endtask

endclass

class consumer_3 extends uvm_component;
  `uvm_component_utils(consumer_3)

  // We have the imp defined in the subconsumer and will connect it in the
  // consumer
  uvm_blocking_put_export #(int) expo;
  subconsumer s;

  function new(input string path = "consumer_3", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    expo = new("expo", this);
    s   = subconsumer::type_id::create("s", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // See here that the expo is the primary consumer and we connect the expo
    // and the imp of the subconsumer with the .connect() method.
    expo.connect(s.imp);
  endfunction
endclass

class env_3 extends uvm_env;
  `uvm_component_utils(env_3)

  producer_3 p;
  consumer_3 c;

  function new(input string path = "env_3", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = producer_3::type_id::create("p", this);
    c = consumer_3::type_id::create("c", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // We don't connect directly to the imp, instead it is directly to the
    // expo which is already connected to the imp.
    p.port.connect(c.expo);
  endfunction
endclass

class test_port_to_export_to_imp extends uvm_test;
  `uvm_component_utils(test_port_to_export_to_imp)
  env_3 e;

  function new(input string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env_3::type_id::create("e", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass
