module Emailvision4rails
	class Newsletter

		attr_accessor :parts, :payload

		def initialize
			@parts = {}
		end

		def publish
			message = Message.new(content, payload[:message])			
			campaign = Campaign.new(payload[:campaign])

			# Message
			unless message.create
				return false
			end

			# Campaign
			campaign.message_id = message.id
			unless campaign.create
				return false				
			end
			campaign.post

			true
		end

		def content
			parts.map do |format, content|
				"[EMV #{format.upcase}PART]\n#{content}"
			end.join("\n")
		end

		def to_html
			parts[:html]
		end

		def to_text
			parts[:text]
		end		

		def to_s
			content
		end

	end
end