require 'active_support/concern'
require 'active_model/callbacks'

module Progressive
  module Subject
    extend ActiveSupport::Concern
    include ActiveModel::Callbacks

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

    included do
      define_model_callbacks :progress, only: [:before, :after]

      attr_accessor :event_context

      class_attribute :new_state_record_on_change
      self.new_state_record_on_change = false
    end

    def specification
      self.class.specification
    end

    def new_state_record_on_change?
      !!self.class.new_state_record_on_change
    end
  end
end
