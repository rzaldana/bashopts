#!/usr/bin/env bash
shopt -s expand_aliases

# If running on MacOs, alias readlink to GNU readlink
OS_NAME=$(uname -s)
if [[ "$OS_NAME" == "Darwin" ]]; then
  [[ -z "$(command -v greadlink)" ]] && { echo "You're running on MacOS but GNU readlink is not installed. You can install it by running 'brew install coreutils'" ; exit 1 ; }
  alias readlink='greadlink'
fi

bashtdlib="$(dirname "$(readlink -f "$BASH_SOURCE")")"/../bashtdlib.bash
source "$bashtdlib"

describe sourced
  it "returns true when in a file that's being sourced"
    # Create temporary file
    file=$(mktemp) || return

    # Set contents of file so that it sources bashtdlib
    # and then calls the function called 'sourced'
    printf 'source "%s"\nsourced' "$bashtdlib" > "$file"

    # Source the file in a subshell
    (source $file)

    # Check that the 'sourced' function returns 0
    assert equal 0 $?

    # Remove temporary file
    rm $file
  end

  it "returns false when in a file that's being executed"
    # Create temporary file
    file=$(mktemp) || return

    # Set contents of file so that it sources bashtdlib
    # and then calls the function called 'sourced'
    printf 'source "%s"\nsourced' "$bashtdlib" > "$file"

    # Make the tmp file executable
    chmod 755 "$file"

    # Run the file directly
    "$file"

    # Check that the 'sourced' function does NOT return 0
    assert unequal 0 $?

    # Remove temporary file
    rm "$file"
  end

end

describe parseopts
  it "returns a short flag"
    defs=( '-o,o_flag,f' )
    args=( '-o' )
    parseopts "${args[*]}" "${defs[*]}" options posargs
    assert equal o_flag=1 $options
  end

  it "returns _err_=1 if the argument isn't defined"
    defs=( -o,o_flag,f )
    args=( --other )
    parseopts "${args[*]}" "${defs[*]}" options posargs
    assert equal 1 $_err_
  end

  it "returns a named argument"
    defs=( --option,option_val )
    args=( --option sample )
    parseopts "${args[*]}" "${defs[*]}" options posargs
    assert equal option_val=sample $options
  end

  it "returns a named argument and a flag"
    defs=(
      "--option,option_val"
      "-p,p_flag,f"
    )

    args=(--option sample -p)
    parseopts "${args[*]}" "${defs[*]}" options posargs
    expecteds=(
      option_val=sample
      p_flag=1
    )

    assert equal "${expecteds[*]}" "${options[*]}"
  end
end
