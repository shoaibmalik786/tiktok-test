class TiktokController < ApplicationController
  def adsets
    adsets = TiktokApi.get_adsets(params[:campaign_id])

    adset_options = adsets.map{|a| [a['adgroup_name'], a['adgroup_id']]}

    render json: adset_options.to_json
  end
end
