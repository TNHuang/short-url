require 'rails_helper'

describe LinksController do
	describe "GET #root" do
		it "render root page" do
			expect( get :root).to render_template(:root)
		end
	end
	
	describe "POST #find_or_create_short_url" do
		it "create short url when long url don't exist in database" do
			expect{
				post "find_or_create_short_url", link: { out_url: "www.google.com" }
				}.to change(Link, :count).by(1)
		end

		it "find short url when long url existed in database" do
			post "find_or_create_short_url", link: {out_url: "www.google.com"}
			post "find_or_create_short_url", link: {out_url: "www.google.com"}
			link = Link.first
			expect(Link.all).to eq([link])
			expect(Link.count).to eq(1)
		end

		it "presence of http extension should not affect short url" do
			post "find_or_create_short_url", link: {out_url: "www.google.com"}
			post "find_or_create_short_url", link: {out_url: "http://www.google.com"}
			link = Link.first
			expect(Link.all).to eq([link])
			expect(Link.count).to eq(1)
		end
	end 

	describe "GET #go" do
		it "should redirect to long url when using short url existed in database" do
			post "find_or_create_short_url", link: {out_url: "www.google.com"}
			link = Link.first
			get "go", in_url: link.in_url
			expect(response).to redirect_to link.out_url
		end

		it "should not redirect when enter non-existing short url" do
			get "go", in_url: "xxxxx"
			expect(flash[:errors]).to eq(["Non existing short url!"])
		end
	end
end
