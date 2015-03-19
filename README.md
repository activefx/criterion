# Criterion

[![Code Climate](https://codeclimate.com/github/activefx/criterion/badges/gpa.svg)](https://codeclimate.com/github/activefx/criterion)

Criterion is a small, simple library for searching Ruby arrays and collections with a chainable, Active Record style query interface.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'criterion'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install criterion

## Usage

Consider the following example: 

````ruby 
require 'hashie'
require 'criterion'

matt = Hashie::Mash.new(name: 'Matt', age: 30) 
mark = Hashie::Mash.new(name: 'Mark', age: 45) 
john = Hashie::Mash.new(name: 'John', age: 50) 

collection = [ matt, mark, john ].extend(Criterion)
````

By extending the collection with the Criterion module, you can perform chainable queries with #where, #not, #order, #limit, #offset/#skip, and calculations with #sum, #maximum, #minimum, #average.

### Where 

Where is the primary method for searching a Criterion collection. All query values must match in order for a result to be returned. 

Calling any query method without a value will return a Criterion::Criteria: 

````ruby 
collection.where
#=> #<Criterion::Criteria...
````

Searching by exact value: 

````ruby 
collection.where(name: 'Matt').first
#=> {"name"=>"Matt", "age"=>30}
````

Searching by regular expression: 

````ruby 
collection.where(name: /J/).first
#=> {"name"=>"John", "age"=>50}
````

Searching by proc: 

````ruby 
collection.where(age: ->(age){ age.odd? }).first
#=> {"name"=>"Mark", "age"=>45}
````

Searching by class:

````ruby 
collection.where(age: Integer).all
#=> [{"name"=>"Matt", "age"=>30}, {"name"=>"Mark", "age"=>45}, {"name"=>"John", "age"=>50}]
````

Searching by range: 

````ruby 
collection.where(age: 42..48).all
#=> [{"name"=>"Mark", "age"=>45}]
````

Searching with multiple arguments or #where calls:

````ruby 
collection.where(name: 'Matt', age: 28...32)
# is equivalent to 
collection.where(name: 'Matt').where(age: 28...32)
````

All criteria must match to return a result: 

````ruby 
collection.where(name: 'Matt', age: 40).empty?
#=> true
````

### Not 

The #not method negates the query, returning matches that do not match all of the specified values. Like #where, #not can search by exact value, regular expression, class, proc, and range. 

````ruby 
collection.not(name: 'Matt').all 
#=> [{"name"=>"Mark", "age"=>45}, {"name"=>"John", "age"=>50}]
````

All values must match for result to be excluded:

````ruby 
collection.not(name: 'Matt', age: 40).empty?
#=> true 
````

### Limit

Limit the number of results returned: 

````ruby 
collection.where(age: 0..100).limit(2).count
#=> 2 
````

### Offset 

Skip the specified number of records before returning a result: 

````ruby 
collection.where(age: 0..100).offset(1).first
#=> {"name"=>"Mark", "age"=>45}
````

### Order 

Specify the field or fields with which to order the results: 

````ruby 
collection.order(:name).first
#=> {"name"=>"John", "age"=>50}
````

Ascending order is assumed by default, but descending can be specified:

````ruby 
collection.order(age: :desc).first
#=> {"name"=>"John", "age"=>50}
````

### Calculations 

A calculation method can be called end of the criteria chain to perform on operation on one of the collection's attributes. 

````ruby 
# Sum / total for a field: 
collection.where(age: 35..55).sum(:age)
#=> 95

# Maximum value for a field: 
collection.maximum(:age)
#=> 50 

# Minimum value for a field:
collection.minimum(:age)
#=> 30 

# Average value for a field:
collection.average(:age)
#=> 41.666666666666664

# When there are no values in the collection, nil is returned:
collection.where(age: 0..1).average(:age)
#=> nil 
````

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/criterion/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
