`include "uvm_macros.svh"
import uvm_pkg::*;

class producer_1 extends uvm_component;
  `uvm_component_utils(producer_1)

  int data = 12;

  // Create the PORT of the producer_1 class
  uvm_blocking_put_port #(int) send;


  function new(input string path = "producer_1", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  // Put object creation inside of the build_phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Add the constructor for the class
    send = new("send", this);  // min/max interface size is 1 and 1
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    send.put(data);
    `uvm_info("PROD", $sformatf("Data Sent: %0d", data), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class consumer_1 extends uvm_component;
  `uvm_component_utils(consumer_1)

  uvm_blocking_put_export #(int) recv;

  // Wherever you want to receive the data is where the implementation should go
  // We need to define a put task in class consumer_1 
  uvm_blocking_put_imp #(int, consumer_1) imp;

  function new(input string path = "consumer_1", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
    imp  = new("imp", this);
  endfunction

  task put(int datar);
    `uvm_info("consumer_1", $sformatf("data: %0d", datar), UVM_NONE);
  endtask

endclass

class env_0 extends uvm_env;
  `uvm_component_utils(env_0)

  producer_1 p;
  consumer_1 c;

  function new(input string path = "env_0", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = producer_1::type_id::create("p", this);
    c = consumer_1::type_id::create("c", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    p.send.connect(c.recv);
    c.recv.connect(c.imp);
  endfunction
endclass

class test_port_export_imp extends uvm_test;
  `uvm_component_utils(test_port_export_imp)
  env_0 e;

  function new(input string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env_0::type_id::create("e", this);
  endfunction
endclass
