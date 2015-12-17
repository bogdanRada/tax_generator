require_relative '../helpers/application_helper'
module TaxGenerator
  # class used to create the Taxonomy Tree
  #
  # @!attribute root_node
  #   @return [Tree::TreeNode] the root node of the tree
  #
  # @!attribute document
  #   @return [Nokogiri::XML] the xml document used to build the tree
  class TaxonomyTree
    include TaxGenerator::ApplicationHelper
    attr_reader :root_node, :document

    #  receives a file path that will be parsed and used to build the tree
    # @see Tree::TreeNode#new
    # @see #add_node
    #
    # @param  [String]  file_path the path to the xml file that will be parsed and used to build the tree
    #
    # @return [void]
    #
    # @api public
    def initialize(file_path)
      @document = nokogiri_xml(file_path)
      taxonomy_root = @document.at_xpath('//taxonomy_name')
      @root_node = Tree::TreeNode.new('0', taxonomy_root.content)
      @document.xpath('.//taxonomy/node').pmap do |taxonomy_node|
        add_node(taxonomy_node, @root_node)
      end
    end

    #  finds a node by the name in the tree list
    #
    # @param  [String]  node_id the name of the node that needs to be found
    # @param  [Tree::TreeNode]  node the node that will be used to search in
    # @param  [Array]  list the list that holds the nodes
    #
    # @return [void]
    #
    # @api public
    def find_by_name(node_id, node = @root_node, list = [])
      if node.name.to_s == node_id.to_s
        list << node
      else
        node.children.each { |child| find_by_name(node_id, child, list) }
      end
      list.compact
    end

    #  gets the atlas_id from the nokogiri element and then searches first child whose name is 'node_name'
    # and uses this to insert the node
    # @see #insert_node
    #
    # @param  [Nokogiri::Element]  taxonomy_node the nokogiri element that wants to be added to the tree
    # @param  [Tree::TreeNode]  node the parent node to which the element needs to be added
    #
    # @return [void]
    #
    # @api public
    def add_taxonomy_node(taxonomy_node, node)
      atlas_node_id = taxonomy_node.attributes['atlas_node_id']
      node_name = taxonomy_node.children.find { |child| child.name == 'node_name' }
      insert_node(atlas_node_id, node_name, node)
    end

    #  inserts a new node in the tree by checking first if atlas_id and node_name are present
    # and then adds the node as child to the node passed as third argument
    # @see Tree::TreeNode#new
    #
    # @param  [Nokogiri::Element]  atlas_node_id the element that holds the value of the atlas_id attribute
    # @param  [Nokogiri::Element]  node_name the the element that holds the node name of the element
    # @param  [Tree::TreeNode]  node the parent node to which the element needs to be added
    #
    # @return [void]
    #
    # @api public
    def insert_node(atlas_node_id, node_name, node)
      return if atlas_node_id.blank? || node_name.blank?
      current_node = Tree::TreeNode.new(atlas_node_id.value, node_name.content)
      node << current_node
      current_node
    end

    #  checks to see if the nokogiri element has any childrens, if it has , will add it to the tree and iterates over the
    # children and adds them as child to the newly added node
    # @see #add_taxonomy_node
    #
    # @param  [Nokogiri::Element]  taxonomy_node the nokogiri element that wants to be added to the tree
    # @param  [Tree::TreeNode]  node the parent node to which the element needs to be added
    #
    # @return [void]
    #
    # @api public
    def add_node(taxonomy_node, node)
      tax_node = add_taxonomy_node(taxonomy_node, node)
      return unless taxonomy_node.children.any?
      taxonomy_node.xpath('./node').pmap do |child_node|
        add_node(child_node, tax_node) if tax_node.present?
      end
    end

    #  receives a file path that will be parsed and used to build the tree
    #
    # @param  [String]  name the name of the method that is invoked against the tree
    # @param  [Array]  args the arguments to the method
    # @param  [Proc]  block the block that will be passed to the method
    #
    # @return [void]
    #
    # @api public
    def method_missing(name, *args, &block)
      @root_node.send name, *args, &block
    end
  end
end
