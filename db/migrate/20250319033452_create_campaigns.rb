class CreateCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :landing_page_url
      t.text :description
      t.boolean :generating_prompts

      t.timestamps
    end
  end
end
