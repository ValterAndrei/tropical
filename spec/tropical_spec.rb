# frozen_string_literal: true

require "json"

FILE_SUCCESS_RESPONSE = File.expand_path("spec/fixtures/success_response.json")

RSpec.describe Tropical::OpenWeatherMap do
  before do
    response = Net::HTTPSuccess.new(1.0, "200", "OK")
    expect_any_instance_of(Net::HTTP).to receive(:request) { response }
    expect(response).to receive(:body) { response_body }
  end

  describe "when the request is successful" do
    let(:response_body) { File.read(FILE_SUCCESS_RESPONSE) }
    let(:params) { { appid: "xxxx", q: "caconde,br", lang: "pt_br", units: "metric" } }

    describe "#list" do
      it "return correct values" do
        expect(described_class.new(params).list).to eq(
          [
            {
              datetime: Time.at(1_613_174_400), # 2021-02-12 21:00:00 -0300
              description: "chuva leve",
              temp: 19.77
            },
            {
              datetime: Time.at(1_613_185_200), # 2021-02-13 00:00:00 -0300
              description: "nublado",
              temp: 19.09
            },
            {
              datetime: Time.at(1_613_196_000), # 2021-02-13 03:00:00 -0300
              description: "nublado",
              temp: 18.55
            }
          ]
        )
      end
    end

    describe "#average_temp_by_days" do
    end

    describe "#current_date" do
    end

    describe "#current_temp" do
    end

    describe "#current_weather" do
    end
  end

  describe "when the request is unauthorized" do
  end

  describe "when the request has an error" do
  end
end
