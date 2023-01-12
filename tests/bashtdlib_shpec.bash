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
      "--otion,option_val"
      "-p,p_flag,f"
    )

    args=(--otion sample -p)
    parseopts "${args[*]}" "${defs[*]}" options posargs
    expecteds=(
      option_val=sample
      p_flag=1
    )

    assert equal "${expecteds[*]}" "${options[*]}"
  end

  it "returns two named arguments"
    defs=( "--option,option_val" "--another,another_val" )
    args=( --option sample  --another sample2 )
    parseopts "${args[*]}" "${defs[*]}" options posargs
    expecteds=(
      option_val=sample
      another_val=sample2
    )
    assert equal "${expecteds[*]}" "${options[*]}"
  end


  it "stops when it encounters a non-option"
    defs=( "--option,option_val" "--another,another_val" )
    args=( --option sample  - --another sample2 )
    parseopts "${args[*]}" "${defs[*]}" options posargs
    expecteds=(
      option_val=sample
    )
    assert equal "${expecteds[*]}" "${options[*]}"
    assert equal "$_err_" 0
  end

  it "stops when it encounters --"
    defs=(
      --option,option_v
      -p,p_flag,f 
    )
    args=( --option sample_val -- -p )
    parseopts "${args[*]}" "${defs[*]}" ops posargs
    assert equal option_v=sample_val $ops
  end

  it "returns positional arguments"
    defs=( -o,o_flag,f )
    args=( -o one two )
    parseopts "${args[*]}" "${defs[*]}" ops posargs
    expected_ops=( o_flag=1 )
    expected_args=( one two )
    assert equal "${expected_ops[*]}" "${ops[*]}"
    assert equal "${expected_args[*]}" "${posargs[*]}"
  end

  it "accepts a short option with no space"
    defs=( -o,o_val )
    args=( -oone )
    parseopts "${args[*]}" "${defs[*]}" options posargs
    assert equal o_val=one $options
  end

end
