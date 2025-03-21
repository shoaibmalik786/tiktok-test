class CampaignsController < ApplicationController
  before_action :find_campaign, only: [:show, :generate_images, :reload]

  def new
    @campaign = Campaign.new
    @campaigns = Campaign.all
  end

  def create
    @campaign = if params[:campaign_id].present?
      Campaign.find(params[:campaign_id])
    else
      Campaign.new(campaign_params)
    end

    @campaign.ad_prompts.destroy_all if @campaign.ad_prompts.present?

    if @campaign.save
      @campaign.generate_prompts
      redirect_to @campaign
    else
      render :new
    end
  end

  def show
    @tiktok_campaigns = TiktokApi.get_campaigns
  end

  def generate_images
    @campaign.generate_images

    redirect_to campaign_path(@campaign)
  end

  def publish
    ad_items = AdItem.where(id: params[:ad_item_ids])
    ad_items.each{|ad_item| ad_item.upload_and_publish(campaign_id: params[:campaign_id], adset_id: params[:adset_id])}
  end

  def reload
    @tiktok_campaigns = TiktokApi.get_campaigns

    respond_to do |format|
      format.turbo_stream do
        render(
          turbo_stream: turbo_stream.replace(
            "campaign-item",
            partial: 'campaigns/campaign',
            locals: { campaign: @campaign, tiktok_campaigns: @tiktok_campaigns }
          )
        )
      end
    end
  end

  private

  def campaign_params
    params.require(:campaign).permit(:name, :description, :landing_page_url)
  end

  def find_campaign
    @campaign = Campaign.find(params[:id])
  end
end
