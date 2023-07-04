`include "uvm_macros.svh"
import uvm_pkg::*;

class producer_0 extends uvm_component;
  `uvm_component_utils(producer_0)

  int data = 12;

  // Create the PORT of the producer_0 class
  uvm_blocking_put_port #(int) send;


  function new(input string path = "producer_0", uvm_component parent = null);
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
    `uvm_info("producer_0", $sformatf("Data Sent: %0d", data), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class consumer_0 extends uvm_component;
  `uvm_component_utils(consumer_0)

  uvm_blocking_put_export #(int) recv;

  // Wherever you want to receive the data is where the implementation should go
  // We need to define a put task in class consumer_0 
  uvm_blocking_put_imp #(int, consumer_0) imp;

  function new(input string path = "consumer_0", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
    imp  = new("imp", this);
  endfunction

  task put(int datar);
    `uvm_info("consumer_0", $sformatf("data: %0d", datar), UVM_NONE);
  endtask

endclass

class env_0 extends uvm_env;
  `uvm_component_utils(env_0)

  producer_0 p;
  consumer_0 c;

  function new(input string path = "env_0", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = producer_0::type_id::create("p", this);
    c = consumer_0::type_id::create("c", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    /* Connect the TLM ports! */
    // In the connect phase, we can make the TLM port connection
    // What we will see here is that an export is not allowed to be the endpoint
    // of a TLM, just the receiver. 
    // We need to use the uvm_blocking_put_imp to be the connection. 
    // This is placed with the export side of the connection
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
