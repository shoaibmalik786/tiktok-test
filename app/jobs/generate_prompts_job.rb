class GeneratePromptsJob < ApplicationJob
  def perform(campaign_id:)
    campaign = Campaign.find(campaign_id)

    user_message = <<~MSG
      I am creating a marketing campaign and need four creative image prompts for AI-generated visuals.

      - The images should align with the campaign's **theme, mood, and target audience**.
      - Each prompt should be **visually distinct** and use **different artistic styles** (e.g., futuristic, minimalistic, abstract, photorealistic).
      - The images should have **vibrant, eye-catching colors** to enhance engagement.
      - Ensure **no repetition** in style across the four prompts.

      Campaign Details:
        Name: "#{campaign.name}"
        Description: "#{campaign.description}"

      **Return JSON in this format:**  
      [
        {"prompt": "A bold and futuristic visual ..."},
        {"prompt": "A minimalistic and elegant ad concept ..."}
      ]
    MSG

    messages = [
      { role: "system", content: "You are an expert in generating creative image prompts for AI image models." },
      { role: "user", content: user_message }
    ]

    chat_completion = Openai::ChatCompletions.new(messages: messages, model: 'gpt-4-turbo')
    response = chat_completion.process

    message_content = response.dig("choices", 0, "message", "content") || ""

    # Extract JSON content
    code_part = message_content.include?("```") ? message_content.split("```").find { |block| block.include?("[{") }&.gsub('json', '')&.strip : message_content

    begin
      prompts_array = JSON.parse(code_part)

      prompts_array.each do |prompt_item|
        campaign.ad_prompts.create(content: prompt_item['prompt'])
      end
    rescue JSON::ParserError => e
      Rails.logger.error "JSON parsing error in GeneratePromptsJob: #{e.message}"
    end

    campaign.update(generating_prompts: false)

    Turbo::StreamsChannel.broadcast_replace_to("campaign-#{campaign.id}", target: "campaign-item", partial: 'campaigns/campaign', locals: { campaign: campaign })
  end
end
