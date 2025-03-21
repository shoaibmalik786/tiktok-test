require 'open-uri'

class ReplicateFetchImageJob < ApplicationJob
  def perform(image_id:, ad_item_id:, retry_count: 0)
    request = Replicate::FetchImage.new(image_id: image_id)
    response = request.process

    ad_item = AdItem.find(ad_item_id)

    if response["status"] != "succeeded"
      if retry_count <= 3
        ReplicateFetchImageJob.set(wait: 10.seconds).perform_later(image_id: image_id, ad_item_id: ad_item_id, retry_count: retry_count + 1)
      else
        ad_item.update(image_generation_status: :failed)
      end
    else
      ad_item.attach_image(response["output"]) if response["output"].present?
    end
  end
end
