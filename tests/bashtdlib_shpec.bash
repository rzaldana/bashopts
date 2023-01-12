# If running on MacOs, alias readlink to GNU readlink
OS_NAME=$(uname -s)
if [[ "$OS_NAME" == "Darwin" ]]; then
  [ -z "$(command -v greadlink)" ] && { echo "You're running on MacOS but GNU readlink is not installed. You can install it by running 'brew install coreutils'" ; exit 1 ; }
  alias readlink=greadlink
fi

source "$(dirname "$(readlink -f "$BASH_SOURCE")")"/../bashtdlib.bash

describe bashtdlib
  it "says 'hello world!'"
    result=$(hello_world)
    assert equal "hello, world!" "$result"
  end
end
