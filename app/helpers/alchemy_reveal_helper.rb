module AlchemyRevealHelper
  ELEMENTS_YML = Rails.root.join("config", "alchemy", "elements.yml")

  # The element's definition exactly as written in config/alchemy/elements.yml,
  # so the "reveal" shows the real YAML rather than a paraphrase.
  def element_definition_yaml(element)
    extract_yaml_block(File.read(ELEMENTS_YML), element.name)
  end

  # Returns the verbatim top-level list block whose `- name:` matches, from the
  # matching line up to (but not including) the next top-level item or comment.
  def extract_yaml_block(source, name)
    lines = source.lines
    start = lines.index { |line| line.chomp =~ /\A- name:\s+#{Regexp.escape(name)}\z/ }
    return unless start

    block = [lines[start]]
    lines[(start + 1)..].each do |line|
      break if line =~ /\A(- |#)/
      block << line
    end
    block.join.rstrip
  end
end
