module AlchemyRevealHelper
  ELEMENTS_YML = Rails.root.join("config", "alchemy", "elements.yml")

  # The element's definition exactly as written in config/alchemy/elements.yml,
  # so the "reveal" shows the real YAML rather than a paraphrase.
  def element_definition_yaml(element)
    extract_yaml_block(File.read(ELEMENTS_YML), element.name)
  end

  # Admin deep link to edit this element. The public site renders the published
  # page version, but the admin editor works on the draft version, so anchor to
  # the matching draft element (falling back to the rendered one).
  def admin_element_url(element)
    page = element.page
    return unless page

    editable = draft_element_for(element, page.draft_version) || element
    alchemy.edit_admin_page_path(page, anchor: "element_#{editable.id}")
  end

  # The element in the draft version matching the given (published) element,
  # matched by name and position within the same parent so nested elements
  # resolve too. Returns nil when no match exists.
  def draft_element_for(element, draft_version)
    return unless draft_version

    draft_parent = nil
    if (parent = element.parent_element)
      draft_parent = draft_element_for(parent, draft_version)
      return if draft_parent.nil?
    end

    draft_version.elements.find_by(
      name: element.name,
      position: element.position,
      parent_element_id: draft_parent&.id
    )
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
