require "active_support/all"
require "date"
require "json"
require "net/http"
require "uri"

module Tropical
  class OpenWeatherMap
    BASE_URL = "https://api.openweathermap.org/data/2.5/forecast?".freeze

    attr_reader :data, :params, :status

    def initialize(params)
      @params  = params
      response = post(request_params)

      load_data(response)
    end

    def average_temp_by_days
      group_by_days = list.group_by { |item| item[:datetime].to_date }
      days = []

      group_by_days.each do |day, temps|
        average = temps.sum { |time| time[:temp] } / temps.length

        days << { day: day, average: average.round }
      end

      days
    end

    def city
      data["city"]["name"]
    end

    def current_date
      list.first[:datetime]
    end

    def current_temp
      list.first[:temp]
    end

    def current_weather
      list.first[:description]
    end

    def list
      data["list"].map do |list_item|
        {
          datetime: Time.at(list_item["dt"]),
          temp: list_item["main"]["temp"],
          description: list_item["weather"].first["description"]
        }
      end
    end

    def scale
      units = params[:units]

      return "°C" if units == "metric"
      return "°F" if units == "imperial"

      "°K"
    end

    def sumary
      message = format_message

      "#{message.current_temp}#{scale} e #{current_weather} em #{city} em #{message.current_date}. "\
      "Média para os próximos dias: "\
      "#{message.first_day_average}#{scale} em #{message.first_day_date}, "\
      "#{message.second_day_average}#{scale} em #{message.second_day_date}, "\
      "#{message.third_day_average}#{scale} em #{message.third_day_date}, "\
      "#{message.fourth_day_average}#{scale} em #{message.fourth_day_date} "\
      "e #{message.fifth_day_average}#{scale} em #{message.fifth_day_date}."
    end

    private

    def request_params
      link = ""

      params.each do |k, v|
        link += "&#{k}=#{v}" if v.is_a?(String) && v.present?
      end

      BASE_URL + link
    end

    def format_message
      OpenStruct.new(
        current_temp: current_temp.round,
        current_date: current_date.strftime("%d/%m"),
        first_day_average: average_temp_by_days[0][:average],
        first_day_date: average_temp_by_days[0][:day].strftime("%d/%m"),
        second_day_average: average_temp_by_days[1][:average],
        second_day_date: average_temp_by_days[1][:day].strftime("%d/%m"),
        third_day_average: average_temp_by_days[2][:average],
        third_day_date: average_temp_by_days[2][:day].strftime("%d/%m"),
        fourth_day_average: average_temp_by_days[3][:average],
        fourth_day_date: average_temp_by_days[3][:day].strftime("%d/%m"),
        fifth_day_average: average_temp_by_days[4][:average],
        fifth_day_date: average_temp_by_days[4][:day].strftime("%d/%m")
      )
    end

    def load_data(response)
      @status = response.code
      @data = case response
              when Net::HTTPSuccess
                JSON.parse(response.body)
              when Net::HTTPUnauthorized
                { error: "#{response.message}: appid is invalid." }
              else
                { error: response.message }
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
