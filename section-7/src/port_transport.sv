`include "uvm_macros.svh"
import uvm_pkg::*;


class producer_5 extends uvm_component;
  `uvm_component_utils(producer_5)

  int datas = 12;  // Sent
  int datar = 0;  // Received 

  // This transport port will be able to manage data both ways
  // #(producer->consumer, consumer->producer)
  uvm_blocking_transport_port #(int, int) port;

  function new(input string path = "producer_5", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);  // min/max interface size is 1 and 1
  endfunction

  task main_phase(uvm_phase phase);
    phase.raise_objection(phase);
    port.transport(datas, datar);
    `uvm_info("producer_5", $sformatf("Data Sent: %0d, Data Recv: %0d", datas, datar), UVM_NONE);
    phase.drop_objection(phase);
  endtask
endclass

class consumer_5 extends uvm_component;
  `uvm_component_utils(consumer_5)

  // From the consumer perspective, the datas is going to producer
  // From the consumer persepctive, the datar is coming from the producer
  
  // In this example, the consumer will be sending the data
  int datas = 13;
  int datar = 0;

  // With a transport_imp, you have to specify both the datatypes for the
  // transaction
  // #(data sent, data received, class of imp)
  uvm_blocking_transport_imp #(int, int, consumer_5) imp;

  function new(input string path = "consumer_5", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  // virtual makes it clear we want to execute this method in a child class
  virtual task transport(input int datar, output int datas);
    datas = this.datas; // this.datas refers to the current class scope obviously 
    `uvm_info("consumer_5", $sformatf("Data Sent: %0d, Data Recv: %0d", datas, datar), UVM_NONE);
  endtask
endclass

class env_5 extends uvm_env;
  `uvm_component_utils(env_5)

  producer_5 p;
  consumer_5 c;

  function new(input string path = "env_5", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = producer_5::type_id::create("p", this);
    c = consumer_5::type_id::create("c", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    p.port.connect(c.imp);
  endfunction
endclass

class test_transport extends uvm_test;
  `uvm_component_utils(test_transport)
  env_5 e;

  function new(input string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env_5::type_id::create("e", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass
