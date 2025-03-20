require 'open-uri'
require 'httparty'

class TiktokApi
  BASE_URL = "https://business-api.tiktok.com/open_api/v1.3"
  ACCESS_TOKEN = ENV['TIKTOK_ACCESS_TOKEN']
  ADVERTISER_ID = ENV['TIKTOK_ADVERTISER_ID']
  IDENTITY_ID = ENV['TIKTOK_IDENTITY_ID']
  CLIENT = TiktokBusinessApi.client(access_token: ACCESS_TOKEN)


  def self.get_campaigns
    CLIENT.campaigns.list(advertiser_id: ADVERTISER_ID)
  end

  def self.get_adsets(campaign_id)
    CLIENT.adgroups.list(advertiser_id: ADVERTISER_ID, campaign_id: campaign_id)
  end

  def self.upload_image(image_url)
    response = CLIENT.images.upload(
      advertiser_id: ADVERTISER_ID,
      image_file: File.open(image_url),
      upload_type: 'UPLOAD_BY_FILE'
    )

    response['image_id']
  end

  def self.create_ad(campaign_id:, adset_id:, image_id:, ad_item:)
    ad_prompt = ad_item.ad_prompt
    campaign = ad_prompt.campaign

    creatives = [{
      ad_name: "#{campaign.name} - ad - #{ad_item.id}",
      identity_id: IDENTITY_ID,
      identity_type: "CUSTOMIZED_USER",
      ad_format: "SINGLE_IMAGE",
      image_ids:[image_id],
      ad_text: campaign.name,
      call_to_action: "SHOP_NOW",   
      landing_page_url: campaign.landing_page_url
    }]

    response = CLIENT.ads.create(
      advertiser_id: ADVERTISER_ID,
      adgroup_id: adset_id,
      creatives: creatives.as_json
    )
  end
end
