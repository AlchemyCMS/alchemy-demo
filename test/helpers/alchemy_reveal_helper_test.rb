require "test_helper"

class AlchemyRevealHelperTest < ActionView::TestCase
  include AlchemyRevealHelper

  SOURCE = <<~YAML
    - name: hero
      unique: true
      ingredients:
        - role: headline
          type: Text
          default: "Hi"

    - name: cta
      ingredients:
        - role: text
          type: Richtext
  YAML

  test "extract_yaml_block returns the verbatim block for the named element" do
    expected = <<~YAML.rstrip
      - name: hero
        unique: true
        ingredients:
          - role: headline
            type: Text
            default: "Hi"
    YAML

    assert_equal expected, extract_yaml_block(SOURCE, "hero")
  end

  test "extract_yaml_block stops at the next top-level element" do
    result = extract_yaml_block(SOURCE, "cta")

    assert_equal "- name: cta\n  ingredients:\n    - role: text\n      type: Richtext", result
    refute_includes result, "hero"
  end

  test "extract_yaml_block returns nil when the element is absent" do
    assert_nil extract_yaml_block(SOURCE, "missing")
  end
end
