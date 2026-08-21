module AlchemyRevealHelper
  ELEMENTS_YML = Rails.root.join("config", "alchemy", "elements.yml")

  # The element's definition exactly as written in config/alchemy/elements.yml,
  # so the "reveal" shows the real YAML rather than a paraphrase.
  def element_definition_yaml(element)
    extract_yaml_block(File.read(ELEMENTS_YML), element.name)
  end

  # Admin deep link to edit this element. The public site renders the published
  # page version, but the admin editor works on the draft version, so resolve
  # the matching draft element (by name + position) and anchor to its editor id.
  def admin_element_url(element)
    page = element.page
    return unless page

    editable = element
    if (draft = page.draft_version)
      scope = Alchemy::Element.where(page_version_id: draft.id, name: element.name)
      editable = scope.find_by(position: element.position) || scope.first || element
    end
    alchemy.edit_admin_page_path(page, anchor: "element_#{editable.id}")
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
