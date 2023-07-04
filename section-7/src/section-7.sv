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

// What you should notice between the producer_1 and consuemr is that we are not
// defining how to send the data, just if the 2 classes can be connected
// together. This connection is done in the connect phase. 
//
// Driver and Sequencer connection is in connect_phase of agent
// Monitor and Scoreboard connection is in connect_phase of environment

// In this testbench example, we see how a Producer, Consumer, and Imp are all
// created in the hierarchy to send a transaction over a TLM. 
module tb_port_export_imp;
  initial begin
    run_test("test_port_export_imp");
  end
endmodule

// This testbench provides an example of how the consumer is not needed and how
// you can connect a producer to the imp and skip the consumer (recv)
// definition. 
module tb_port_imp_only;
  initial begin
    run_test("test_port_imp_only");
  end
endmodule

// This testbench shows how a sub-producer inside of the producer can generate
// the TLM and send that to the top level producer port. 
module tb_port_to_port_to_imp;
  initial begin
    run_test("test_port_to_port_to_imp");
  end
endmodule

// This testbench shows the opposite of the previous one. Here,
// there is a port -> export -> imp -> subconsumer (imp) where a subconsumer is
// inside of a consumer.
module tb_port_to_export_to_imp;
  initial begin
    run_test("test_port_to_export_to_imp");
  end
endmodule

// PUT is producer to consumer and data flow is the same.
// GET is different because the producer sends request but the consumer will
// send data
module tb_port_get;
  initial begin
    run_test("test_port_get");
  end
endmodule

// If you have a situation where you need to send data both ways, you have to
// use transport
// You should see in the terminal output that the data sent from the producer is
// what the consumer receives and that the data sent from the consumer is
// received by the producer.
module tb_transport;
  initial begin
    run_test("test_transport");
  end
endmodule

/*
*
* An analysis port is when you want to broadcast the same data from a producer
* to multiple components. 
*
* By default, port/export are 1 to 1, so this port is needed for multiple
* connections
*
* With get/put ports, you can either be blocking or non-blocking.
*
* With an analysis port, we do not check if communication is done or not. That
* means we can only use functions in analysis ports because they cannot consume
* time.
*
* This is one of the more important differences between them. 
*
* uvm_analysis_port #(datatype)
* uvm_analysis_imp #(datatype, class)
*
* port.write(data);
*
* virtual function void write(data);
* endfunction
*
*      Port                   Export 
*  +----------+            +------------+
*  |          |            |            |
*  | Producer |  --------> | Consumer 0 |
*  |          |            |            |
*  +----------+            +------------+
*       |                     Export 
*       |                  +------------+
*       |                  |            |
*       +----------------> | Consumer 1 |
*                          |            |
*                          +------------+
*
*  we make the connections in the connect_phase the same way we have
*  p.port.connect(c1.imp);
*  p.port.connect(c2.imp);
*
*/
module tb_analysis;
  initial begin
    run_test("test_analysis");
  end
endmodule
