module Progressive
  class State < ActiveRecord::Base
    belongs_to :subject, polymorphic: true
    validates :state, presence: true

    after_initialize :set_default_state, :if => :specification?
    before_validation :set_default_state, :on => :create

    def specification
      Progressive.specifications[subject_type]
    end

    def specification?
      return false unless loaded?
      specification.present?
    end

    # If we try to access subject_type before it's present, method_missing goes
    # nuts.
    #
    # Returns true if loaded, false if not.
    def loaded?
      !read_attribute(:subject_type).nil?
    end

    def method_missing(method_sym, *args, &block)
      return super unless loaded?

      if specification.event?(method_sym)
        to(method_sym, *args)
      elsif method_sym.to_s[-1] == '?' && specification.state?(method_sym.to_s[0..-2])
        predicate = method_sym.to_s[0..-2]
        state.to_sym == predicate.to_sym
      else
        super
      end
    end

    # This will be available for all callbacks to get better context around event
    # changes.
    #
    # Returns Hash.
    def default_event_context
      {}
    end

    # Public: Transition from the current state to a new state.
    #
    # state - The event
    #
    # Returns nothing.
    def to(event, options = {})
      return false unless current_state.event?(event)
      new_record = !!options.delete(:new_record) || subject.new_state_record_on_change?

      current_event = current_state.events[event]

      previous_event_context = subject.event_context
      subject.event_context = default_event_context.merge(options).merge({
        from: state.to_sym,
        to: current_event.to
      })

      subject.run_callbacks(:progress) do
        subject.run_callbacks(current_event.name) do
          if new_record
            record = dup
            record.state = current_event.to
            if record.save
              record
            else
              false
            end
          else
            update_attribute(:state, current_event.to)
          end
        end
      end
    ensure
      subject.event_context = previous_event_context
    end

    def current_state
      specification.states[state.to_sym]
    end

    def to_s
      state
    end

    def to_param
      state
    end

    private

    def set_default_state
      return unless specification?
      self.state ||= specification.default_state
    end
  end
end
