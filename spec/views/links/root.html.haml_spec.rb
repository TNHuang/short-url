require "rails_helper"

describe "View" do
	describe "#links/root.html.haml", :type => :feature do
		before(:each) do
			visit "/"
			assign(:links, Link.all)
		end

		it "should display title" do
			expect(page).to have_content("Type in the long url to get a short url")
		end

		describe "#enter new long url" do
			it "should display the new short url on the page once it's added" do
				within("form") do
					fill_in "out_url", :with => "www.google.com"
				end
				click_button "get shortened url"
				link = Link.first

				expect(page).to have_content("http://www.google.com")
				expect(page).to have_content("#{link.in_url}")
			end

			it "should display multiple entries when enter multiple long url" do
				within("form") do
					fill_in "out_url", :with => "www.google.com"
				end
				click_button "get shortened url"

				within("form") do
					fill_in "out_url", :with => "www.yahoo.com"
				end
				click_button "get shortened url"

				expect(page).to have_content("http://www.google.com")
				expect(page).to have_content("http://www.yahoo.com")
			end
		end
		
	end
end