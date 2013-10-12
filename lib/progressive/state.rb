module Progressive
  class State < ActiveRecord::Base
    belongs_to :subject, :polymorphic => true

    validates :subject_type, :presence => true
    validates :subject_id, :presence => true, :uniqueness => { :scope => [:subject_type] }
    validates :state, :presence => true

    def specification
      @specification ||= subject.specification
    end

    def method_missing(method_sym, *args, &block)
      if specification.state?(method_sym)
        to(method_sym, *args)
      elsif method_sym.to_s[-1] == '?'
        predicate = method_sym.to_s[0..-2]
        state == predicate
      else
        super
      end
    end

    # Public: Transition from the current state to a new state.
    #
    # state - The event
    #
    # Returns nothing.
    def to(state, options = {})
      return false unless current_state.event?(state)

      subject.run_callbacks(:progress) do
        subject.run_callbacks(state) do
          update_attribute(:state, state)
        end
      end
    end

    def current_state
      specification.states[state.to_sym]
    end

    def to_s
      state
    end
    delegate :humanize, :to => :to_s
  end
end
