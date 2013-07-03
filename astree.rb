
# This class represents a node in the Abstract Syntax Tree
class Node
  attr_accessor :name      # Name of node
  attr_accessor :value     # Value of node
  attr_accessor :children  # Array of child Nodes
  attr_accessor :is_root   # Whether or not this node is a root node
  attr_accessor :is_leaf   # Whether or not this node is a leaf node

  # This method creates a new node
  # - name: a String representing the name of this node
  # - value: an Object representing the value of this node
  #          (should be nil unless node is a leaf node)
  # - children: an Array of child Nodes of this node
  # - is_root: whether or not this node is a root node
  # - is_leaf: whether or not tis node is a leaf node
  def initialize(name = "", value = nil, children = [], is_root = false, is_leaf = false)
    @name = name
    @value = value
    @children = children
    @is_root = is_root
    @is_leaf = is_leaf
  end

  # This method returns a String representation of this node.
  # NOTE: For Debugging purposes only!
  # - show_children: whether or not to include child nodes
  # return: a String of the attributes of this node (and possibly child nodes)
  def to_s(show_children = true)
    # Since @value can be nil & nil does not have a to_s method
    # we need to specify nil some other way 
    out = "[ " + @name + " "
    if @value == nil
      out = out + "nil "
    else
      out = out + @value.to_s + " "
    end
    # If show_children is true, show child nodes in brackets
    if show_children == true
      if @children == []
        out = out + "[] "
      else
        children.each do |child|
          out = out + child.to_s
        end
      end
    end
    out = out + @is_root.to_s + " " + @is_leaf.to_s + " ] "
    return out
  end
end

# This class represents the Abstrax Syntax Tree generated by the parser.
class AST
  attr_accessor :root    # the root node

  # This method creates a new AST
  # - root: a Node representing the @root of this AST
  def initialize(root = nil)
    @root = root
  end

  # This method inserts a new node into the tree.
  # - node: the Node to be inserted
  # - curr_node: the Node under which to insert node
  def insert(node = nil, curr_node = @root)
    # Ensure node is a valid node
    if node == nil or !node.is_a?(Node)
      raise ParseError, "Error! Invalid node!"
    end

    # If AST is empty, insert node at root 
    if curr_node == @root and @root == nil
      if node.is_root == true
        @root = node
      else
        raise ParseError, "Invalid root node: " + node.to_s
      end
    elsif curr_node == nil
      raise ParseError, "Cannot add a subnode to a nil node!"
    # If AST is nonempty, add node as a child node to curr_node
    else
      insert_child_node(node, curr_node)
    end 
  end

  # This method inserts a non-root node into the AST.
  # - node: the Node to be inserted
  # - curr_node: the Node under which to insert node
  def insert_child_node(node, curr_node)
    if node.is_root == false
      if curr_node.is_leaf == false
        curr_node.children.push(node)
      else
        raise ParseError, "Cannot add child node to leaf node!"
      end
    else
      raise ParseError, "Cannot insert more than one root node!"
    end
  end

  # This method returns the first node in the AST matching 
  # the specified attributes.
  # - attributes: a Hash containing the Node fields to match
  # returns: the first Node matching the specified attributes (nil if no match)
  def seek(attributes)
    result = seek_r(attributes, @root)
    if result == nil
      raise ParseError, "No match found for " + attributes.to_s + "!"
    else
      return result
    end
  end

  # This method recursively examines every node (starting with curr_node)
  # for a node matching the specified attributes.
  # - attributes: a Hash containing the Node fields to match
  # - curr_node: the Node with which to start the search
  # returns: the first Node matching the specified attributes (nil if no match)
  def seek_r(attributes = {}, curr_node = @root)
    # Examine all keys/value pairs in attributes & ensure they are all
    # equivalent to a corresponding attribute in curr_node
    match = true
    attributes.keys.each do |key|
      #puts Node.public_instance_methods.to_s + " " + curr_node.send(key) + " " + attributes[key]
      if !Node.public_instance_methods.include?(key) || curr_node.send(key) != attributes[key]
        match = false 
      end
    end
    if match == true
      return curr_node
    # Return nil if curr_node is a leaf node
    elsif curr_node.is_leaf == true 
      return nil
    else
      # If a child node (or one of its children) contains a match, then
      # return it. Otherwise, examine the next child node.
      curr_node.children.each do |child|
        result = seek_r(attributes, child)
        if result != nil
          return result 
        end
      end
      # Return nil if no child node (or subnode) matches
      return nil
    end
  end

  # This method returns a string representation of the Abstract Syntax Tree
  # where every node at the current depth is on the same line.
  # returns: a (possibly) multiline String containing all the data in the tree
  def to_s
    output = []
    output << @root.to_s(false)
    next_level = @root.children
    # Repeat until no node at the current depth has children
    while next_level != []
      row_output = []
      curr_level = next_level
      next_level = []
      # Display all nodes at the current depth & get their children
      curr_level.each do |node|
        row_output << node.to_s(false)
        next_level = next_level + node.children
      end
      output << row_output.join(" ")
    end
    return output.join("\n")
  end
end