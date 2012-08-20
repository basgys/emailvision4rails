module Emailvision4rails
	class AbstractNewsletter < ::AbstractController::Base
		abstract!

		include AbstractController::Rendering
		include AbstractController::Layouts

		append_view_path "#{Rails.root}/app/views"

		private_class_method :new

		class << self
			def respond_to?(method, include_private = false)
				super || action_methods.include?(method.to_s)
			end

			protected

			def method_missing(method, *args)
				return super unless respond_to?(method)
				new(method, *args).message
			end		
		end

		attr_internal :message

	  def initialize(method_name=nil, *args)
	    super()
	    lookup_context.formats = [:text, :html] # Restrict rendering formats to html and text
	    @_message = Newsletter.new
	    process(method_name, *args) if method_name
	  end

		def process(*args)
			lookup_context.skip_default_locale!
			super
		end

		def newsletter(params = {})
			message = @_message

			lookup_context.locale = params.delete(:language) if params[:language]

			responses = collect_responses(lookup_context.formats)

			# Inline CSS
			responses[:html] = Premailer.new(responses[:html], 
				:warn_level => Premailer::Warnings::SAFE,
				:with_html_string => true
			)


			message.parts = responses
			message.payload = params

			message
		end

		private

		def collect_responses(formats)
			collector = ActionMailer::Collector.new(lookup_context) do 
				render(action_name)
			end			
			responses = {}
			formats.each do |f|
				collector.send(f)
				responses[f] = collector.responses.last[:body]
			end
			responses
		end

	end	
end