`include "uvm_macros.svh"
import uvm_pkg::*;
/*
*************************************************
*******This section will cover uvm_object********
*************************************************

uvm_object and uvm_component are the 2 base classes which everything is built
out of 

Driver, Scoreboard, Monitor will always be present for an entire simulation time (static components)
Transaction have a life time where they cause a pass or fail (dynamic components)

There are pre-defined classes which are derived from uvm_object and
uvm_component that users use

dynamic components -> uvm_object
- uvm_sequence_item

static components -> uvm_component
- uvm_driver

Note that a uvm_component is derived from uvm_objects
uvm_tree can be made with a uvm_component but not uvm_object

phases in UVM only exist for uvm_component. Phases cannot exist for uvm_objects


uvm_object                      ----              uvm_component




Used to interact with dynamic components 
Transaction object spans independemtn of time and included print, compare,
create object, etc

uvm_object have a set of methods known as core methods
uvm_object
 - uvm_transaction
 - uvm_sequence_item
 - uvm_sequence



Used to build the static environment
uvm_component
 - uvm_driver
 - uvm_sequencer
 - uvm_monitor
 - uvm_agent 
 - uvm_scoreboard
 - uvm_env
 - uvm_test

Core Methods (Field Macros for uvm_object)
  - print
  - record
  - copy
  - compare
  - create
  - clone
  - pack / unpack

The core methods expand into general inline code that is not as run-time efficient nor as flexible as 
direct implementations of the do_* methods.

// They are basically abstract methods you have to create yourself
You could make user defined do_* methods to do similar things
  - do_print
  - do_record
  - do_copy
  - do_compare
  - do_pack / do_unpack

Using these requires you to specify how they will work
  
// There are 2 ways to access Core Methods 
// 1. Field Macros, call method but don't have to define implementation
// 2. do_* methods and don't have to register data member with a field macor but
// must define implementation

// We will learn how to build the uvm_object classes and the field macros / do methods
*/

module tb;
  fData f;
  initial begin
    f = new();
    f.randomize();  // randomize all rand items
    $display("Value of data: %0d", f.data);
  end
endmodule

module tb_obj;
  obj o;

  initial begin
    o = new("obj");
    o.randomize();
    `uvm_info("TB_TOP", $sformatf("a: %0d", o.a), UVM_NONE);
  end

endmodule

module tb_macros_explained;
  obj_macros_explained o;

  initial begin
    o = new("obj");
    o.randomize();
    o.print();  // Only available when fields / variables are registered to the factory
  end
endmodule

module tb_change_printer;
  obj_macros_explained o;

  initial begin
    o = new("obj");
    o.randomize();
    o.print(
        uvm_default_tree_printer); // Only available when fields / variables are registered to the factory
    o.print(
        uvm_default_line_printer); // Only available when fields / variables are registered to the factory
  end
endmodule

module tb_field_macros;
  obj_field_macros o;
  initial begin
    o = new("obj");
    o.randomize();
    o.print(uvm_default_table_printer);
  end
endmodule

module tb_field_macros_obj;
  child c;
  initial begin
    c = new("child");
    c.p.randomize(); // -> NOTE: the rand variables are in the parent, so we have to run randomization 
    c.print();
  end
endmodule

module tb_array_field_macros;
  array a;

  initial begin
    a = new("array");
    a.run();
    a.print();
  end
endmodule

module tb_copy;
  first f;
  first s;

  initial begin
    // We want to copy data into s
    f = new("first");
    s = new("second");
    f.randomize();
    s.copy(f);
    f.print();
    s.print();
  end
endmodule

module tb_clone;
  first f;
  first s;

  initial begin
    f = new("first");
    s = new("second");
    f.randomize();

    /* This is an error because when you clone, you get a copy of the parent
       class. f (class first) is a child of uvm_object, and when we do
       s = f.clone(), you are saying that you want to assign s (class first) to
       f (class uvm_object);

       This is resolved by typecasting!
    */

    // Error: s = f.clone();
    // https://verificationguide.com/systemverilog/systemverilog-casting/
    $cast(s, f.clone());
    f.print();
    s.print();
  end
endmodule


module tb_deep_vs_shallow;
  /*  If we get an independent handle for original class / copied class, its deep
   *  If  we get a single handle for both classes, its shallow
  */
  second s1, s2;

  initial begin
    s1 = new("s1");
    s2 = new("s2");
    s1.f.randomize();
    s1.print();

    /* Shallow Copy */
    // copy s1 into s2
    s2 = s1;
    s2.print();
    s2.f.data = 'hf;
    // When you print both, you will see that both share data = 'h4;
    // This change is seed by both instances, which means they share a handle.
    // This is a shallow copy
    s1.print();
    s2.print();
  end

  /* Deep Copy */
  // Can implement on you rown
  // Or you can do s2.copy(s1);
endmodule

// Let's investigate more about copy / clone
module tb_deepcopy;

  // Important lessons learned here:
  // 1. s2.copy(s1) -> Deep Copy
  // 2. $cast(s3, s1.clone()) -> Deep Copy
  second s1, s2;
  second s3;

  initial begin
    s1 = new("s1");
    s2 = new("s2");
    s1.f.randomize();

    s2.copy(s1);  // deep copy

    s1.print();
    s2.print();

    s2.f.data = 12;

    // As we can see here, this is a deep copy since only 1 handle is changed
    s1.print();
    s2.print();

    // s3 does not need to be initialized
    $cast(s3, s1.clone()); // Deep copy
    s1.print();
    s3.print();

    s3.f.data = 12;
    s1.print();
    s3.print();
  end
endmodule

module tb_compare;
endmodule
