`include "uvm_macros.svh"
import uvm_pkg::*;
/* In this demo, we can see how we create the following hierarchy
* - test
*   - env
*     - agent
*       - comp1 
*       - comp2
*
* What we are mainly showing in this example is that we can use the
* uvm_config_db#(T) method to set the value of data inside of comp1 and comp2
* from the testbench level.
*
* Notice how when you run this that the comp1 / comp2 data* fields are populated
* with 256 bits. 
*/
class comp1 extends uvm_component;
  `uvm_component_utils(comp1)

  // W/e we write from tb top, we will write it here
  int data1 = 0;

  function new(string path = "comp1", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(int)::get(null, "uvm_test_top", "data", data1))
      `uvm_error("comp1", "Unable to access interface");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp1", $sformatf("data rcvd comp1: %0d", data1), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class comp2 extends uvm_component;
  `uvm_component_utils(comp2)

  // W/e we write from tb top, we will write it here
  int data2 = 0;

  function new(string path = "comp2", uvm_component parent = null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(int)::get(null, "uvm_test_top", "data", data2))
      `uvm_error("comp2", "Unable to access interface");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp2", $sformatf("data rcvd comp2: %0d", data2), UVM_NONE);
    phase.drop_objection(this);
  endtask
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent);
  function new(input string inst = "AGENT", uvm_component c = null);
    super.new(inst, c);
  endfunction

  comp1 c1;
  comp2 c2;

  virtual function void build_phase(uvm_phase phase);
    c1 = comp1::type_id::create("comp1", this);
    c2 = comp2::type_id::create("comp2", this);
  endfunction
endclass

class env_demo1 extends uvm_env;
  `uvm_component_utils(env_demo1);

  function new(input string inst = "ENV", uvm_component c = null);
    super.new(inst, c);
  endfunction

  agent a;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("AGENT", this);
  endfunction
endclass

class test_demo1 extends uvm_test;
  `uvm_component_utils(test_demo1)

  function new(input string inst = "TEST", uvm_component c = null);
    super.new(inst, c);
  endfunction

  env_demo1 e;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env_demo1::type_id::create("ENV", this);
  endfunction
endclass

// Demo 2 is mainly a recap of the set /get methods for setting / getting
// variables from the config_db

/*
* uvm_config_db#(T)
*   - set -> change the value 
*   - get -> get the value
*
*
*
*   uvm_config_db#(int)::set(context, instance_name, key, value)
*     - context: (null in static and this for dynamic)
*     - instance_name: string of instance
*     - key: string key to access values 
*     - value: Value that the key will access 
*
*   uvm_config_db#(int)::set(null, "uvm_test_top", "data", data);
*     -> In this example you will have "uvm_test_top.data" as the hierarchicl
*        path, and if the get works, it will return the actual data value. 
*
*   uvm_config_db#(int)::get(context, instance_name, key, value)
*   
*   uvm_config_db#(int)::get(null, "uvm_test_top", "data", data2)
*
*
*   If a uvm_config_db has a get/set which the same instance_name.key, then they
*   will match up and you can access the data.
*
*/

// Demo 3
/* if (!uvm_config_db#(int)::get(null, "uvm_test_top", "data", data1))
*    ->  When null is used, we get the full path down to this point which is:
*
*        uvm_test_top.e.a.c2.data
*
*    -> If you use this, you will get 
*
*        uvm_test_top.env.agent.comp2.data
*
*   The null is the correct path, but this will cause the wrong path to be
*   formed. A uvm_error in the build phase will trigger and uvm_fatal
*   immediately since there has been a build problem.
*
*
*   If you want to access with this, you would have to change 
*   "uvm_test_top" to "uvm_test_top.env.agent.comp1", which is not something you
*   want to be doing.
*
*/

// Demo 4
/*
* Let's say that we want to provide a set to all components inside of an agent
*
* "uvm_test_top.env.agent.*" will allow you to have a wildcard for the remaining
* path all the way down to what .*data is.
*/

/* Examples
*
* In the case that you want to be doing sets on an interface, you can pass an
* interface to the set method.
*
* uvm_config_db#(virtual adder_if)::get(this, "", "aif", aif)
*   -> If you use this, then the set method in the tb must have a full path to
*      this point
*
*   This does a good job by showing that you can set / get an interface to
*   connect a interface that is driven in the UVM system to a top level
*   testbench.
*
*
*   All of that code is included below for reference.
*
*
*     module adder(
      input [3:0] a,b,
      output [4:0] y
    );
      
      
      assign y = a + b;
      
    endmodule
     
     
     
    interface adder_if;
      logic [3:0] a;
      logic [3:0] b;
      logic [4:0] y;
      
    endinterface
     




/////////////////////////Testbench Environment

    //////////////////////////////////////////////////////
     
    `include "uvm_macros.svh"
    import uvm_pkg::*;
     
     
    class drv extends uvm_driver;
      `uvm_component_utils(drv)
     
      virtual adder_if aif;
     
      function new(input string path = "drv", uvm_component parent = null);
        super.new(path,parent);
      endfunction
     
      virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
        if(!uvm_config_db#(virtual adder_if)::get(this,"","aif",aif))//uvm_test_top.env.agent.drv.aif
          `uvm_error("drv","Unable to access Interface");
      endfunction
      
       virtual task run_phase(uvm_phase phase);
         phase.raise_objection(this);
         for(int i = 0; i< 10; i++)
          begin
            aif.a <= $urandom;
            aif.b <= $urandom;
            #10;
          end
         phase.drop_objection(this);
       endtask
     
    endclass
     
     
     
    /////////////////////////////////////////////////////////////////////////
     
    class agent extends uvm_agent;
    `uvm_component_utils(agent)
     
      function new(input string inst = "agent", uvm_component c);
    super.new(inst,c);
    endfunction
     
     drv d;
     
     
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      d = drv::type_id::create("drv",this);
    endfunction
     
    endclass
     
    ///////////////////////////////////////////////////////////////////////
     
    class env extends uvm_env;
    `uvm_component_utils(env)
     
      function new(input string inst = "env", uvm_component c);
    super.new(inst,c);
    endfunction
     
    agent a;
     
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      a = agent::type_id::create("agent",this);
    endfunction
     
    endclass
     
     
    //////////////////////////////////////////////////////////////////
    class test extends uvm_test;
    `uvm_component_utils(test)
     
      function new(input string inst = "test", uvm_component c);
    super.new(inst,c);
    endfunction
     
    env e;
     
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      e = env::type_id::create("env",this);
    endfunction
     
     
    endclass
     
     
    ////////////////////////////////////////////////////////////////////
    module tb;
     
      adder_if aif();
      
      adder dut (.a(aif.a), .b(aif.b), .y(aif.y));
     
    initial 
      begin
      uvm_config_db #(virtual adder_if)::set(null, "uvm_test_top.env.agent.drv", "aif", aif);
      run_test("test"); 
      end
     
      initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
      end
    endmodule
*/
