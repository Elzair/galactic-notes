
# This class represents the translator that takes an Abstract Syntax Tree
# returned from the parser and generates code to run on the Virtual Machine.
class Translator
  # This method creates a new Translator object.
  # - err_class: the class name of the error to raise
  def initialize(err_class)
    @err_class = err_class
  end

  # This method generates virtual machine code from the input
  # Abstract Syntax Tree.
  # NOTE: The statements are generated in the reverse order that
  # they are to be executed. That is why they are popped off a stack.
  # - ast: the Abstract Syntax Tree
  # - returns: an Array of Strings containing virtual machine code
  def translate(ast = nil)
    # Ensure that ast is a valid Abstract Syntax Tree
    if ast == nil or !ast.respond_to?("root") or ast.root == nil
      raise @err_class, "The Abstract Syntax Tree is either invalid or empty!"
    else
      @ast = ast
      @code = []
    end

    # Get root node
    curr_node = ast.root
    if curr_node.name == "QUIT"
      @code.push("HALT")
    elsif curr_node.name == "HOWMANY" or curr_node.name == "HOWMUCH"
      translate_query(curr_node)
    elsif curr_node.name == "ASSIGN"
      translate_assign(curr_node)
    end

    # Add common initialization code used in all statements
    @code.push("CLR $ar") # Clear general purpose register #1
    @code.push("CLR $br") # Clear general purpose register #2
    @code.push("CLR $nr") # Clear numeral register
    @code.push("CLR $rr") # Clear return register
    @code.push("CLR $sr") # Clear stack register

    # Return virtual machine code
    return @code
  end

  # This method generates code for a query statement.
  def translate_query(curr_node = nil)
    # First handle errors
    if curr_node == nil
      raise @err_class, "Malformed Query Statement!"
    end

    # Add code to return result of query
    @code.push("RET")

    # Next initialize output string
    out_str = ""

    # Generate code for a valid HOWMANY query
    if curr_node.name == "HOWMANY"
      if curr_node.children[0].name == "GALNUMBER" and \
         curr_node.children[1].name == "COMMODITY"
        @code.push("MOV $ar $rr") # Move contents of gp register #1 into return register
        @code.push("MUL $br $ar") # Multiply gp register #1 by gp register #2
        # Move contents of memory location into gp register #1
        @code.push("MOV %#{curr_node.children[1].value} $ar")
        @code.push("POP $br") # Pop value of stack register into $br 
        curr_node.children[0].children.each do |num|
          out_str = out_str + num.value + " "
          @code.push("PUSH") # Push numeral register onto stack register
          @code.push("MOV %#{num.value} $nr")
        end
        out_str = out_str + curr_node.children[1].value + " is $rr Credits"
        @code.push("LOAD '#{out_str}'") # Load out_str into string register
      else
        raise @err_class, "Malformed HOWMANY statement!"
      end
    # Generate code for a valid HOWMUCH query
    elsif curr_node.name == "HOWMUCH"
      if curr_node.children[0].name == "GALNUMBER"
        @code.push("MOV $br $rr")
        @code.push("POP $br")
        curr_node.children[0].children.each do |num|
          out_str = out_str + num.value + " "
          @code.push("PUSH")
          @code.push("MOV %#{num.value} $nr")
        end
        out_str = out_str + "is $rr"
        @code.push("LOAD '#{out_str}'")
      else
        raise @err_class, "Malformed HOWMUCH statement!"
      end
    end
  end

  # This method generates code for an assign statement.
  def translate_assign(curr_node = nil)
    # First handle errors
    if curr_node == nil or curr_node.name != "ASSIGN"
      raise @err_class, "Malformed Assign Statement!"
    end

    # Generate code for a valid numeral assignment
    if curr_node.children[0].name == "GALNUMERAL" and \
       curr_node.children[1].name == "GALNUMERAL"
      @code.push("MOV $ar %#{curr_node.children[0].value}")
      @code.push("MOV %#{curr_node.children[1].value} $ar")
    # Generate code for a valid commodity assignment
    elsif curr_node.children[0].name == "GALNUMBER" and \
          curr_node.children[1].name == "COMMODITY" and \
          curr_node.children[2].name == "NUMBER"
      # Move result of division into memory location
      @code.push("MOV $ar %#{curr_node.children[1].value}")
      @code.push("DIV $br $ar") # Divide $ar by $br & store result in $ar
      @code.push("POP $br")
      curr_node.children[0].children.each do |num|
        @code.push("PUSH")
        @code.push("MOV %#{num.value} $nr")
      end 
      # Move number into $ar
      @code.push("MOV #{curr_node.children[2].value} $ar")
    else
      raise @err_class, "Malformed ASSIGN statement!"
    end

  end
end
