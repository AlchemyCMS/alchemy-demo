module AlchemyRevealHelper
  # Introspects a live Alchemy element into a plain hash describing how it is
  # built, so the "reveal" partial can show an always-accurate definition.
  def element_source(element)
    {
      name: element.name,
      ingredients: element.ingredients.map { |i| [i.role, i.type.to_s.demodulize] },
      nested: element.nested_elements.map(&:name)
    }
  end
end
