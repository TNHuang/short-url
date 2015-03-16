require 'rails_helper'

describe "Route", :type => :routing do
	it "should route to link controller" do
		expect(get("/")).to route_to("links#root")
	end
	it "should route to links#go when enter short url" do
		expect(get("test_short_url")).
		to route_to(:controller => "links", :action => "go", :in_url => "test_short_url")
	end
	it "should route to links#find_or_create_short_url when fetching short url" do
		expect(:post => "find_or_create_short_url").
		to route_to(:controller=> "links", :action=>"find_or_create_short_url")
	end
end