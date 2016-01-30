# ActiveRecordFlorder

[![Build Status](https://travis-ci.org/turboMaCk/active-record-florder.svg)](https://travis-ci.org/turboMaCk/active-record-florder)
[![Code Climate](https://codeclimate.com/github/turboMaCk/active-record-florder/badges/gpa.svg)](https://codeclimate.com/github/turboMaCk/active-record-florder)
[![Test Coverage](https://codeclimate.com/github/turboMaCk/active-record-florder/badges/coverage.svg)](https://codeclimate.com/github/turboMaCk/active-record-florder/coverage)
[![Inline docs](http://inch-ci.org/github/turboMaCk/active-record-florder.svg?branch=master)](http://inch-ci.org/github/turboMaCk/active-record-florder)
[![Gem Version](https://badge.fury.io/rb/active_record_florder.svg)](https://badge.fury.io/rb/active_record_florder)

Floating point ActiveRecord Models ordering for rich client apps heavily inspirated by Trello's ordering alorithm.
ActiveRecordFlorder let client decide model's position in collection, normalize given value and resolve conflicts
to keep your data clean. It's highly optimalized and generate as small SQL queries.
The whole philosophy is to load and update as little records as possible so in 99% it runs just one SELECT and one UPDATE.
In edge cases sanitization of all records happens and bring records back to the "Garden of Eden" state.
It's implemented with both Rails and non-Rails apps in mind and highly configurable.

## Installation

add to your Gemfile if you're using Bundler

```ruby
gem 'active_record_florder', '~> 0.0.1'
```

or simply install via Ruby Gems

```shell
gem install active_record_florder
```

## Api

This gem defines new method for `ActiveRecord::Base` named `florder`.

### Parameters

* `direction {Symbol}` values: `:asc` `:desc`, **required**
* `options {Hash}`, optional

### Options

* `scope {Symbol}` - ordering scope (should be relationship or any other model property)
* `attribute {Sumbol}` - position column name, **default:** position
* `min_delta {Number}` - Minimal allowed position delata, affect position normalization *
* `step {Number}` - Optimal (init) delta between positions *
* `populate {Boolean}` - If true `move` method will return array of all affected records instead of just `self`

* *Setting this should affect performance. We recommend using default values*

### Example

```ruby
class Post < ActiveRecord::Base
  florder :desc, scope: :user, attribute: :order_position, min_delta: 0.001, step: 2**8, populate: true
end
```

## Usage

If you're using Rails or `ActiveRecordMigrations` create new migration:

```ruby
class AddPositionToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :position, :float, default: 0
  end
end
```

With rails you can use generator for this:

```shell
rails g migration add_position_to_posts position:float
```

Now migrate your database:

```shell
rake db:migrate
```

To use ActiveRecordFlorder add this line to your model:

```ruby
class Post < ActiveRecord::Base
  florder :desc
end
```

Now you can start using it:

```ruby
# Get ordered Posts
Post.ordered

# change position of first post
Post.first.move(123.123)
```

### Migrating Existing Data

ActiveRecordFlorder adds new before save model hook create position for new records. To make this work correctly you will need to initialize
positions for your existing data. ActiveRecordFlorder provides simple class method for this. You can define rake task or call it right inside your migration.

```ruby
Posts.reinit_positions
```

This method also should be used for optimalizing or repairing positions. It will not affect order of records just generate optimal positions for current order.

### ASCending vs DESCending ordering

The only required parameter for each model is `:asc` or `:desc` order param.
Each of them is optimalised for one of the cases - creating new models as first or last.
Basically created model has highest position value in collection. Because of this whole interval is increased with each new record.
Negative values are not allowed so creating new models with lowest position will decrese number of possible positions and increase possibility in conflicts.
This is why this is desibled by default.

#### Simply use one of this:

* **Use ASC ordering when you want to create new models as last**
* **Use DESC ordering when you want to create new models as first**

### Front-End Implementation

Client itself request position for given Model. This Gem is build with drag and drop interfaces in first place in mind.
Calculation on is simple - you just need to now position of two sibling to place model in middle of them.
For first and last position simply use hiher/lower value than first / last.

Here is hypotetical implementation in JavaScript:

```js
/*
 * Calculate new requested position for model
 * @param abovePosition {number}
 * @param belowPosition {number}
 * @returns {number}
 */
function calculateNewPosition(abovePosition, belowPosition) {
  if (!abovePosition) {
    return bellowPosition ? bellowPosition * 2 : false;
  } else if (!bellowPosition) {
    return abovePosition / 2;
  }

  return (bellowPosition + abovePosition) / 2;
}
```

## Configuration

You can use initializer to overwrite default settings like this:

```Ruby
ActiveRecordFlorder.configure do |config|
  config.scope :owner
  config.attribute :position_2
  config.step 3
  config.min_delta 0.1
end
```

## Upgrading
Please see summary of changes for each version in [changelog](CHANGELOG.md)

## Developing

Git clone repository and cd in it:

```shell
git clone git@github.com:turboMaCk/active-record-florder.git
cd active-record-florder
```

Copy configuration:

```shell
cp db/config.example.yml db/config.yml
```

Install dependencies:

```shell
bundle install
```

Run tests:

```shell
bundle exec rspec
```

or

```shell
bundle exec rake spec
```

That's it! We can't wait for your PR!

## License

MIT
