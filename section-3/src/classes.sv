`include "uvm_macros.svh"
import uvm_pkg::*;

// https://verificationacademy.com/verification-methodology-reference/uvm/docs_1.1c/html/files/macros/uvm_object_defines-svh.html

class fData;
  rand bit [3:0] data;
endclass

// Recall uvm_object is used for all dynamic components
class obj extends uvm_object;
  // Step 1: Register a class with the factory
  // - print, compare, deep copy all become available

  `uvm_object_utils(obj)  // register class to factory for uvm_object derived classes

  // The class name and path name should match
  function new(string path = "OBJ");  // Note default path is added
    super.new(path);
  endfunction

  // We are able to add Field Macros to Data Members like this
  // This will belong to `uvm_field_int because its a 3:0 bit. 
  rand bit [3:0] a;

  /* Put inside of these field macros */
  // `uvm_object_utils_begin
  // `uvm_object_utils_end

  /* `uvm_field_int
  *  `uvm_field_object
  *  `uvm_field_queue_string
  *  ....
  */
endclass

class obj_macros_explained extends uvm_object;

  //`uvm_object_utils(obj_macros_explained)

  function new(string path = "OBJ");  // Note default path is added
    super.new(path);
  endfunction

  rand bit [3:0] a;
  rand bit [7:0] b;

  /* `uvm_field_int(name, flag), flag can be the following:
  *    - UVM_ALL_ON - Set all operations on (default)
  *    - UVM_DEFAULT - Use the default flag settings
  *    - UVM_NOCOPY - Do not copy this field
  *    - UVM_NOCOMPARE - Do not compare this field
  *    - UVM_NOPRINT - Do not print this field
  *    - UVM_NOPACK - Do not pack or unpack this field
  *    - UVM_REFERENCE - 
  *    - UVM_PHYSICAL
  *    - UVM_ABSTRACT
  *    - UVM_READONLY
  */

  /* Can also | with the FLAG variable to change the data type for display
  *   - UVM_BIN
  *   - UVM_DEC
  *   - UVM_UNSIGNED
  *   - UVM_OCT
  *   - UVM_HEX
  *   - UVM_STRING
  *   - UVM_TIME
  */

  // This allows us to start registering something to a factory
  // Note that you have to register the a variable with the factory, otherwise
  // you will not be able to print it out. 
  `uvm_object_utils_begin(obj_macros_explained)
    `uvm_field_int(a, UVM_DEFAULT + UVM_HEX);  // Get default methods now
    `uvm_field_int(b, UVM_DEFAULT + UVM_DEC);  // Get default methods now
  `uvm_object_utils_end

endclass

class obj_field_macros extends uvm_object;
  /* `UVM_FIELD_* Macros
  *    - `uvm_field_int
  *    - `uvm_field_object
  *    - `uvm_field_string
  *    - `uvm_field_enum
  *    - `uvm_field_real
  *    - `uvm_field_event
  */

  // Will look at enum, real, and string
  typedef enum bit [1:0] {
    s0,
    s1,
    s2,
    s3
  } state_type;
  rand state_type state;
  real temp = 12.34;
  string str = "UVM";

  function new(string path = "obj");
    super.new(path);
  endfunction

  `uvm_object_utils_begin(obj_field_macros)
    `uvm_field_enum(state_type, state, UVM_DEFAULT);  // (enum type, val, FLAG)
    `uvm_field_string(str, UVM_DEFAULT);  // (ARG, FLAG)
    `uvm_field_real(temp, UVM_DEFAULT);  // (ARG, FLAG);
  `uvm_object_utils_end
endclass


class parent extends uvm_object;
  //`uvm_object_utils(parent);
  function new(string path = "parent");
    super.new(path);
  endfunction

  rand bit [3:0] data;

  // Notice how we have to register "data", otherwise we can't print its value
  `uvm_object_utils_begin(parent);
    `uvm_field_int(data, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

class child extends uvm_object;
  parent p;

  function new(string path = "child");
    super.new(path);
    p = new("parent");  ////// build_phase + create to add a constructor for class instances
  endfunction

  `uvm_object_utils_begin(child)
    `uvm_field_object(p, UVM_DEFAULT);  // -> NOTE: We just registered a class handle
  `uvm_object_utils_end
endclass

class array extends uvm_object;

  int arr1[3] = {1, 2, 3};  // static array
  int arr2[];  // dynamic array
  int arr3[$];  // queue
  int arr4[int];  // associative array (key = int)

  function new(string path = "array");
    super.new(path);
  endfunction

  /*
  * sarray -> static array
  * array -> dynamic array
  * aa -> associate array
  */

  // There is a ton of macros for each type of array, so just look them up based
  // on what your type is.
  // E.G `uvm_field_sarray_int vs `uvm_field_sarray_string for int arrays or
  // string arrays

  `uvm_object_utils_begin(array)
    `uvm_field_sarray_int(arr1, UVM_DEFAULT);
    `uvm_field_array_int(arr2, UVM_DEFAULT);
    `uvm_field_queue_int(arr3, UVM_DEFAULT);
    `uvm_field_aa_int_int(arr4, UVM_DEFAULT);
  `uvm_object_utils_end

  // Fill the empty arrays with random data
  task run();
    arr2 = new[3];  // allocate space
    for (int i = 0; i < 3; i++) begin
      arr2[i] = 2;
    end

    arr3.push_front(3);
    arr3.push_front(3);

    for (int i = 1; i < 5; i++) begin
      arr4[i] = 4;
    end
  endtask
endclass

/*
* Core Methods
*   - Print
*   - record
*   - copy 
*   - compare
*   - create
*   - clone
*   - pack / unpack
*
*  copy: Need to add constructor before copying data into targetted object
*  clone: Do not need to add constructor to the object we want to copy data to 
*/

class first extends uvm_object;
  rand bit [3:0] data;

  function new(string path = "first");
    super.new(path);
  endfunction

  `uvm_object_utils_begin(first)
    `uvm_field_int(data, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

class second extends uvm_object;
  first f;
  rand bit [3:0] s;

  function new(string path = "second");
    super.new(path);
    f = new("first");
  endfunction

  `uvm_object_utils_begin(second);
    `uvm_field_object(f, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

// Let's say that in a future release of our code / tbs, we decide that we want
// to add a new signal to the classes that we use. Create helps push these kind
// of changes.

class first_mod extends first;
  rand bit ack;

  `uvm_object_utils_begin(first_mod)
    `uvm_field_int(ack, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

// override the first class requires a component, so let's use this for now and
// talk about it later.
class comp extends uvm_component;
  `uvm_component_utils(comp)

  first f;

  function new(string path = "second", uvm_component parent = null);
    super.new(path, parent);
    f = first::type_id::create("f");
    f.randomize();
    f.print();
  endfunction
endclass

class obj_do extends uvm_object;
  `uvm_object_utils(obj_do)

  function new(string path = "obj_do");
    super.new(path);
  endfunction
  
  bit [3:0] a = 4;
  string b = "UVM";
  real c = 12.34;

  // NOTE: Because we are using the do_* methods, we do not have to register
  // this with the Field Macros. Just registert with `uvm_object_utils
  
  // virtual -> extended class will be called instead of base 
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer)
    printer.print_field_int("a", a, $bits(a), UVM_HEX);
    printer.print_string("b", b);
    printer.print_real("c", c);
  endfunction


endclass
