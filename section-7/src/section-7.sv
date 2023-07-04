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

module tb_port_imp_only;
  initial begin
    run_test("test_port_imp_only");
  end
endmodule
