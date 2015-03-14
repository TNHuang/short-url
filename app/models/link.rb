require "net/http"

class ValidUrlValidator < ActiveModel::Validator
  def validate(link)
    unless Link.valid_out_url?(link.out_url)
      link.errors[:out_url] << ": #{link.out_url} is not a valid url!"
    end
  end
end

class Link < ActiveRecord::Base
	
	include ActiveModel::Validations
  	validates_with ValidUrlValidator #make the out url is actually exist
	
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

	def self.valid_out_url?(out_url)
		url = URI.parse(out_url)
		req = Net::HTTP.new(url.host, url.port)
		req.use_ssl = (url.scheme == 'https')
		path = url.path if url.path.present?
		begin
			res = req.request_head(path || '/')
			if res.kind_of?(Net::HTTPRedirection)
				url_exist?(res['location']) # Go after any redirect and make sure you can access the redirected URL 
			else
				![4,5].include?(res.code[0]) # Not from 4xx or 5xx families
			end
		rescue
			return false #false if can't find the server
		end
	end

end