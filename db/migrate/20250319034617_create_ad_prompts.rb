class CreateAdPrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :ad_prompts do |t|
      t.references :campaign
      t.text :content
      t.boolean :generating_ad_items

      t.timestamps
    end
  end
end
