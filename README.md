# udemy-uvm
SystemVerilog UVM Training

The UVM field guide for help is found here:

https://verificationacademy.com/verification-methodology-reference/uvm/docs_1.1c/html/

```
+-----------------------------------------+-----------------------------------------------+------------------------------------------------+
| Construction Phase (Non-Time)           | Run Phase (Time Consuming)                    | Cleanup Phase (Non-Time)                       |
| _______________________________________ | _____________________________________________ | ______________________________________________ |
| Construction Phase (4 phases)           | Run Phase (12 phases)                         | Cleanup Phase (4 phases)                       |
| 1. build_phase                          | - Generation / applying stimulus              | - To collection and report the data            |
| - Create an object of a class           | to DUT and waiting for valid response         | - Check whether coverage goals are achieved    |
| - super.build_phase(phase)              | 1. reset_phase                                |                                                |
| 2. connect_phase                        |  a. pre_reset_phase                           | 1. extract_phase                               |
| - Create the connection of              |  b. post_reset_phase                          | 2. check_phase                                 |
| a component in TLM                      | 2. configure_phase                            | 3. report_phase                                |
| 3. end_of_elaboration_phase             |  a. pre_configure_phase                       | 4. final_phase                                 |
| - Uses to understand hierarchy          |  b. post_configure_phase                      |                                                |
| - Adjust hierarchy of component         | 3. main_phase                                 |                                                |
|                                         |  a. pre_main_phase                            |                                                |
|                                         |  b. post_main_phase                           |                                                |
|                                         | 4. shutdown_phase                             |                                                |
|                                         |  a. pre_shutdown_phase                        |                                                |
|                                         |  b. post_shutdown_phase                       |                                                |
|                                         |                                               |                                                |
+-----------------------------------------+-----------------------------------------------+------------------------------------------------+
```
