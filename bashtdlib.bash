#!/usr/bin/env bash

# Set strict mode
#set -euo pipefail

function hello_world {
  echo "hello, world!"
}

function sourced {
  # Returns:
  #   0 if the function is called in a file that's being sourced
  #   1 if the function is called in a file that's being executed
  [[ ${FUNCNAME[1]} == source ]]
}

function denormopts {
  local -n _names_=$2
  local -n _flags_=$3
  local IFS=$IFS
  local _defn_
  local _opt_

  for _defn_ in $1; do
    IFS=,
    set -- $_defn_
    IFS='|'

    for _opt_ in $1; do
      _names_[$_opt_]=$2
      
      # If there is an 'f' in the option definition
      # then mark that option as a flag 
      if ! [[ -z "$3" ]]; then
        _flags_[$_opt_]=1
      fi
    done
  done
}

function parseopts {
  #echo "1=$1 2=$2 3=$3 4=$4"
  local defs_=$2
  local -n opts_=$3
  # clear opts_
  opts_=()
  local -n posargs_=$4
  local -A flags_=()
  local -A names_=()

  _err_=0
 
  # parses the space-separated strings
  # of the first argument into position arguments
  # e.g. if the provided ${args[*]} is "--option value"
  # then $1='--option' and $2='--value' 
  set -- $1
  denormopts "$defs_" names_ flags_

  while (( $# )); do
    # Return _err_=1 if the provided
    # option was not defined
    [[ -z "${names_[$1]}" ]] && {
      _err_=1
      return
    }

    # If option is not a flag, store its value in
    # the return hash
    if [[ -z "${flags_[$1]}" ]]; then
      opts_+=( "${names_[$1]}=$2" )
      shift
    else
      opts_+=( "${names_[$1]}=1" )
    fi
    shift
  done
}

main () {
  hello_world
}


# Exit and don't run main if script is being sourced
sourced && return

main "$@"


