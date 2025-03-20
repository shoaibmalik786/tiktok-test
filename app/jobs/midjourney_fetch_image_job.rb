require 'open-uri'

class MidjourneyFetchImageJob < ApplicationJob
  def perform(image_id:, ad_item_id:)
    request = Imagineapi::FetchImage.new(image_id: image_id)
    response = request.process

    if response["data"]["status"] == 'pending'
      MidjourneyFetchImageJob.set(wait: 10.seconds).perform_later(image_id: image_id, ad_item_id: ad_item_id)
    else
      ad_item = AdItem.find(ad_item_id)

      ad_item.attach_image(response["data"]["url"]) if response["data"]["url"].present?
    end
  end
end
