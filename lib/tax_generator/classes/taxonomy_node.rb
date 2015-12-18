module TaxGenerator
  # node from the tree
  class TaxonomyNode < Tree::TreeNode
    #  prints the entire tree with name and content
    #
    # @param  [Integer]  level the level of the current node, Default 0
    # @param  [Integer]  max_depth the maximum depth the tree must be printed. Default nil
    # @param  [Lambda]  block the lambda that will be executed for printing node name and content
    #
    # @return [String]
    #
    # @api public
    def print_tree(level = 0, max_depth = nil, block = ->(node, prefix) { puts "#{prefix} #{node.respond_to?(:name) ? node.name : node}" })
      prefix = fetch_prefix_for_printing(level)
      block.call("#{name}---#{content}", prefix)
      return unless max_depth.nil? || level < max_depth # Exit if the max level is defined, and reached.

      children { |child| child.print_tree(level + 1, max_depth, block) if child } # Child might be 'nil'
    end

    #  builds up the prefix needed to display for current node
    #
    # @param  [Integer]  level the level of the current node
    #
    # @return [String]
    #
    # @api public
    def fetch_prefix_for_printing(level)
      prefix = ''
      if is_root?
        prefix << '*'
      else
        prefix << '|' unless parent.is_last_sibling?
        prefix << (' ' * (level - 1) * 4)
        prefix << (is_last_sibling? ? '+' : '|')
        prefix << '---'
        prefix << (has_children? ? '+' : '>')
      end
      prefix
    end
  end
end
