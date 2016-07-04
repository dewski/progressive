require 'active_support/concern'
require 'active_model/callbacks'

module Progressive
  module Subject
    extend ActiveSupport::Concern
    include ActiveModel::Callbacks

    included do
      define_model_callbacks :progress, only: [:before, :after]

      attr_accessor :event_context
    end

    module ClassMethods
      # Public: Define the different states and events the subject can go through.
      #
      # options - The Hash options used to build the specification (default: {}):
      #           :default - The default state the subject is instantiated at (optional).
      # block   - A required block that is used to define states and events for
      #           the subject.
      #
      # Returns Progression::Specification
      def states(options = {}, &block)
        self.specification = Specification.new(options, &block)
        define_model_callbacks(*specification.event_names, only: [:before, :after])
      end

      def specification=(specification)
        Progressive.specifications[name] = specification
      end

      def specification
        Progressive.specifications[name]
      end
    end

    def specification
      self.class.specification
    end
  end
end
