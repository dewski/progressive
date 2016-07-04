module Progressive
  class Specification
    class State
      attr_reader :events

      def initialize(&block)
        @events = {}
        return unless block.present?
        instance_eval(&block)
      end

      # Public: Defines events
      #
      # args - Can either be symbol (:potential) or hash (:archive => :archived)
      #
      # Returns Progression::Specification::Event
      def event(*args)
        name, to = args.first.is_a?(Symbol) ? args.first : args.first.to_a.flatten
        @events[name.to_sym] = Event.new(name, to)
      end

      # Public: Determine if a given event exists.
      #
      # state - Event name to check for.
      #
      # Returns true if event exists, false if not.
      def event?(state)
        @events.key?(state.to_sym)
      end
    end

    class Event
      attr_reader :name
      attr_reader :to

      def initialize(name, to = nil)
        @name = name
        @to   = to || name
      end
    end

    attr_reader :options
    attr_reader :states

    # Public: Define the different states and events the subject can go through.
    #
    # options - The Hash options used to build the specification (default: {}):
    #           :default - The default state the subject is instantiated at (optional).
    # block   - A required block that is used to define states and events for
    #           the subject.
    #
    # Returns Progression::Specification
    def initialize(options = {}, &block)
      raise MissingConfiguration if block.nil?

      @options = options
      @states = {}

      instance_eval(&block)
    end

    # Public: Determine if an event exists within the specification.
    #
    # event - Event to check for.
    #
    # Returns true if exists, false if not.
    def event?(event)
      event_names.include?(event.to_sym)
    end

    # Public: All possible events that can be applied to the subject. Doesn't
    # gaurantee it can progress to said states, but that they exist for the
    # subject.
    #
    # Returns Array of Symbols.
    def event_names
      @event_names ||= @states.collect do |_, state|
        state.events.keys
      end.flatten.uniq
    end

    # Public: Defines states
    #
    # state - The name of the state
    # block - block that is used to define events for the state.
    #
    # Returns Progression::Specification::State
    def state(state, &block)
      @states[state.to_sym] = State.new(&block)
    end

    # Public: Determine if a given state has been defined.
    #
    # state - The state name to check for.
    #
    # Returns true if defined, false if not.
    def state?(state)
      @states.key?(state.to_sym)
    end

    # Public: Returns the default state for the specification.
    #
    # Returns symbol.
    def default_state
      @default_state ||=
        if options.key?(:default)
          options[:default]
        elsif states.any?
          states.keys.first
        end
    end
  end
end
