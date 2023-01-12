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
  local -n _getopts_=$4
  local IFS=$IFS
  local _defn_
  local _long_=''
  local _opt_
  local _short_=''

  _getopts_=( [long]='' [short]='' )
  for _defn_ in $1; do
    IFS=,
    set -- $_defn_
    IFS='|'
    for _opt_ in $1; do
      _names_[$_opt_]=$2
      case $_opt_ in
        -?  ) _short_+=,${_opt_#?};;
        *   ) _long_+=,${_opt_#??};;
      esac
      case ${3:-} in
        '' )
          case $_opt_ in
            -?  ) _short_+=: ;;
            *   ) _long_+=:  ;;
          esac
          ;;
        * ) _flags_[$_opt_]=1;;
      esac
    done
  done
  _getopts_[long]=${_long_#?}
  _getopts_[short]=${_short_#?}
}


is_enhanced_getopt () {
  # Returns true if GNU getopt is installed
  local rc
  getopt -T &>/dev/null && rc=$? || rc=$? 
  (( rc == 4 ))
}

function wrap_getopt {
  local short=$2
  local long=$3
  local result

  ! result=$(getopt -o "$short" ${long:+-l} $long -n $0 -- $1)
  case $? in
    0) echo '_err_=1; return';;
    1) echo "set -- $result";;
  esac 
}

function parseopts {
  #echo "1=$1 2=$2 3=$3 4=$4"
  local defs_=$2
  local -n opts_=$3
  # clear opts_
  opts_=()
  local -n posargs_=$4
  local -A flags_=()
  local -A getopts_=()
  local -A names_=()
  local rc_
  local result_


  _err_=0
 
  # parses the space-separated strings
  # of the first argument into position arguments
  # e.g. if the provided ${args[*]} is "--option value"
  # then $1='--option' and $2='--value' 
  set -- $1
  denormopts "$defs_" names_ flags_ getopts_

  # Check if we have enhanced getopt
  #is_enhanced_getopt && eval $(wrap_getopt "$*" "${getopts_[short]}" "${getopts_[long]}")

  echo "getopts_[short]=${getopts_[long]}"
  echo "getopts_[long]=${getopts_[short]}"
  is_enhanced_getopt && eval $(wrap_getopt "$*" "${getopts_[short]}" "${getopts_[long]}")

  # keep reading options while you encounter
  # words starting with a dash and followed by some chars
  while [[ ${1:-} == -?* ]]; do

    # stop reading options once you encounter --
    [[ $1 == -- ]] && {
      shift
      break
    }
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

  # Return remaining arguments as positional arguments
  posargs_=( "$@" )
}

main () {
  hello_world
}


# Exit and don't run main if script is being sourced
sourced && return

main "$@"


