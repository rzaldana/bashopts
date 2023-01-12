function hello_world {
  echo "hello, world!"
}

function sourced {
  # Returns:
  #   0 if the function is called in a file that's being sourced
  #   1 if the function is called in a file that's being executed
  [[ ${FUNCNAME[1]} == source ]]
}

main () {
  hello_world
}


# Exit and don't run main if script is being sourced
sourced && return

main "$@"


