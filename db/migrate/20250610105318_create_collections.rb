class CreateCollections < ActiveRecord::Migration[7.1]
  def change
    create_table :collections do |t|
      t.string :name
      t.string :url_image

      t.timestamps
    end
  end
end
