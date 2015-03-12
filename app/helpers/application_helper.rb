module ApplicationHelper
	def form_auth
	    <<-HTML.html_safe
	      <input type="hidden" name="authenticity_token"
	          value="#{form_authenticity_token}">
	    HTML
  	end

	def form_patch
		<<-HTML.html_safe
		<input type="hidden" name="_method"
		value="PATCH">
		HTML
	end

	def form_delete
		<<-HTML.html_safe
		<input type="hidden" name="_method"
		value="DELETE">
		HTML
	end
end
