class AdPrompt < ApplicationRecord
  belongs_to :campaign
  has_many :ad_items

  def generate_images
    update(generating_ad_items: true)
    wait = 1

    AdItem.image_generation_models.keys.each do |model|
      wait_time = model == 'mid_journey' ? (wait + 20).seconds : wait.seconds

      GenerateImageJob.set(wait: wait_time).perform_later(ad_prompt_id: id, model: model)

      wait += 10
    end
  end
end
