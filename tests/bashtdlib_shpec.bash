# If running on MacOs, alias readlink to GNU readlink
OS_NAME=$(uname -s)
if [[ "$OS_NAME" == "Darwin" ]]; then
  [ -z "$(command -v greadlink)" ] && { echo "You're running on MacOS but GNU readlink is not installed. You can install it by running 'brew install coreutils'" ; exit 1 ; }
  alias readlink=greadlink
fi

bashtdlib="$(dirname "$(readlink -f "$BASH_SOURCE")")"/../bashtdlib.bash

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
