require "test_helper"

# Unit-tests the reveal deep-link resolution logic with lightweight stand-ins
# for Alchemy's element/version/page, so it needs no database or demo seed.
# The real ActiveRecord path is smoke-covered by published_pages_test, which
# renders the reveals (and thus calls these helpers) against seeded data.
class AlchemyRevealDeepLinkTest < ActiveSupport::TestCase
  include AlchemyRevealHelper

  Page = Struct.new(:id, :draft_version, keyword_init: true)
  Element = Struct.new(:id, :name, :position, :parent_element, :page, keyword_init: true)

  # Stands in for a PageVersion whose `elements` association supports the same
  # find_by(name:, position:, parent_element_id:) call the helper makes.
  class FakeVersion
    attr_reader :id

    def initialize(id, elements)
      @id = id
      @elements = elements
    end

    def elements
      Relation.new(@elements)
    end

    Relation = Struct.new(:elements) do
      def find_by(name:, position:, parent_element_id:)
        elements.find do |e|
          e.name == name && e.position == position && e.parent_element&.id == parent_element_id
        end
      end
    end
  end

  # Route proxy that the helper reaches as `alchemy` in a view context.
  def alchemy
    @alchemy ||= Object.new.tap do |proxy|
      def proxy.edit_admin_page_path(page, anchor:)
        "/admin/pages/#{page.id}/edit##{anchor}"
      end
    end
  end

  def setup
    @draft_hero = Element.new(id: 6, name: "hero", position: 1, parent_element: nil)
    @draft_grid = Element.new(id: 7, name: "concept_grid", position: 2, parent_element: nil)
    @draft_card = Element.new(id: 8, name: "concept_card", position: 1, parent_element: @draft_grid)
    @draft = FakeVersion.new(41, [@draft_hero, @draft_grid, @draft_card])

    @page = Page.new(id: 2, draft_version: @draft)
    @public_grid = Element.new(id: 33, name: "concept_grid", position: 2, parent_element: nil)
    @public_hero = Element.new(id: 32, name: "hero", position: 1, parent_element: nil, page: @page)
    @public_card = Element.new(id: 34, name: "concept_card", position: 1, parent_element: @public_grid)
  end

  test "draft_element_for maps a top-level element to its draft counterpart" do
    assert_equal @draft_hero, draft_element_for(@public_hero, @draft)
  end

  test "draft_element_for resolves a nested element under the matching draft parent" do
    assert_equal @draft_card, draft_element_for(@public_card, @draft)
  end

  test "draft_element_for returns nil without a draft version" do
    assert_nil draft_element_for(@public_hero, nil)
  end

  test "draft_element_for returns nil when the draft parent cannot be resolved" do
    orphan_parent = Element.new(id: 99, name: "missing_parent", position: 9, parent_element: nil)
    orphan = Element.new(id: 100, name: "concept_card", position: 1, parent_element: orphan_parent)

    assert_nil draft_element_for(orphan, @draft)
  end

  test "admin_element_url anchors to the resolved draft element id" do
    assert_equal "/admin/pages/2/edit#element_6", admin_element_url(@public_hero)
  end
end
