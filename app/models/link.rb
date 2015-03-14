class Link < ActiveRecord::Base
	validates :in_url, :out_url, :http_status, presence: true
	validates :out_url, :in_url, uniqueness: true 
	
	validates_uniqueness_of :out_url, scope: :in_url

	after_initialize :ensure_in_url, :ensure_clean_out_url

	URL_PROTOCOL_HTTP = "http://"
  	REGEX_LINK_HAS_PROTOCOL = /^http:\/\/|^https:\/\//i

  	#ensure out url has proper header protocol
  	def self.clean_url(out_url)
		return nil if out_url.blank?
		out_url = URL_PROTOCOL_HTTP + out_url.strip unless out_url =~ REGEX_LINK_HAS_PROTOCOL
		URI.parse(out_url).normalize.to_s
	end

	def self.find_or_create_short_url(params)
		clean_url = Link.clean_url(params[:out_url])
		@link = Link.find_by({out_url: clean_url})
		unless @link
			@link = Link.new({ out_url: clean_url }) 
		end
		@link
	end

	def ensure_clean_out_url
		self.out_url = Link.clean_url(self.out_url)
	end

	#call back to be fire to generate unique in url
	def ensure_in_url
		self.in_url ||= Link.generate_unique_in_url
	end

	def self.generate_unique_in_url
		begin
			in_url = SecureRandom.base64(32)
		end while Link.exists?(in_url: in_url)
		in_url
	end
end