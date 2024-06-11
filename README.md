# Filterman

Often times, when you want to allow filtering by several params, you'd end up with something like this:

```ruby
class CompaniesController < ApplicationController
  before_action :load_companies

  def index
    @companies = @companies.where(name: params[:name]) if params[:name]
    @companies = @companies.where(city: params[:city]) if params[:city]
    @companies = @companies.where(category: params[:category]) if params[:category]
  end

  private

  def load_companies
    @companies = Company.all
  end
end
```

Filterman aims to provide a simple way to avoid such repetition in your controllers, without requiring additional classes to be defined elsewhere.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'filterman'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install filterman

Then
```ruby
  include Filterman
```

in the controller where you need it, or inside ApplicationController to make it available throughout
## Usage

The equivalent of the above example using filterman would look like:
```ruby
class CompaniesController
  before_action :load_companies, only: :index

  available_filters :name, :city, :category

  def index
  end

  private

  def load_companies
    @companies = Company.all
    apply_filters!
  end
end
```

For more complex queries it also supports scopes
```ruby
available_filters location: { scope: :by_location},
                  name:     { scope: :by_name }
```

Or if you don't want to pollute your model with additional scopes, you could even supply a query directly
```ruby
available_filters min_age: { query: -> (users, age) { users.where('age > ?', age) } },
                  max_age: { query: -> (users, age) { users.where('age < ?', age) } }
```

By default the collection name on which the filters are applied is inferred from controller name, but you can specify it explicitly with `on:` parameter

```ruby
class CompaniesController < ApplicationController
  def load_companies
    @agencies = Company.all
    apply_filters! on: :agencies
  end
end
```

Also, by default `params` are used to read the supplied keys from, but you can easily pass a different method:
```ruby
class CompaniesController <ApplicationController
  ...

  private

  def search_params
    params.permit(:name, :location)
  end

  def load_companies
    @companies = Company.all
    apply_filters! from: :search_params
  end
end
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/filterman. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/filterman/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Filterman project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/filterman/blob/master/CODE_OF_CONDUCT.md).
