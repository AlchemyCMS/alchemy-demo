# This migration comes from alchemy (originally 20160422195310)
class AddImageFileFormatToAlchemyPictures < ActiveRecord::Migration
  def up
    add_column :alchemy_pictures, :image_file_format, :string
  end

  def down
    remove_column :alchemy_pictures, :image_file_format
  end
end
