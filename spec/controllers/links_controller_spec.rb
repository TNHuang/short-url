require 'rails_helper'

describe LinksController do
	describe "GET #root" do
		it "should response successfully" do
			get :root
			expect(response).to have_http_status(200)
		end
		it "should render root page" do
			expect( get :root).to render_template(:root)
		end
	end
	
	describe "POST #find_or_create_short_url" do
		let(:find_or_create_short_url) {
			post "find_or_create_short_url", link: { out_url: "www.google.com" } 
		}

		it "create short url when long url don't exist in database" do
			expect{find_or_create_short_url}.to change(Link, :count).by(1)
		end

		it "find short url when long url existed in database" do
			link = create(:link)			
			expect(Link.all).to eq([link])
			expect{find_or_create_short_url}.to_not change(Link, :count)
		end

		it "presence of http extension should not affect short url" do
			link = create(:link)
			expect(Link.all).to eq([link])
			expect{
				post "find_or_create_short_url", link: {out_url: "http://www.google.com"}
			}.to_not change(Link, :count)
		end
	end 

	describe "GET #url address bar" do
		it "should redirect to long url when using short url existed in database" do
			link = create(:link)
			get "go", in_url: link.in_url
			expect(response).to redirect_to link.out_url
		end

		it "should not redirect when enter non-existing short url" do
			get "go", in_url: "xxxxx"
			expect(flash[:errors]).to eq(["Non existing short url!"])
		end
	end
end
