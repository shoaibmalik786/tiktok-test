class Campaign < ApplicationRecord
  has_many :ad_prompts, dependent: :destroy
  has_many :ad_items, through: :ad_prompts

  def generate_prompts
    update(generating_prompts: true)

    GeneratePromptsJob.perform_later(campaign_id: id)
  end

  def generate_images
    ad_prompts.each do |ad_prompt|
      ad_prompt.generate_images
    end
  end
end
