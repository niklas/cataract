module Spec
  module Matchers
    
    #Based on patch from Wilson Bilkovich
    class Change #:nodoc:
      def initialize(receiver=nil, message=nil, &block)
        @receiver = receiver
        @message = message
        @block = block
      end
      
      def matches?(target, &block)
        if block
          raise MatcherError.new(<<-EOF
block passed to should or should_not change must use {} instead of do/end
EOF
)
        end
        @target = target
        execute_change
        return false if @from && (@from != @before)
        return false if @to && (@to != @after)
        return (@before + @amount == @after) if @amount
        return @before != @after
      end
      
      def execute_change
        @before = @block.nil? ? @receiver.send(@message) : @block.call
        @target.call
        @after = @block.nil? ? @receiver.send(@message) : @block.call
      end
      
      def failure_message
        if @to
          "#{result} should have been changed to #{@to.inspect}, but is now #{@after.inspect}"
        elsif @from
          "#{result} should have initially been #{@from.inspect}, but was #{@before.inspect}"
        elsif @amount
          "#{result} should have been changed by #{@amount.inspect}, but was changed by #{actual_delta.inspect}"
        else
          "#{result} should have changed, but is still #{@before.inspect}"
        end
      end
      
      def result
        @message || "result"
      end
      
      def actual_delta
        @after - @before
      end
      
      def negative_failure_message
        "#{result} should not have changed, but did change from #{@before.inspect} to #{@after.inspect}"
      end
      
      def by(amount)
        @amount = amount
        self
      end
      
      def to(to)
        @to = to
        self
      end
      
      def from (from)
        @from = from
        self
      end
    end
    
    # :call-seq:
    #   should change(receiver, message, &block)
    #   should change(receiver, message, &block).by(value)
    #   should change(receiver, message, &block).from(old).to(new)
    #   should_not change(receiver, message, &block)
    #
    # Allows you to specify that a Proc will cause some value to change.
    #
    # == Examples
    #
    #   lambda {
    #     team.add_player(player) 
    #   }.should change(roster, :count)
    #
    #   lambda {
    #     team.add_player(player) 
    #   }.should change(roster, :count).by(1)
    #
    #   string = "string"
    #   lambda {
    #     string.reverse
    #   }.should change { string }.from("string").to("gnirts")
    #
    #   lambda {
    #     person.happy_birthday
    #   }.should change(person, :birthday).from(32).to(33)
    #       
    #   lambda {
    #     employee.develop_great_new_social_networking_app
    #   }.should change(employee, :title).from("Mail Clerk").to("CEO")
    #
    # Evaluates +receiver.message+ or +block+ before and
    # after it evaluates the c object (generated by the lambdas in the examples above).
    #
    # Then compares the values before and after the +receiver.message+ and
    # evaluates the difference compared to the expected difference.
    #
    # == Warning
    # +should_not+ +change+ only supports the form with no subsequent calls to
    # +be+, +to+ or +from+.
    #
    # blocks passed to +should+ +change+ and +should_not+ +change+
    # must use the <tt>{}</tt> form (<tt>do/end</tt> is not supported)
    def change(target=nil, message=nil, &block)
      Matchers::Change.new(target, message, &block)
    end
  end
end
