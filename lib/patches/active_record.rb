# TODO convert into real Validator
module PredicateValidatorMethod
  def validates_predicate attribute, meth
    word = meth.to_s.sub(/\?$/,'')
    validates_each attribute do |record, attr, value|
      if value.respond_to?(meth)
        record.errors.add attr, "is not #{word}" unless value.send(meth)
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  extend PredicateValidatorMethod
end

