require 'progressive/version'

module Progressive
  class InvalidProgress < StandardError; end
  class MissingConfiguration < StandardError; end

  # Direct mapping of service names to their service object.
  mattr_accessor :specifications
  @@specifications = {}
end

require 'progressive/specification'
require 'progressive/subject'
require 'progressive/state'
