class PublishTiktokAdJob < ApplicationJob
  def perform(campaign_id:, adset_id:, image_id:, ad_item_id:)
    ad_item = AdItem.find(ad_item_id)
    TiktokApi.create_ad(campaign_id: campaign_id, adset_id: adset_id,
                        image_id: image_id, ad_item: ad_item)
  end
end
