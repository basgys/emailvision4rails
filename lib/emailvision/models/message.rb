class Emailvision::Message < Emailvision::Base

	attributes(
		:name,
		:subject,
    :from, 
    :from_email,		      
    :body,   		    
	  :reply_to, 
	  :reply_to_email,
		:id,
		:create_date, 
		:to,  		    
		:description, 
		:encoding, 
		:hotmail_unsub_url,
		:type,
		:hotmail_unsub_flg,
		:is_bounceback,
		:message_id
	)

	validates_presence_of(
		:name,
		:subject,
		:from, 
		:from_email,		      
		:body,   		    
		:reply_to, 
		:reply_to_email
	)  	

	# Validate format of email address	

	def create
		if valid?
		  run_callbacks :create do
		    message_id = api.post.message.create(:body => self.to_emv).call
		  end
			true
		else
			false
		end
	end	

	def update
		if valid? and persisted?
			run_callbacks :update do
				api.post.message.create(:body => self.to_emv).call
			end			
		else
			false
		end
	end

	# Maybe in a helper?
	def mirror_url_id
		@mirror_url_id ||= api.get.url.create_and_add_mirror_url(uri: [message_id, 'mirror_url']).call
	end

	def track_links
		emv.get.message.track_all_links(id: message_id).call
	end

	def persisted?
		message_id.present?
	end

end