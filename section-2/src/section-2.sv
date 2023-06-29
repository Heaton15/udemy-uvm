`include "uvm_macros.svh"
import uvm_pkg::*;

/* 
*
// UVM Provides a wide variety of reporting mechanism
typedef enum bit [1:0] {
  UVM_INFO,  // Informative Message
  UVM_WARNING,  // Indicates a potential problem
  UVM_ERROR,  // Indicates a real problem (continues subject to the configured message)
  UVM_FATAL  // Indicates a problem which simulation cannot recover.
} uvm_severity;

typedef enum{
  UVM_NONE = 0,
  UVM_LOW = 100,
  UVM_MEDIUM = 200,
  UVM_HIGH = 300,
  UVM_FULL = 400,
  UVM_DEBUG = 500
} uvm_verbosity;


- UVM_INFO -
UVM_INFO(id, msg, redundancy_level)
id -> pathname of a class
msg -> Message to send
redundancy_level -> 200 by default (UVM_MEDIUM) 

W/e the redundancy level you set, it must be <= to the redundancy level you set with a UVM_INFO,
or it will not be reported.

- UVM_WARNING / UVM_ERROR / UVM_FATAL -
The rest of the reporting mechanism (WARNING, ERROR, FATAL) we do not get filtering capability.
They indicate that a problem exists, so we don't add a redundancy level.

UVM_WARNING(id, msg);
UVM_ERROR(id, msg);
UVM_FATAL(id, msg);

`include "uvm_macros.svh"  // Provides access to common macros, like `uvm_info(...)
import uvm_pkg::*; -> allows us to get access to the definition of classes we are going to extend to build up the UVM

*/
module tb;
  initial
    `uvm_fatal("tb", "Default TB -> Specify which one to actually run");
endmodule

module tb1;

  // Getting Started
  initial begin
    // id -> Normally a class indentifier
    #10ns;
    `uvm_info("TB_TOP", "Hello World", UVM_LOW);
    $display("Hello World with Display");
  end
endmodule

module tb2;
  int data = 56;
  // sformatf 
  initial begin
    `uvm_info("TB_TOP", $sformatf("Value of var : %d", data), UVM_NONE);
  end
endmodule

module tb3;
  // UVM_ROOT is parent to all classes in a UVM TB environment (UVM Tree)

  // Because UVM_ROOT returns a null pointer, we cannot directly access it.
  // However, in a few situations, we may need to access or configure the
  // default settings of UVM_ROOT.

  // In such a case, UVM provides a global variable UVM_TOP which is accessible
  // to all classes of environment. UVM_TOP could be used whenever we need to
  // work with the UVM root. 

  initial begin
    $display("Default Verbosity Level : %0d ", uvm_top.get_report_verbosity_level);
    #10ns uvm_top.set_report_verbosity_level(UVM_HIGH);
    $display("Default Verbosity Level : %0d ", uvm_top.get_report_verbosity_level);
    `uvm_info("TB_TOP", "String", UVM_HIGH);
  end
endmodule


module tb4;
  /* Verbosity level of classes*/

  driver0 drv;  // Instance of driver drc
  env0 e;

  // Couple important things to note here:
  // 1. The DRV1 / DRV2 IDs are registered based on their use it seems. 

  initial begin
    // In a real scenario, null won't be there
    drv = new("DRV", null);  // Initialize class handle
    e   = new("ENV", null);

    // Can also do +UVM_VERBOSITY=UVM_HIGH on the command line
    e.set_report_verbosity_level(UVM_HIGH);
    drv.set_report_verbosity_level(UVM_HIGH);

    drv.run();
    e.run();
  end
endmodule

module tb5;
  /* Hierarchical verbosity setting */
  env1 e;

  initial begin
    e = new("ENV", null);
    e.set_report_verbosity_level_hier(UVM_HIGH);
    e.run();
  end
endmodule


module tb6;
  /* uvm_info / uvm_warning / uvm_error / uvm_fatal */

  driver2 drv;

  initial begin
    drv = new("DRV", null);
    drv.run();
  end
endmodule

module tb7;
  // These commands let you to change the severity. For example, all UVM_FATAL
  // calls can be down graded to UVM_ERRORS

  /* 
   set_report_severity_override()
   set_report_severity_id_override()
  */

  driver2 d;
  initial begin
    d = new("DRV", null);
    d.set_report_severity_id_override(UVM_FATAL, "DRV1", UVM_ERROR);
    d.run();
  end
endmodule

module tb8;
  /* UVM has actions */
  // UVM_NO_ACTION - no action is taken
  // UVM_DISPLAY - Sends the report to the standard output (terminal / console)
  // UVM_LOG - sends the report to the file(s) for this (severity, id) pair
  // UVM_COUNT - Counts the number of reports with the COUNT attribute. 
  //             When this value reaches max_quit_count, the simulation
  //             terminates
  // UVM_EXIT - Terminates the simulation immediately (default action in UVM_FATAL)
  // UVM_CALL_HOOK - Callback the report hook methods
  // UVM_STOP - Causes ~$stop~ to be excuted, putting the simulation into interactive mode
  // UVM_RM_RECORD -  Sends the report to the reporter 

  // set_report_severity_action

  driver2 d;
  initial begin
    d = new("DRV", null);
    //d.set_report_severity_action(UVM_INFO, UVM_DISPLAY | UVM_EXIT); // In this case, uvm_info will exit sims
    //d.set_report_severity_action(UVM_FATAL, UVM_DISPLAY); // uvm_fatal no longer kills simulations
    d.run();
  end

endmodule

module tb9;
  /* UVM counting errors */
  // These can be used to set a threshold of errors. If over 5 for example, kill
  // a sim. No reason to keep failing. 

  // set_report_max_quit_count() -- when UVM_COUNT reaches max_count, die is called

  driver3 d;
  initial begin
    d = new("DRV", null);
    d.set_report_max_quit_count(2);  // set max_count for the method
    d.set_report_severity_action(UVM_WARNING,
                                 UVM_DISPLAY | UVM_COUNT);  // warning now causes count increments
    d.run();
  end
endmodule

module tb10;
  // This goes over storing data not only at stdout but also into files
  // set_report_default_file() -> Send all output data to thie file ID instead
  // set_report_severity_file(UVM_ERROR, fileId) -> Send specific severity IDs to a file

  driver4 d;
  int file, file2;  // file descriptor ID

  initial begin
    file = $fopen("log.txt", "w");
    file2 = $fopen("uvm_error.txt", "w");

    d = new("DRV", null);
    d.set_report_default_file(file);  // Everything gets dumped here
    d.set_report_severity_file(UVM_ERROR, file2);

    // NOTE: UVM_WARNING / UVM_ERROR need to be | with UVM_DISPLAY and UVM_LOG
    // so that they can report to stdout and to the log as well
    d.set_report_severity_action(UVM_INFO, UVM_DISPLAY | UVM_LOG);
    d.set_report_severity_action(UVM_WARNING, UVM_DISPLAY | UVM_LOG);
    d.set_report_severity_action(UVM_ERROR, UVM_DISPLAY | UVM_LOG);
    d.run();
    #10;
    $fclose(file);
    // The above setup will have all UVM_INFO / UVM_WARNING go to the file and
    // all UVM_ERROR go to file2
  end
endmodule

module assignment1;
  initial begin
    `uvm_info("assignment1", "Behavioral SRAM", UVM_NONE);
  end
endmodule

module assignment2;
  initial begin
    uvm_top.set_report_verbosity_level(UVM_DEBUG);
    $display("Verbosity: %d", uvm_top.get_report_verbosity_level);
  end
endmodule

module assignment3;
  // UVM_WARNING should increment quit_count
  drivera3 drv;
  initial begin

    drv = new("DRV", null);
    // uvm_warning now displays and counts
    drv.set_report_max_quit_count(4);
    drv.set_report_severity_action(UVM_WARNING, UVM_DISPLAY | UVM_COUNT);
    #10ns;
    drv.run();
  end
endmodule

module assignment4;

  component c;
  initial begin
    c = new("CMP", null);
    c.set_report_verbosity_level(UVM_DEBUG);
    c.set_report_id_verbosity("CMP2", UVM_NO_ACTION);
    c.run();
  end
endmodule


module assignment5;

  killComponent c;

  initial begin
    c = new("CMP", null);
    c.set_report_severity_action(UVM_WARNING, UVM_DISPLAY | UVM_EXIT);
    #10ps;
    c.run();
  end
endmodule








/* End Section Notes:

UVM Info: https://verificationacademy.com/verification-methodology-reference/uvm/docs_1.2/html/files/base/uvm_report_object-svh.html

1. set_report_verbosity_level(UVM_HIGH)
2. set_report_verbosity_level_hier(UVM_HIGH)
3. set_report_id_verbosity(id, UVM_NO_ACTION)
4. set_report_max_quit_count(4);
5. set_report_severity_action(UVM_WARNING, UVM_DISPLAY | UVM_COUNT);

*/
