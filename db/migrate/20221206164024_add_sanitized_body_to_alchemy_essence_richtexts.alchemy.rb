# frozen_string_literal: true
# This migration comes from alchemy (originally 20210326105046)

class AddSanitizedBodyToAlchemyEssenceRichtexts < ActiveRecord::Migration[6.0]
  def change
    add_column :alchemy_essence_richtexts, :sanitized_body, :text
  end
end
