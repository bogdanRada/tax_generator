module TaxGenerator
  # node from the tree
  class TaxonomyNode < Tree::TreeNode
    def print_tree(level = 0, max_depth = nil, block = ->(node, prefix) { puts "#{prefix} #{node.respond_to?(:name) ? node.name : node}" })
      prefix = fetch_prefix_for_printing(level)
      block.call("#{name}---#{content}", prefix)
      return unless max_depth.nil? || level < max_depth # Exit if the max level is defined, and reached.

      children { |child| child.print_tree(level + 1, max_depth, block) if child } # Child might be 'nil'
    end

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
