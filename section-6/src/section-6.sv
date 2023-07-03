`include "uvm_macros.svh"
import uvm_pkg::*;
`timescale 1ns/1ns

/* This entire section is dedicated to the phases of UVM and what they do
   - Note that the phases are automatically called 

  Phases belong to 2 categories:
   - Time consuming
   - Non-time consuming
   
  The time consuming phases are how we will be applying stimulus and standard SV DUT assertion


  Standard verification steps:
    - Configuring TB env
    - System Reset
    - Applying Stimulus to DUT
    - Compare responses with golden data
    - Generateing report

  Phases:
    - Time consuming 
      - Apply stimulus to DUT on valid edges
    - Not time consuming
      - Creating objects of classes / init at t=0
  
All phases which do not consume time will be functions
  - function + super. in the definition

All phases which consume time use tasks
   - tasks


There are 20 phases in total that give fine tune control, but very rarely will you find yourself
having to use all 20 of them. 

Construction Phase (4 phases)
  1. build_phase
    - Create an object of a class
    - super.build_phase(phase)

  2. connect_phase
    - Create the connection of a component in TLM

  3. end_of_elaboration_phase
    - Uses to understand hierarchy
    - Adjust hierarchy of component

  4. start_of_simulation

Run Phase (12 phases)
  - Generation / applying stimulus 
    to DUT and waiting for valid response
  1. run_phase
    a. reset_phase
      a.1 pre_reset_phase
      a.2 post_reset_phase
    b. configure_phase
      b.1 pre_configure_phase
      b.2 post_configure_phase
    c. main_phase
      c.1 pre_main_phase
      c.2 post_main_phase
    d. shutdown_phase
      d.1 pre_shutdown_phase
      d.2 post_shutdown_phase


reset_phase
  - Reset the DUT at the start of verification to bring system into null state

configure_phase
  - Have certain variables in an env that have to be set to specific values
    - memories, arrays, general variables

main_phase
  - Generating stimuli + collecting the response

shutdown_phase
  - Stimuli that are generated are correctly applied to the DUT and provided enough time to the verification
    env to receive all of the responses to the input stimuli.


Cleanup Phase (4 phases)
  - To collection and report the data
  - Check whether coverage goals are achieved

  1. extract_phase
  2. check_phase
  3. report_phase
  4. final_phase

UVM Phase table
+-----------------------------------------+-----------------------------------------------+------------------------------------------------+
| Construction Phase (Non-Time)           | Run Phase (Time Consuming)                    | Cleanup Phase (Non-Time)                       |
| _______________________________________ | _____________________________________________ | ______________________________________________ |
| Construction Phase (4 phases)           | Run Phase (12 phases)                         | Cleanup Phase (4 phases)                       |
| 1. build_phase                          | - Generation / applying stimulus              | - To collection and report the data            |
| - Create an object of a class           | to DUT and waiting for valid response         | - Check whether coverage goals are achieved    |
| - super.build_phase(phase)              | 1. reset_phase                                |                                                |
| 2. connect_phase                        | a. pre_reset_phase                            | 1. extract_phase                               |
| - Create the connection of              | b. post_reset_phase                           | 2. check_phase                                 |
| a component in TLM                      | 2. configure_phase                            | 3. report_phase                                |
| 3. end_of_elaboration_phase             | a. pre_configure_phase                        | 4. final_phase                                 |
| - Uses to understand hierarchy          | b. post_configure_phase                       |                                                |
| - Adjust hierarchy of component         | 3. main_phase                                 |                                                |
|                                         | a. pre_main_phase                             |                                                |
|                                         | b. post_main_phase                            |                                                |
|                                         | 4. shutdown_phase                             |                                                |
|                                         | a. pre_shutdown_phase                         |                                                |
|                                         | b. post_shutdown_phase                        |                                                |
|                                         |                                               |                                                |
+-----------------------------------------+-----------------------------------------------+------------------------------------------------+


- Time Consuming (tasks)
  - Run Phase 

- Non Time Consuming (functions + super.)
  - Construction Phase
  - Cleanup Phase




How to Override Phases

- Non time consuming phases are functions which we can overide
- In overriding time consuming tasks, we override tasks instead

- Commonly used phases
  - build_phase
  - connect_phase
*/


module tb_override_phases;
  initial begin
    run_test("test");
  end
endmodule


/*  Phases running top down can go from test -> env -> slo / agent -> mon/drv/seq
*    - This means parents execute first and then we go to the children
*
*   Phases can also be ran botton up where the bottom of the tree executes first
*     - mon/drv/seq -> agent -> env -> test -> uvm_top
*
*
*   BUILD_PHASE runs top down
*   OTHER PHASES run bottom up
*/

module tb_connect_phase;
  initial begin
    run_test("test_connect_phase");
  end
endmodule

module tb_raising_objections;
  initial begin
    run_test("comp");
  end
endmodule


// For multiple phases, time moves from phase to phase. Since reset phase comes
// before main phase, a #100ns in reset will cause the main phase to start at
// t=100ns for that component. 
module tb_mult_phases;
  initial begin
    run_test("test_env_mult_phase");
  end
endmodule

// By default, the timeout is 9200 seconds (huge)
module tb_timeouts;
  initial begin
    // The test before required 500ns, so if we set the timeout to 200ns we
    // should fail
    uvm_top.set_timeout(200ns);
    run_test("test_env_mult_phase");
  end
endmodule

module tb_draintime;
  // When you send a DUT data, sometimes you have to wait a certain amount of
  // time for the data to enter and be responded to in the DUT. For example, you
  // might need 10ns after the main_phase ends for the DUT to finish up. This
  // time is the buffer time which in turn is called the drain time. 
  initial begin
    run_test("test_draintime");
  end
endmodule

