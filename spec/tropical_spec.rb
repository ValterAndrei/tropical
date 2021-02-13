# frozen_string_literal: true

require "json"

RSpec.describe Tropical::OpenWeatherMap do
  describe "when the request is successful" do
    before do
      response = Net::HTTPSuccess.new(1.0, "200", "OK")
      expect_any_instance_of(Net::HTTP).to receive(:request) { response }
      expect(response).to receive(:body) { response_body }
    end

    let(:response_body) { File.read(File.expand_path("spec/fixtures/response.json")) }
    let(:params) { { appid: "valid_appid", q: "caconde,br", lang: "pt_br", units: "metric" } }

    subject { described_class.new(params) }

    describe "#list" do
      it "return correct values" do
        expect(subject.list).to eq(
          [
            { datetime: Time.new(2021, 2, 13, 15), temp: 21.86, description: "chuva moderada" },
            { datetime: Time.new(2021, 2, 13, 18), temp: 21.46, description: "chuva leve" },
            { datetime: Time.new(2021, 2, 13, 21), temp: 19.04, description: "chuva leve" },
            { datetime: Time.new(2021, 2, 14,  0), temp: 18.18, description: "nublado" },
            { datetime: Time.new(2021, 2, 14,  3), temp: 17.51, description: "nublado" },
            { datetime: Time.new(2021, 2, 14,  6), temp: 17.1,  description: "nublado" },
            { datetime: Time.new(2021, 2, 14,  9), temp: 22.44, description: "nublado" },
            { datetime: Time.new(2021, 2, 14, 12), temp: 25.16, description: "chuva leve" },
            { datetime: Time.new(2021, 2, 14, 15), temp: 26,    description: "chuva leve" },
            { datetime: Time.new(2021, 2, 14, 18), temp: 23.34, description: "chuva leve" }
          ]
        )
      end
    end

    describe "#average_temp_by_days" do
      it "return correct values" do
        expect(subject.average_temp_by_days).to eq(
          [
            { day: Date.new(2021, 2, 13), average: 21 },
            { day: Date.new(2021, 2, 14), average: 21 }
          ]
        )
      end
    end

    describe "#current_date" do
      it "return correct values" do
        expect(subject.current_date).to eq(Time.new(2021, 2, 13, 15))
      end
    end

    describe "#current_temp" do
      it "return correct values" do
        expect(subject.current_temp).to eq(21.86)
      end
    end

    describe "#current_weather" do
      it "return correct values" do
        expect(subject.current_weather).to eq("chuva moderada")
      end
    end

    describe "#city" do
      it "return correct values" do
        expect(subject.city).to eq("Caconde")
      end
    end

    it "return status" do
      expect(subject.status).to eq("200")
    end
  end

  describe "when the request is unauthorized" do
    before do
      response = Net::HTTPUnauthorized.new(1.0, "401", "Unauthorized")
      expect_any_instance_of(Net::HTTP).to receive(:request) { response }
    end

    let(:params) { { appid: "invalid_appid", q: "caconde,br", lang: "pt_br", units: "metric" } }

    subject { described_class.new(params) }

    it "return correct values" do
      expect(subject.data).to eq({ error: "Unauthorized: appid is invalid." })
    end

    it "return status" do
      expect(subject.status).to eq("401")
    end
  end

  describe "when the request has an error or not found city" do
    before do
      response = Net::HTTPServerError.new(1.0, "404", "Not Found")
      expect_any_instance_of(Net::HTTP).to receive(:request) { response }
    end

    let(:params) { { appid: "valid_appid", q: "anyway,br" } }

    subject { described_class.new(params) }

    it "return correct values" do
      expect(subject.data).to eq({ error: "Not Found" })
    end

    it "return status" do
      expect(subject.status).to eq("404")
    end
  end
end
