`include "uvm_macros.svh"
import uvm_pkg::*;

/*
* When we want to communicate data between classes, we use TLM communication in
* UVM, which is blocking or non-blocking.
*  - PUT port
*  - GET port
*  - Transport Port
*  - Analysis Port
*  - TLM FIFO
*
*
* - Sequencer acts as the "generator" which creates the packets and send it to
*   the driver
*
* - Driver with the help of an interface applies the sequence to the DUT
*
* - The sequencer / driver connect is made with mailbox / semaphores
*     - mailbox / semaphore not used in the UVM
* - The monitor collects the response from the DUT 
* - Monitor sends results to the scoreboard where the results are computed
*
* - In the UVM, transaction level modeling (TLMs) are used.
*
*
* Sequencer -> Driver: Special TLM Port : SEQ_ITEM_PORT
* Monitor -> Scoreboard: TLM Port : UVM_ANALYSIS_PORT
*
*
* TLMs are discussed in terms of port and exports
*   - Port initiates transaction (initiator)
*   - Export is component that responds to a port (responder)
*
* Box A can be the PORT box (square) (initiator)
* Box B can be the EXPORT box (circle) (responder)
* - Control Flow (initiator sends control info to responder)
* - Data Flow (initiator can causes data from resp -> init or init -> resp)
* A ------> B
*
* Initiator -> Responder
*   A ->->-> B
*   - PUT Operation
*
* Responder -> Initiator
*   A <-<-<- B
*   - GET Operation
*
* Responder <-> Initiator
*   A <->-<-> B (data flows both directions)
*   - Transport Operation
*
*   When it comes to sending data, you can use blocking or non-blocking
*   assignments. The blocking assignments won't let you move forward until the
*   previous action is complete, as the name implies.
*
*   PUT + Blocking 
*   GET + Blocking
*   PUT + Non-Blocking
*   GET + Non-Blocking
*
* 
*      Port                   Export 
*  +----------+            +----------+
*  |          |            |          |
*  | Producer |  --------> | Consumer |
*  |          |            |          |
*  +----------+            +----------+
*
*
*   PUT Operations
*   --------------
*   The parameter type is the type T of the transaction
*
*     - uvm_blocking_put_port #(param)
*     - uvm_blocking_put_export #(param)
*     - uvm_blocking_put_imp #(param)
*
*  uvm_blocking_put_port #(type T = int) extends uvm_port_base#(uvm_tlm_if_base#(T, T))
*
*/

// What you should notice between the producer and consuemr is that we are not
// defining how to send the data, just if the 2 classes can be connected
// together. This connection is done in the connect phase. 
//
// Driver and Sequencer connection is in connect_phase of agent
// Monitor and Scoreboard connection is in connect_phase of environment

class producer extends uvm_component;
  `uvm_component_utils(producer)

  int data = 12;

  // Create the PORT of the producer class
  uvm_blocking_put_port #(int) send;


  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);

    // Add the constructor for the class
    send = new("send", this); // min/max interface size is 1 and 1
  endfunction
endclass

class consumer extends uvm_component;
  `uvm_component_utils(consumer)

  uvm_blocking_put_export #(int) recv;

  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
    recv = new("recv", this);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)

  producer p;
  consumer c;

  function new(input string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = producer::type_id::create("p", this);
    c = consumer::type_id::create("c", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    /* Connect the TLM ports! */
    // In the connect phase, we can make the TLM port connection
    // What we will see here is that an export is not allowed to be the endpoint
    // of a TLM, just the receiver. 
    // We need to use the uvm_blocking_put_imp to be the connection. 
    p.send.connect(c.recv);
  endfunction
endclass

class test extends uvm_test;
  `uvm_component_utils(test)
  env e;

  function new(input string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e", this);
  endfunction
endclass

