require 'date'
require 'json'
require 'net/http'
require 'uri'

module Tropical
  class OpenWeatherMap
    BASE_URL = 'https://api.openweathermap.org/data/2.5/forecast?'.freeze

    attr_reader :data

    def initialize(params)
      request_params = build_request_params(params)
      response       = post(request_params)

      @data = JSON.parse(response.read_body)
    end

    def average_temp_by_days
      group_by_days = organize_values.group_by { |item| item[:datetime].to_date }
      days = []

      group_by_days.each do |day, temps|
        average = temps.sum { |time| time[:temp] } / temps.length

        days << { day: day, average: average.round }
      end

      days
    end

    def current_date
      organize_values.first[:datetime]
    end

    def current_temp
      organize_values.first[:temp]
    end

    def current_weather
      organize_values.first[:description]
    end

    private

    def build_request_params(params)
      link = ''

      params.each do |k, v|
        link += "&#{k}=#{v}" if v.is_a?(String) && !v.empty?
      end

      BASE_URL + link
    end

    def organize_values
      data['list'].map do |list_item|
        {
          datetime: Time.at(list_item['dt']),
          temp: list_item['main']['temp'],
          description: list_item['weather'].first['description']
        }
      end
    end

    def post(request_params)
      url          = URI(request_params)
      http         = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request      = Net::HTTP::Get.new(url)
      http.request(request)
    end
  end
end
