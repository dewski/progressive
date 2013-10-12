# Progressive

A simple ActiveModel backed state machine.

## Why yet another state machine?

You may be asking why another state machine implementation? Well, first off YASM.
Second, most other implementations rely on class level attributes and make it
difficult for inheritance and the rare case when a subject will need to have
_multiple_ states.

Progressive centralizes the logic for model code to a single State model
which all entities access their state through.

Future plans will be to make it possible to states and events persisted in the
database that way they can be customized and modified.

## Installation

Add this line to your application's Gemfile:

    gem 'progressive'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install progressive

## Usage

### Defining states on the subject model:

```ruby
class State < Progressive::State

end

class User < ActiveRecord::Base
  include Progression::Subject

  has_many :states, :as => :subject, :dependent => :destroy

  states :default => :pending do
    state :pending do
      event :potential
    end

    state :potential do
      event :interview => :interviewing
      event :archive => :archived
    end

    state :interviewing do
      event :potential
      event :archive => :archived
      event :hire => :hired
    end

    state :hired
  end

  after_hire :user_rollup
  before_interview :notify_creator

  def user_rollup
    # Do something
  end

  def notify_creator

  end
end
```

### Interfacing with the state

```ruby
actor = User.first
user = User.first

state = user.states.first
state.state # => pending
state.to(:archived, :actor => actor) # => false
state.to(:potential, :actor => actor) # => true
state.state # => potential
state.specification # => Progressive::Specification
state.current_state # => Progressive::Specification::State
```

## Maintainers

- [@dewski](/dewski)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
