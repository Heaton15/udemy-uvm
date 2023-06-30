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
    $cast(s3, s1.clone());  // Deep copy
    s1.print();
    s3.print();

    s3.f.data = 12;
    s1.print();
    s3.print();
  end
endmodule

module tb_compare;
  // compare will be very useful when we start comparing objects, like in
  // scoreboards

  first f1, f2;
  first f3, f4;
  int status = 0;
  int status2 = 0;
  initial begin
    f1 = new("f1");
    f2 = new("f2");
    f1.randomize();
    f2.randomize();
    f1.print();
    f2.print();

    // Compare Method now
    status = f1.compare(f2);
    // return 0 when different, return 1 when same
    // Notice how the terminal output has a "Miscompare" notice
    $display("status: %0d", status);

    // Because we copied f3 into f4, the data will be the same and compare is
    // correct
    f3 = new("f3");
    f4 = new("f4");
    f3.randomize();
    f4.copy(f3);
    f3.print();
    f4.print();
    status2 = f3.compare(f4);
    $display("status2: %0d", status2);

  end
endmodule

module tb_create;
  // Up to now we have been creating our own classes with new();
  // When in the UVM, the recommended way is to use the create() method so that
  // the factory can override types like in a transaction class.

  first f1, f2;

  initial begin
    // Do this in place of new()
    f1 = first::type_id::create("f1");
    f2 = first::type_id::create("f2");

    f1.randomize();
    f2.randomize();
    f1.print();
    f2.print();

  end
endmodule

module tb_new_vs_create;
  comp c;

  initial begin
    // comp c has a first f instance, so calling this new will initialize that
    // f and then randomize / print the data. So what if we want to override
    // first and instead use first_mod? We added new signals but we don't want
    // to change the first class.
    // c = comp::type_id::create("comp", null);
    
    // set_type_override_by_type(oldClass, newClass);
    c.set_type_override_by_type(first::get_type, first_mod::get_type);
    // Wherever you have a first instance, it will get replaced with first_mod
    c = comp::type_id::create("comp", null);

    // If we had not used the ::create() method, we would have to go back and
    // search / replace all uses of class first with class first_mod. When
    // maintaining larger code bases, updates like this become very difficult. 
  end
endmodule

module tb_do_print;
  obj_do o;

  initial begin
    o = obj_do::type_id::create("o");
    o.print();
  end
endmodule

module tb_conv2str;
  conv2str c;

  initial begin
    c = conv2str::type_id::create("c");
    $display("%0s", c.convert2string());
    `uvm_info("TB_TOP", $sformatf("%0s", c.convert2string()), UVM_NONE);
  end
endmodule

module tb_do_copy;
  do_copy_class o1, o2;

  initial begin
    o1 = do_copy_class::type_id::create("o1");
    o2 = do_copy_class::type_id::create("o2");

    o1.randomize();
    o2.randomize();
    o1.print();
    o2.print();
    o2.copy(o1);
    o1.print();
    o2.print();
  end
endmodule

module tb_do_compare;

  do_compare_class o1, o2;
  int status[2] = {0, 0};

  initial begin
    o1 = do_compare_class::type_id::create("o1");
    o2 = do_compare_class::type_id::create("o2");

    o1.randomize();
    o1.randomize();
    o1.print();
    o2.print();

    status[0] = o1.compare(o2);
    // Once we copy o1 to o2, they are the same contents
    o2.copy(o1);

    o1.print();
    o2.print();
    status [1] = o1.compare(o2);
    `uvm_info("TB_TOP", $sformatf("status[0]: %0d, status[1]: %0d", status[0], status[1]), UVM_NONE);

  end
endmodule

module tb_as1;
  as1_obj o;
  initial begin 
    o = as1_obj::type_id::create("o");
    o.randomize();
    o.print();
  end
endmodule

module tb_as2;
  as2_obj o1, o2;
  int status;

  initial begin
    o1 = as2_obj::type_id::create("o1");
    o2 = as2_obj::type_id::create("o2");

    o1.randomize();

    $cast(o2, o1.clone());
    status = o2.compare(o1);
    o2.print();
    o1.print();
    `uvm_info("TB_TOP", $sformatf("status: %0d", status), UVM_NONE);
  end
endmodule
