class LinksController < ApplicationController
	def root
		@link = Link.new
		@links = Link.all

		render :root
	end

	def find_or_create_short_url
		@link = Link.find_or_create_short_url(link_param)
		unless @link.save
				flash[:errors] = @link.errors.full_messages
		end
		redirect_to root_url
	end

	def go
		@link = Link.find_by_in_url!(params[:in_url])
		redirect_to @link.out_url, status: @link.http_status
	end

	private
	def link_param
		params.require(:link).permit(:out_url)
	end
end