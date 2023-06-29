`include "uvm_macros.svh"
import uvm_pkg::*;

// https://verificationacademy.com/verification-methodology-reference/uvm/docs_1.1c/html/files/macros/uvm_object_defines-svh.html

class first;
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

  // `uvm_object_utils(obj)

  function new(string path = "OBJ");  // Note default path is added
    super.new(path);
  endfunction

  rand bit [3:0] a;

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

  // This allows us to start registering something to a factory
  `uvm_object_utils_begin(obj_macros_explained)
    `uvm_field_int(obj_macros_explained,)
  `uvm_object_utils_end

endclass
