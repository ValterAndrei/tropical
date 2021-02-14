# Tropical

Gem to consultation weather forecast up to 5 days.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tropical', '~> 0.1.7'
```

And then execute:

    $ bundle install

## Usage

Ruby API
```ruby
tropical = Tropical::OpenWeatherMap.new(
  {
    appid: 'your_api_key', # required
    q:     'São Paulo',    # required
    lang:  'pt_br',        # optional
    units: 'metric',       # optional
    cnt:   '50'            # optional
  }
)
```
For more information about the params: [openweathermap](https://openweathermap.org/forecast5)

- City name
```ruby
tropical.city

# => "São Paulo"
```

- Current date
```ruby
tropical.current_date

# => 2021-02-14 18:00:00 -0300
```

- Current temperature
```ruby
tropical.current_temp

# => 26.92
```

- Current weather
```ruby
tropical.current_weather

# => "chuva moderada"
```

- Scale
```ruby
tropical.scale

# => "°C"
```

- Full sumary
```ruby
tropical.full_sumary

# => "27°C e chuva moderada em São Paulo em 14/02. Média para os próximos dias: 26°C em 14/02, 26°C em 15/02, 26°C em 16/02, 26°C em 17/02, 25°C em 18/02 e 24°C em 19/02."
```

- Sumary current day
```ruby
tropical.sumary_current_day

# => "27°C e chuva moderada em São Paulo em 14/02."
```

- Sumary days forecast
```ruby
tropical.sumary_days_forecast

# => "26°C em 14/02, 26°C em 15/02, 26°C em 16/02, 26°C em 17/02, 25°C em 18/02 e 24°C em 19/02." 
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/tropical. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/tropical/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Tropical project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/tropical/blob/master/CODE_OF_CONDUCT.md).
