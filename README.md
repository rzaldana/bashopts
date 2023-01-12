# bash-stdlib
A Bash library and CLI utility to easily create enhanced Bash scripts.

## Tests
To run test, run `make test` from the root directory of the repo.
If running on MacOS, you will need GNU readlink installed on your machine. You can install it with brew: `brew install coreutils`.

## Getopt
These scripts work better when using GNU getopt.
If you're on a Mac, you can install GNU getopt with the following command: `brew install gnu-getopt`.
If you don't have GNU getopt in your path, the scripts will default to more basic funtionality for the parser, so things like using equal signs with long options (e.g. --long=arg) won't work.

# Parseopts
The functionality of the parseopts functions is mainly derived from binary.phile's excellent series on [Approaching Bash like a Developer](https://www.binaryphile.com/bash/2018/09/28/approach-bash-like-a-developer-part-30-option-parsing.html)
