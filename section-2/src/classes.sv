`include "uvm_macros.svh"
import uvm_pkg::*;


class driver0 extends uvm_driver;
  // When something belongs to a component, it must be given a path / parent id
  `uvm_component_utils(driver0)  // Register the driver with the factory

  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction

  task run();
    `uvm_info("DRV1", "Executed Driver1 Code", UVM_HIGH);
    `uvm_info("DRV2", "Executed Driver2 Code", UVM_HIGH);
  endtask
endclass

class env0 extends uvm_env;
  `uvm_component_utils(env0);

  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction

  task run();
    `uvm_info("ENV1", "Executed ENV1 Code", UVM_HIGH);
    `uvm_info("ENV2", "Executed ENV2 Code", UVM_HIGH);
  endtask
endclass

/* --------------------------------------------------------------- */

class driver1 extends uvm_driver;
  // When something belongs to a component, it must be given a path / parent id
  `uvm_component_utils(driver1)  // Register the driver with the factory

  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction

  task run();
    `uvm_info("DRV", "Executed Driver Code", UVM_HIGH);
  endtask
endclass

class monitor1 extends uvm_monitor;
  `uvm_component_utils(monitor1);

  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction

  task run();
    `uvm_info("MON", "Executed Monitor Code", UVM_HIGH);
  endtask
endclass

class env1 extends uvm_env;
  `uvm_component_utils(env1);

  driver1  drv;
  monitor1 mon;

  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction

  task run();
    drv = new("DRV", this);
    mon = new("MON", this);
    drv.run();
    mon.run();
  endtask
endclass

/* --------------------------------------------------------------- */

class driver2 extends uvm_driver;
  // When something belongs to a component, it must be given a path / parent id
  `uvm_component_utils(driver1)  // Register the driver with the factory

  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction

  task run();
    `uvm_info("DRV", "Informational Message", UVM_NONE);
    `uvm_warning("DRV", "Potential Error"); // 
    `uvm_error("DRV", "Real Error"); // uvm_count (default)
    #10;
    `uvm_fatal("DRV", "Simulation cannot continue"); // uvm_exit
    `uvm_fatal("DRV1", "Simulation Cannot Continue DRV1");
  endtask
endclass

/* --------------------------------------------------------------- */

class driver3 extends uvm_driver;
  // When something belongs to a component, it must be given a path / parent id
  `uvm_component_utils(driver1)  // Register the driver with the factory

  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction

  task run();
    `uvm_info("DRV", "Informational Message", UVM_NONE);
    `uvm_warning("DRV", "Potential Error"); 
    // If you want to count uvm_warnings, just change the action to UVM_COUNT
    `uvm_error("DRV", "Real Error"); // uvm_count (default)
    //`uvm_error("DRV", "Second Real Error");
  endtask
endclass

/* --------------------------------------------------------------- */

class driver4 extends uvm_driver;
  // When something belongs to a component, it must be given a path / parent id
  `uvm_component_utils(driver1)  // Register the driver with the factory

  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction

  task run();
    `uvm_info("DRV", "Informational Message", UVM_NONE);
    `uvm_warning("DRV", "Potential Error"); 
    `uvm_error("DRV", "Real Error"); // uvm_count (default)
    `uvm_error("DRV", "Second Real Error");
  endtask
endclass


class drivera3 extends uvm_driver;
  `uvm_component_utils(drivera3)

  function new (string path, uvm_component parent);
    super.new(path, parent);
  endfunction

  task run();
    for (int i=0; i<4; i++) begin
      `uvm_warning("DRV", $sformatf("msg: %0d", i));
    end
  endtask

endclass

class component extends uvm_component;
  `uvm_component_utils(component)

  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction

  task run();
    `uvm_info("CMP1", "Executed CMP1 Code", UVM_DEBUG);
    `uvm_info("CMP2", "Executed CMP2 Code", UVM_DEBUG);
  endtask
endclass

class killComponent extends uvm_component;
  `uvm_component_utils(killComponent)
  function new(string path, uvm_component parent);
    super.new(path, parent);
  endfunction

  task run();
    `uvm_warning("CMP", "Kill the simulation");
    `uvm_info("CMP", "This is unreachable", UVM_NONE);
  endtask
endclass
