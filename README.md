Galactic Notes Program
======================

Introduction
------------

This program stores "free-hand" style notes useful for keeping track of
commodity prices on the galactic market. It will give the user the Arabic 
numeral formatted value of x commodities (where x is the number of 
commodities in Galactic Numeral format {which is a format similar to
the Roman numerals of Terran history [Terra is Earth. I hope you can
follow all these nested asides]}). The user must first tell the program
the Roman numeral a Galactic numeral maps to and the current price (in Arabic
numerals) of x number of a commodity. The developer makes no claim to
universal relevance, but hopefully galactic relevance will do!

Design
---------
The Galactic Notes program implements a full "programming environment" for
the Galactic Notes language. This includes a lexical analyzer, a parser,
a translator, and a virtual machine. 

I wrote this program in Ruby, since it was the only available language that 
I had not used, and I appreciate a learning exercise and a challenge.

**NOTE:** The program functions like an interpreter,where a user inputs a 
command, and the program immediately executes it. However, it is technically 
a Just-In-Time (i.e. JIT) compiler, since it translates the Abstract Syntax
Tree to virtual machine code before executing it.

**NOTE:** Currently, the Virtual Machine evaluates variables (i.e. galactic 
numerals and commodity names). The other pieces of the program pass them
through without validating their existence.

Main
====

The main class manages all the other parts of the process. It handles
any startup options, handles a loop that takes input from the user,
initializes all the other program objects and injects any needed dependencies
into them. I tried to enumerate all program dependencies in this class to make
the various pieces more modular. When a component object had to create another
I at least made sure to pass the class name of the needed object in the 
component object's constructor.

Lexical Analyzer
================

The lexical analyzer takes an input string and returns the input as a series of
tokens. Valid tokens are 'how', 'many', 'much', 'is', 'Credits', '?', 'quit',
valid arabic numeral formatted number, and any sequence of alphabet characters.
**NOTE:** The lexical analyzer ignores whitespace characters.
**NOTE:** When case insensitivity mode is on, the program capitalizes tokens.

Parser
======

The parser takes an array of lexical tokens and returns an Abstract Syntax Tree 
representation of the input statement. 
The program accepts several statements:

  * assign numeral: "VARIABLE is NUMERAL" 
  * assign commodity: "VARIABLE... COMMODITY is NUMBER Credits"
  * how many: "how many Credits is VARIABLE... COMMODITY ?"
  * how much: "how much is VARIABLE... ?"
  * quit: "quit"

Translator
==========

The translator takes an Abstract Syntax Tree as input and returns an array of
"machine code" instructions (they look more like the assembly code commands of
other architectures, but the virtual machine executes them directly).

Virtual Machine
===============

The Virtual Machine takes one or more instruction statements and executes them.
With a few exceptions, it resembles a typical processor with registers,
instructions and flags.

The Virtual Machine has several registers:

  * **$ar** - general purpose register
  * **$br** - general purpose register
  * **$nr** - numeral register which stores the numeral to be PUSHed onto $sr
  * **$pr** - print register which stores the output string
  * **$rr** - stores number RET will interpolate into the output string
  * **$sr** - the stack register used to calculate the value of a number by
  PUSHing its numerals in reverse order

The Virtual Machine understands several instructions:

  * **HALT** - Set halt flag
  * **LOAD "string"** - load string into $pr
  * **MOV [%,$,]op1 [%,$]op2** - copy value of op1 into op2. If op2 is $nr,
  th**en set the nr_changed flag
  * **MUL $op1 $op1** - multiply contents of $op2 by $op1 & store result in $op2
  * **POP $op1** - copy value of $sr into $op1
  * **PUSH** - adds value of $nr onto $sr using special rules described below   
  * **RET** - interpolate value of $rr into $pr and set output flag

The Virtual Machine also has three flags:

  * **halt** - set by HALT instruction, indicates virtual machine will halt
  * **nr_changed** - set when virtual machine copies new value into $nr unset
  by next PUSH instruction
  * **output** - set by RET to indicate Virtual Machine has output to return

**NOTE:** The program evaluates Galactic Numerals in little-endian order
(i.e. right to left). When nr_changed flag is set, the VM compares numeral $nr 
with to the current total $sr. If $nr > $sr, the VM just adds $nr to $sr.
If $nr < $sr and $nr is neither 5, nor 50, nor 500, then the program subtracts
$nr from $sr. When nr_changed is not set, the program simply ensures that
$nr is neither 5, nor 50, nor 500 (since those symbols cannot appear twice) and
that the same symbol has not already been PUSHed to $sr more than twice; if this
is so, the program adds $nr to $sr. 


File Structure
--------------

The Galactic Notes program is split up into nine different source code files 
and two miscellaneous help files.

  * **abstract_syntax_tree.rb** - contains *ASTree* the class of the 
  Abstract Syntax Tree created by the parser and interpreted by the translator
  * **errors.rb** - contains the class definitions of all the various errors
  raised by the differt pieces of the program
  * **grammar.txt** - contains the Galactic Input grammar in Extended
  Backus-Naur Format (i.e. EBNF).
  * **lexical_analyzer.rb** - contains *Lexer* the class of the lexical
  analyzer takes the string inputted by the user and returns an array of all
  the lexical tokens in the string.
  * **lexical_token.rb** - contains *Token* the class of a lexical token
  created by the lexical analyzer from an input string
  * **main.rb** - the main file of the program that manages the other objects
  and takes input from the user
  * **node.rb** - contains *Node* the class of a node in the Abstract
  Syntax Tree.
  * **parser.rb** - contains *Parser* the class of the parser that takes
  an array of tokens returned by the lexical analyzer and outputs an Abstract
  Syntax Tree of the input
  * **README.md** - this file (which you should know since you opened it)
  * **test.txt** - contains the test input from the problem descriptions
  * **translator.rb** - contains *Translator* the class of the translator 
  that takes the Abstract Syntax Tree of the input and returns "machine code" 
  the virtual machine can execute
  * **vm.rb** - contains *VM* the class of the virtual machine that
  executes the inputted statement and returns the result

Running Program
---------------

To run the program, first extract the files from the archive: 
**tar -xvzf project.tar.gz** and invoke main.rb with any options.
Possible options include:

  * **-i** - ignore case sensitivity
  * **-d** - output information useful for debugging
  * **filename** (default) - read in and process input from file

Example: 

  **./main.rb -i test.txt**

This tells the program to ignore case and read in and process
input from test.txt before taking command line input.

Future Enhancements
-------------------

Here are some ways I would like to improve this program:

  * Make VM more general by adding addition, subtraction, comparison 
  and branching instructions and factor out all the special tests into
  machine code created by Translator
  * Add Symbol table so objects other than the VM can validate variables.
  This will make it easier to deal with numerals vs. commodities.
  * Either add support for saving program state to a file or adding an
  autosave feature

