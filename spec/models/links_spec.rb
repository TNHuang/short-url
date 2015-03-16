require "rails_helper"

describe Link do
	describe '#object' do
		it "can be instantiated" do
			expect(build(:link)).to be_an_instance_of(Link)
		end
		it "can be save successfully" do
			expect(create(:link)).to be_persisted
		end
	end

	describe "#validations" do
		let(:missing_out_url) { build(:link, out_url: nil)}
		let(:missing_in_url) { build(:link, in_url: nil)}
		let(:missing_http_status) { build(:link, http_status: nil)}
		
		describe "#model level" do
			it { should validate_presence_of(:out_url)}
			it { should validate_presence_of(:in_url)}
			it { should validate_presence_of(:http_status)}
			
			it "should validate long_url unique" do
				short_url_1 = create(:link)
				short_url_2 = build(:link)
				expect(short_url_2).to_not be_valid
			end

			it "should validate long url and short url pair uniqueness" do
				short_url_1 = create(:link)
				short_url_2 = build(:link, in_url: short_url_1.in_url )
				expect(short_url_2).to_not be_valid
			end
		end

		describe "#should raise db error when model validations are skipped" do
			it "validates the presence of in_url" do
				expect{ missing_in_url.save!(validate: false) }.to raise_error
			end
			it "validates presence of out_url" do
				expect{ missing_out_url.save!(validate: false) }.to raise_error
			end
		end
	end

	describe "#methods" do
		describe "#url cleaning" do
			it "should not modify url when url contain http:// header" do
				expect(Link.clean_url("http://www.google.com")).to eq("http://www.google.com/")
			end
			it "should prepend http:// when http:// is missing from url" do
				expect(Link.clean_url("www.google.com")).to eq("http://www.google.com/")
			end
		end
		describe "#find or create short url" do
			it "should find short url given pre-existing long url" do
				link1 = create(:link)
				link2 = Link.find_or_create_short_url({out_url: "http://www.google.com"})
				
				expect(link2.in_url).to eq(link1.in_url)
			end
			it "should create a new short url given new long url" do
				link = Link.find_or_create_short_url({out_url: "www.google.com"})
				expect(Link.all.include?(link)).to be_falsey
			end

			it "should not create a new short url given pre-existing long url" do
				link = create(:link)
				expect{
					Link.find_or_create_short_url({out_url: "www.google.com"})
				}.to_not change(Link, :count)
			end
		end

		describe "#valid out url" do
			it "should return true if link can send back a non-4xx or non-5xx response" do
				expect(Link.valid_out_url?("http://www.google.com")).to be_truthy
			end
			it "should return false if link is an invalid url" do
				expect(Link.valid_out_url?("adsfsafe")).to be_falsey
			end
		end
	end

end