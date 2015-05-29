McGarr
======

I broke two rules:
1) I did not use a JVM-based language, because.
2) I assume that your example implies that all last children are depicted with "\_" which would mean that your example has a typo.

Other comments:
*) I saw the potential for infinite loops, so I stop a branch before it repeats.
*) I worked on this under distractions (at a conference) for about four hours.  I capture that output under "four_hour_output.txt" and I mark the approximate progress line in the code with a comment to that effect.
*) I also spent an additional hour under the same conditions and captured a 'complete' solution under "five_hour_output.txt"
*) My preference is to write code like this in separate modules, but here I stuck to the Elixir convention of leaving it bound in one file.  In this case, it makes for a better code narrative, since each function is written in order of successively transforming the input into the desired ASCII output.  Read it like a story.

To run:
*) Install Elixir if you don't have it already.  `brew install elixir` works quite well.
*) Checkout the code https://github.com/clr/mcgarr or download a zip directly from https://github.com/clr/mcgarr/archive/master.zip and unpack it.
*) From the directory where you unpack the attached, run `mix run -e McGarr.homework`  If you are unfamiliar, mix is similar to rake but will compile and run the program.  The solution output should print to the terminal.
*) TDD.  All code is documented and tested with doctests, which are awesome.  To run the doctests, run `mix test` from the directory where you unpacked the attached.  It will compile the code, extract the tests from the documentation, and run them.
