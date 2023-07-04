`include "uvm_macros.svh"
import uvm_pkg::*;

// Only uvm_components can control uvm phases

// uvm_test belongs to a uvm_component

class test extends uvm_test;
  `uvm_component_utils(test)

  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction


  /* Construction Phases */

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("test", "Build Phase Executed", UVM_NONE);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("test", "Connect Phase Executed", UVM_NONE);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("test", "End of Elaboration Phase Executed", UVM_NONE);
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("test", "Start of Simulation Phase Executed", UVM_NONE);
  endfunction


  /* Main Phases */

  // Only looking at the run_phase call. You can also call the
  // reset/configure/main/shutdown phases

  task run_phase(uvm_phase phase);
    `uvm_info("test", "Run Phase", UVM_NONE);
  endtask

  /* Cleanup Phase */

  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    `uvm_info("test", "Extract Phase", UVM_NONE);
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    `uvm_info("test", "Check Phase", UVM_NONE);
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("test", "Report Phase", UVM_NONE);
  endfunction

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info("test", "Final Phase", UVM_NONE);
  endfunction
endclass

class driver extends uvm_driver;
  `uvm_component_utils(driver)

  function new(string path = "driver", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("driver", "Driver Build Phase Executed", UVM_NONE);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("driver", "Driver Connect Phase Executed", UVM_NONE);
  endfunction

  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("driver", "Driver Reset Started", UVM_NONE);
    #100ns;
    `uvm_info("driver", "Driver Reset Completed", UVM_NONE);
    phase.drop_objection(this);
  endtask

  // Because main phase comes after reset phase, we expect to see the main phase
  // from t=100ns to t=300ns since 200ns are delayed.
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("driver", "Driver Main Phase Started", UVM_NONE);
    #300ns;
    `uvm_info("driver", "Driver Main Phase Ended", UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  function new(string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("monitor", "Monitor Build Phase Executed", UVM_NONE);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("monitor", "Monitor Connect Phase Executed", UVM_NONE);
  endfunction

  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("monitor", "Monitor Reset Started", UVM_NONE);
    #300ns;
    `uvm_info("monitor", "Monitor Reset Completed", UVM_NONE);
    phase.drop_objection(this);
  endtask

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("monitor", "Monitor Main Phase Started", UVM_NONE);
    #400ns;
    `uvm_info("monitor", "Monitor Main Phase Ended", UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass


class env extends uvm_env;
  `uvm_component_utils(env)

  driver  drv;
  monitor mon;

  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("env", "Env Build Phase Executed", UVM_NONE);
    // Does drv / mon get built first here? 
    // lexicographic order is what decides the order that the drv / mon are
    // created
    // drv [d] comes before mon [m] (d before m)
    // This means that the driver will exist first. 
    // If you change the monitor to be "bon", then it will execute first.
    drv = driver::type_id::create("drv", this);
    mon = monitor::type_id::create("mon", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("env", "Env Connect Phase Executed", UVM_NONE);
  endfunction
endclass


// What you can intuitively see here is that the build_phase of this test is
// what creates the objects of the env. As a result, the build phase of the test
// has to run first in order for the env build phase to run (and in turn run all
// of the build phases of objects in the env build phase)

// The build order is also apparent from the `uvm_info() description dumps. The
// terminal will show test -> env -> driver / monitor build info

// What you will see in the terminal output when you run this test is that the
// build phase `uvm_info() calls print top down while the connect phase
// `uvm_info() calls print bottom up. 
class test_connect_phase extends uvm_test;
  `uvm_component_utils(test_connect_phase)

  env e;

  function new(string path = "test_connect_phase", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("test_connect_phase", "Test Build Phase Executed", UVM_NONE);
    e = env::type_id::create("e", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("test_connect_phase", " Test Connect Phase Executed", UVM_NONE);
  endfunction
endclass

// Run Phase or 12 sub phases can consume time

class comp extends uvm_component;
  `uvm_component_utils(comp)

  function new(string path = "comp", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  // UVM will not automatically hold time for the task to finish. To
  // purposefully hold the time for a specific phase, you need to use the
  // objection mechanism. 

  // These objections are more frequently seen in sequences themselves
  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp", "Reset Started", UVM_NONE);
    #10ns;
    `uvm_info("comp", "Reset Completed", UVM_NONE);
    phase.drop_objection(this);
  endtask

  // Time consumed in a single component
  // Since the reset_phase comes before the main_phase, you won't see the
  // main_phase start until after 10ns. So this main phase will run from t=10ns
  // to t=110ns
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp", "Main Phase Started", UVM_NONE);
    #100ns;
    `uvm_info("comp", "Main Phase Ended", UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass


class env_mult_phase extends uvm_env;
  `uvm_component_utils(env_mult_phase)

  driver  drv;
  monitor mon;

  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("env", "Env Build Phase Executed", UVM_NONE);
    drv = driver::type_id::create("drv", this);
    mon = monitor::type_id::create("mon", this);
  endfunction
endclass

class test_env_mult_phase extends uvm_test;
  `uvm_component_utils(test_env_mult_phase)

  env_mult_phase e;

  function new(string path = "test_env_mult_phase", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env_mult_phase::type_id::create("e", this);
    `uvm_info("test_env_mult_phase", "Test_Env_Mult_Phase Build Phase Executed", UVM_NONE);
  endfunction
endclass

class draintime_env extends uvm_env;
  `uvm_component_utils(draintime_env)

  function new(string name = "draintime_env", uvm_component parent);
    super.new(name, parent);
  endfunction
endclass



class test_draintime extends uvm_test;
  `uvm_component_utils(test_draintime)

  draintime_env e;

  function new(string path = "test_draintime", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = draintime_env::type_id::create("e", this);
    `uvm_info("test_draintime", "Test Draintime Build Phase Executed", UVM_NONE);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_phase main_phase;
    super.end_of_elaboration_phase(phase);

    // This grabs the main phase object
    main_phase = phase.find_by_name("main", 0);

    // The main_phase now specifically has 100ns of drain time
    main_phase.phase_done.set_drain_time(this, 300);
  endfunction

  task main_phase(uvm_phase phase);
    // As a result, when the main_phase ends, we will wait another 200ns
    //  phase.phase_done.set_drain_time(this, 200ns);

    phase.raise_objection(this);
    `uvm_info("test_draintime", "Test Draintime Main Phase Started", UVM_NONE);
    #100ns;
    `uvm_info("test_draintime", "Test Draintime Main Completed", UVM_NONE);
    phase.drop_objection(this);
  endtask

  // This post_main_phase step should be ran 100ns + draintime = 300ns
  task post_main_phase(uvm_phase phase);
    `uvm_info("test_draintime", "Test Draintime Post Main Phase ", UVM_NONE);
  endtask
endclass
