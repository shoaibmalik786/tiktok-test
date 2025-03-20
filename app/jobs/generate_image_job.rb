class GenerateImageJob < ApplicationJob
  def perform(ad_prompt_id:, model:, retry_count: 0)
    ad_prompt = AdPrompt.find(ad_prompt_id)
    ad_item = ad_prompt.ad_items.find_or_create_by(image_generation_model: model)
    ad_item.update(image_generation_status: :started)

    prompt_content = ad_prompt.content + "\n- Size should be 1024 pixels (width) x 1792 pixels (height) \n - Image should be from only these formats 'jpg', 'png', 'jpeg'"

    begin
      case model
      when 'mid_journey'
        request = Imagineapi::ImageGenerations.new(prompt: prompt_content)
      when 'openai'
        request = Openai::ImageGenerations.new(prompt: prompt_content, model: 'dall-e-3', n: 1)
      when 'ideogram', 'flux_pro', 'imagen_3'
        request = Replicate::ImageGenerations.new(
          prompt: prompt_content,
          model: model,
          aspect_ratio: model == 'ideogram' ? '3:2' : nil,
          prompt_upsampling: model == 'flux_pro' ? true : nil
        )
      end

      response = request.process

      ad_item.handle_image_generation(response)
    rescue => e
      if retry_count < 3
        GenerateImageJob.set(wait: 10.seconds).perform_later(ad_prompt_id: ad_prompt_id, model: model, retry_count: retry_count + 1)
      end
    end
  end
end
