require 'active_support/concern'
require 'active_model/callbacks'

module Progressive
  module Subject
    extend ActiveSupport::Concern
    include ActiveModel::Callbacks

    included do
      class_attribute :specification

      define_model_callbacks :progress, only: [:before, :after]
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
    end

    def method_missing(method_sym, *args, &block)
      if method_sym.to_s[-1] == '?' && specification.state?(method_sym.to_s[0..-2])
        specification.send(method_sym)
      else
        super
      end
    end

    def specification
      self.class.specification
    end

    def human_state
      state.humanize
    end
  end
end
