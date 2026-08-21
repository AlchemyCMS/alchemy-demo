require "test_helper"

class SyntaxHighlightHelperTest < ActionView::TestCase
  include SyntaxHighlightHelper

  test "highlight_code wraps recognised tokens in spans and is html safe" do
    html = highlight_code("name: hero", "yaml")

    assert_includes html, "<span"
    assert_includes html, "hero"
    assert_predicate html, :html_safe?
  end

  test "highlight_code falls back to plain escaped text for unknown languages" do
    html = highlight_code("a < b", "nonsense")

    assert_includes html, "a &lt; b"
  end
end
