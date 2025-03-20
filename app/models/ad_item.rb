require 'open-uri'

class AdItem < ApplicationRecord
  belongs_to :ad_prompt

  has_one_attached :image

  enum :image_generation_model, { mid_journey: 0, openai: 1, ideogram: 2, flux_pro: 3, imagen_3: 4 }
  enum :image_generation_status, { started: 0, success: 1, failed: 2 }

  def attach_image(image_url)
    mini_image = MiniMagick::Image.open(ActiveStorage::Blob.service.path_for(image.key))
    mini_image.resize "720x1280^"
  
    # Crop to exact dimensions
    mini_image.gravity "center"
    mini_image.crop "720x1280+0+0"

    file = Tempfile.new('temp')
    mini_image.write file
    file.rewind

    if image.attach(io: file, filename: "#{image_generation_model}-#{ad_prompt_id}-#{id}")
      file.close
      file.unlink

      update(image_generation_status: :success)
    else
      update(image_generation_status: :failed)
    end
  end

  def handle_image_generation(response)
    image_url = nil
    case image_generation_model
    when 'mid_journey'
      image_url = handle_mid_journey_response(response)
    when 'openai'
      image_url = handle_openai_response(response)
    when 'ideogram', 'flux_pro', 'imagen_3'
      image_url = handle_replicate_response(response)
    end

    attach_image(image_url) if image_url
  end

  def handle_mid_journey_response(response)
    if response["data"]["status"] == 'pending'
      image_id = response['data']['id']
      MidjourneyFetchImageJob.set(wait: 30.seconds).perform_later(image_id: image_id, ad_item_id: id)
    else
      image_url = response["data"]["url"]
    end

    image_url ||= nil
  end

  def handle_replicate_response(response)
    if response['status'] == 'starting'
      image_id = response['id']
      ReplicateFetchImageJob.set(wait: 10.seconds).perform_later(image_id: image_id, ad_item_id: id)
    else
      image_url = response["output"]
    end

    image_url ||= nil
  end

  def handle_openai_response(response)
    image_url = response["data"][0]["url"]
  end

  def upload_and_publish(campaign_id:, adset_id:)
    if image.attached?
      image_id = TiktokApi.upload_image(ActiveStorage::Blob.service.path_for(image.key))

      PublishTiktokAdJob.perform_later(campaign_id: campaign_id, adset_id: adset_id, image_id: image_id, ad_item_id: id)
    end
  end
end
