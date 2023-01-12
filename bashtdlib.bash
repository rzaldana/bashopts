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
      [[ -z "$3" ]] && _flags_[$_opt_]=1
    done
  done
}

function parseopts {
  local defs_=$2
  local -n opts_=$3
  local -n posargs_=$4
  local -A flags_=()
  local -A names_=()

  _err_=0
  
  set -- $1
  denormopts "$defs_" names_ flags_

  # Return _err_=1 if the provided
  # option was not defined
  [[ -z "${names_[$1]}" ]] && {
    _err_=1
    return
  }

  opts_="${names_[$1]}=1"
}

main () {
  hello_world
}


# Exit and don't run main if script is being sourced
sourced && return

main "$@"


