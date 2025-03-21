class AdPrompt < ApplicationRecord
  belongs_to :campaign
  has_many :ad_items

  def generate_images
    wait = 1
    AdItem.image_generation_models.keys.each do |model|
      ad_item = ad_items.find_or_create_by(image_generation_model: model)
      ad_item.update(image_generation_status: :started)

      wait_time = model == 'mid_journey' ? (wait + 20).seconds : wait.seconds

      GenerateImageJob.set(wait: wait_time).perform_later(ad_item_id: ad_item.id)

      wait += 10
    end
  end
end
