`include "uvm_macros.svh"
import uvm_pkg::*;

/* Now, we will go over all of the components and put everything together for
* a UVM simulation
*
* 1. Transaction: Keep track of all the I/O present in the DUT (uvm_sequence_item)
* 2. Sequence: Combination of transactions to verify specific test case (uvm_sequence)
* 3. Sequencer: Manage sequences. Send sequence to driver after request (uvm_sequencer)
* 4. Driver: Send request to driver for sequence, apply sequence to the DUT (uvm_driver)
* 5. Monitor: Collect response of DUT and forward to scoreboard (uvm_monitor)
* 6. Scoreboard: Compare response with golden data (uvm_scoreboard)
*
*
*/
