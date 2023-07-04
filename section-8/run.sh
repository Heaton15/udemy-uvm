#!/bin/bash -eu 

COMPILE=0
RUN=0
TOP="tb"
DEBUG=""


while getopts "hrcdt:" flag; do
  case "$flag" in
    r)
      RUN=1
      ;;
    c)
      COMPILE=1
      ;;
    t)
      TOP=${OPTARG}
      ;;
    d)
      DEBUG="+UVM_PHASE_TRACE +UVM_OBJECTION_TRACE"
      ;;
    h)
      echo "Usage: $(basename "$0") [-r] [-c] [-t] [-d] [-h]
      [-c] Compile the design 
      [-r] Run the design
      [-t] Specify the top module
      [-d] Debug flags for simulation
      [-h] Halp"
      exit 0
      ;;
    ?)
      echo "Invalid command option."
      exit 1
      ;;
  esac
done

if [[ $COMPILE -eq 1 ]]; then
  vcs -ntb_opts uvm -sverilog -full64 -timescale=1ns/1ps +incdir+${VCS_HOME}/include -f vflags.f -top $TOP
fi

if [[ $RUN -eq 1 ]]; then
  ./simv +ntb_random_seed_automatic $DEBUG
fi

