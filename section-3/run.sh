#!/bin/bash -eu 

COMPILE=0
RUN=0
TOP="tb"


while getopts "hrct:" flag; do
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
    h)
      echo "Usage: $(basename "$0") [-r] [-c] [-t] [-h]
      [-c] Compile the design 
      [-r] Run the design
      [-t] Specify the top module
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
  ./simv 
fi

