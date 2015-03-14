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
end