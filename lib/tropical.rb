require "active_support/all"
require "date"
require "json"
require "i18n"
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

    def city
      data["city"]["name"]
    end

    def current_date
      list.first[:dt]
    end

    def current_temp
      list.first[:temp]
    end

    def current_weather
      list.first[:description]
    end

    def scale
      units = params[:units]

      return "°C" if units == "metric"
      return "°F" if units == "imperial"

      "°K"
    end

    def full_sumary
      "#{sumary_current_day} "\
      "Média para os próximos dias: "\
      "#{sumary_days_forecast}"
    end

    def sumary_current_day
      "#{current_temp.round}#{scale} e #{current_weather} em "\
      "#{city} em #{current_date.strftime("%d/%m")}."
    end

    def sumary_days_forecast
      list = average_temp_by_days.map do |x|
        "#{x[:average]}#{scale} em #{x[:day].strftime("%d/%m")}"
      end

      "#{list.to_sentence(words_connector: ", ", last_word_connector: " e ")}."
    end

    def list
      data["list"].map do |list_item|
        {
          dt: Time.at(list_item["dt"]),
          temp: list_item["main"]["temp"],
          description: list_item["weather"].first["description"]
        }
      end
    end

    def average_temp_by_days
      group_by_days = list.group_by { |item| item[:dt].to_date }
      days = []

      group_by_days.each do |day, temps|
        average = temps.sum { |time| time[:temp] } / temps.length

        days << { day: day, average: average.round }
      end

      days
    end

    private

    def request_params
      link = ""

      params.each do |k, v|
        link += "&#{k}=#{remove_accents(v)}" if v.is_a?(String) && v.present?
      end

      BASE_URL + link
    end

    def remove_accents(value)
      I18n.transliterate(value)
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
