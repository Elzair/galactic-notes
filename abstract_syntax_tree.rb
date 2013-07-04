
# This class represents the Abstrax Syntax Tree generated by the parser.
class ASTree
  attr_accessor :root    # the root node

  # This method creates a new Abstract Syntax Tree.
  # - node_class: the name of the class representing a node in the tree
  # - root: a Node representing the @root of this Abstract Syntax Tree
  def initialize(node_class, root = nil)
    @node_class = node_class
    @root = root
  end

  # This method inserts a new node into the tree.
  # - node: the Node to be inserted
  # - curr_node: the Node under which to insert node
  def insert(node = nil, curr_node = @root)
    # Ensure node is a valid node
    if node == nil or !node.is_a?(@node_class)
      raise ParserError, "Error! Invalid node!"
    end

    # If ASTree is empty, insert node at root 
    if curr_node == @root and @root == nil
      if node.is_root == true
        @root = node
      else
        raise ParserError, "Invalid root node: " + node.to_s
      end
    elsif curr_node == nil
      raise ParserError, "Cannot add a subnode to a nil node!"
    # If @root contains an element, add node as a child node to curr_node
    else
      insert_child_node(node, curr_node)
    end 
  end

  # This method inserts a non-root node into the Abstract Syntax Tree.
  # - node: the Node to be inserted
  # - curr_node: the Node under which to insert node
  def insert_child_node(node, curr_node)
    if node.is_root == false
      if curr_node.is_leaf == false
        curr_node.children.push(node)
      else
        raise ParserError, "Cannot add child node to leaf node!"
      end
    else
      raise ParserError, "Cannot insert more than one root node!"
    end
  end

  # This method returns the first node in the Abstract Syntax Tree 
  # matching the specified attributes.
  # - attributes: a Hash containing the Node fields to match
  # returns: the first node matching the specified attributes (nil if no match)
  def seek(attributes)
    result = seek_r(attributes, @root)
    if result == nil
      raise ParserError, "No match found for " + attributes.to_s + "!"
    else
      return result
    end
  end

  # This method recursively examines every node (starting with curr_node)
  # for a node matching the specified attributes.
  # - attributes: a Hash containing the Node fields to match
  # - curr_node: the node with which to start the search
  # returns: the first node matching the specified attributes (nil if no match)
  def seek_r(attributes = {}, curr_node = @root)
    # Examine all keys/value pairs in attributes & ensure they are all
    # equivalent to a corresponding attribute in curr_node
    match = true
    attributes.keys.each do |key|
      if !@node_class.public_instance_methods.include?(key) || curr_node.send(key) != attributes[key]
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
