class Location < ActiveRecord::Base
  extend Alchemy::SearchableResource

  has_many :events, dependent: :nullify

  validates :name, presence: true
end
