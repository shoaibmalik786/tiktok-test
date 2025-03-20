class CreateAdItems < ActiveRecord::Migration[8.0]
  def change
    create_table :ad_items do |t|
      t.references :ad_prompt
      t.integer :image_generation_model
      t.integer :image_generation_status

      t.timestamps
    end
  end
end
