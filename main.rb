#!/usr/bin/env ruby

require './errors.rb'
require './lexical_token.rb'
require './lexical_analyzer.rb'
require './node.rb'
require './abstract_syntax_tree.rb'
require './parser.rb'
require './translator.rb'
require './vm.rb'

# This is the main class of the Galactic Notes program. It gets input from the user
# and manages the interactions between the lexical analyzer, the parser and the
# virtual machine. 
class Main
  # This method creates a new Main object.
  # - options: a Hash representing the passed options
  def initialize(options)
    # First handle any options passed
    @ignore_case = false
    @unit_test = false
    if options.respond_to?("include?")
      if options.include?(:ignore_case) and options[:ignore_case] == true
        @ignore_case = true
      end
      if options.include?(:unit_test) and options[:unit_test] == true
        @unit_test = true
      end
    end

    # Next initialize the names of all the error classes
    @err_classes = {
      :ast_err_class => ASTreeError,
      :lexer_err_class => LexerError,
      :main_err_class => MainError,
      :parser_err_class => ParserError,
      :translator_err_class => TranslatorError,
      :vm_err_class => VMError
    }
    @main_err_class = @err_classes[:main_err_class]

    # Then initialize rules for Lexical Analyzer 
    if @ignore_case == true # Case Insensitive Rules
      @lexer_rules = {
        "HOW" => "HOW",
        "MANY" => "MANY",
        "MUCH" => "MUCH",
        "IS" => "IS",
        "QUIT" => "QUIT",
        "CREDITS" => "CREDITS",
        "[[:alpha:]]+" => "VARIABLE",
        "[0-9]+\\.[0-9]+|[0-9]+" => "NUMBER",
        "\\?" => "QUESTION",
        "\\s" => "WS",
        "\n" => "EOL"
      }
    else # Case Sensitive Rules
      @lexer_rules = {
        "how" => "HOW",
        "many" => "MANY",
        "much" => "MUCH",
        "is" => "IS",
        "quit" => "QUIT",
        "Credits" => "CREDITS",
        "[[:alpha:]]+" => "VARIABLE",
        "[0-9]+\\.[0-9]+|[0-9]+" => "NUMBER",
        "\\?" => "QUESTION",
        "\\s" => "WS",
        "\n" => "EOL"
      }
    end

    # Initialize Virtual Machine memory locations
    @variables = {
      :I =>    1,
      :V =>    5,
      :X =>   10,
      :L =>   50,
      :C =>  100,
      :D =>  500,
      :M => 1000
    }

    # Initialize input history
    @history = []

    # Store the names of certain classes to inject into certain objects
    @token_class = Token
    @node_class = Node
    @ast_class = ASTree

    # Finally, initialize Lexical Analyzer, Parser, Translator and Virtual Machine
    @lexer = Lexer.new(@token_class, @err_classes[:lexer_err_class], @lexer_rules) 
    @parser = Parser.new(@node_class, @err_classes[:parser_err_class])
    @translator = Translator.new(@err_classes[:translator_err_class])
    @vm = VM.new(@err_classes[:vm_err_class], @variables)
  end

  # This method processes an array of input strings 
  # and outputs them to output_stream
  # - inputs: an Array of input strings
  # - output: a stream used for output
  # - err: a stream used for reporting errors
  def batch_process(inputs = [], output = STDOUT, err = STDERR)
    # First ensure inputs is an array
    if !inputs.respond_to?("each")
      raise @main_err_class, "batch_process needs an array for inputs!"
    end
    inputs.each do |input|
      process_input(input, output, err, false)
    end
  end

  # This method processes one statement from input
  # (which can be a stream or a string) and outputs
  # the result to output. 
  # - input: a String or Stream containing the users input
  # - output: a stream used for output
  # - err: a stream used for reporting errors
  # - ret_val: whether or not to return anything to parent
  def process_input(input = STDIN, output = STDOUT, err = STDERR, ret_val = true)
    # First make sure input, output and err are valid streams/strings
    if input.respond_to?("gets")
      is_input_stream = true
    elsif input.kind_of?(String)
      is_input_stream = false
    else
      raise @main_err_class, "You must pass either a string or a stream for input!"
    end
    if !output.respond_to?("print") or !output.respond_to?("puts")
      raise @main_err_class, "You must pass a valid stream for output!"
    end
    if !err.respond_to?("print") or !err.respond_to?("puts")
      raise @main_err_class, "You must pass a valid stream for err!"
    end

    # Get user input differently if input is a stream or string
    output.print "Enter Input: "
    if is_input_stream
      inp = input.gets.chomp
    else
      inp = input
      output.puts(inp) # Display input just as if it were typed
    end

    # If @ignore_case is true, convert inp to upper case
    if @ignore_case == true
      inp = inp.upcase
    end

    # Add input to @history
    @history.push(inp)

    # Process user input
    begin
      # First, use Lexical Analyzer to convert input into an Array of tokens
      tokens = @lexer.tokenize(inp, true)
      tokens.each do |token|
        output.print(token.to_s + " ")
      end
      output.puts("")
      # Next, create the Abstract Syntax Tree to use for this iteration
      ast = @ast_class.new(@node_class, @err_classes[:ast_err_class])
      # Then, parse the tokens into the Abstract Syntax Tree & return result
      ast = @parser.parse(tokens, ast)
      output.puts(ast.to_s)
      # Then, generate virtual machine code from the Abstract Syntax Tree
      code = @translator.translate(ast)
      code.each do |line|
        output.puts(line)
      end
      # Finally, execute code on the Virtual Machine
      #code.each do |line|
      #  @vm.execute(line)
      #end
      while !code.empty?
        @vm.execute(code.pop)
        if @vm.has_output?
          output.puts(@vm.output)
        end
        if @vm.halt? and ret_val
          return false
        end
      end
    rescue ASTreeError, LexerError, ParserError, TranslatorError, VMError => e
      err.puts e.message
    ensure
      if ret_val
        return true
      end
    end
  end
end

# This block is called when this file is invoked directly.
if __FILE__ == $0
  # First handle command line arguments
  options = {} # Stores values of command line flags
  inputs = [] # Stores statements read from input files
  ARGV.each do |a|
    case a
    when "-i"
      options[:ignore_case] = true
    when "-u"
      options[:unit_test] = true
    else # The program considers anything else a filename
      begin
        file = File.open(a)
        while !file.eof
          inputs.push(file.readline.chomp)
        end
      rescue
        STDERR.puts "Cannot open file: #{a}!"
      ensure
        file.close()
      end
    end
  end

  # Flush STDIN to prevent input from spilling over into main loop
  STDIN.flush

  main = Main.new(options)
  # Process any input files
  main.batch_process(inputs, STDOUT, STDERR)
  # Enter main input loop
  loop do
    main.process_input(STDIN, STDOUT, STDERR)
  end 
end
