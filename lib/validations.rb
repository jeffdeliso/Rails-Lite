
class Validator
  attr_reader :options, :attribute

  def initialize(attribute, options = {})
    default = {
      presence: false,
      uniqueness: false,
      class: nil
    }
    default.merge!(options)

    @attribute = attribute
    @options = default
  end

  def presence(_obj, val, errors_array)
    errors_array << "#{attribute} must be present" if val.blank?
  end

  def uniqueness(obj, val, errors_array)
    arr = obj.class.where("#{attribute} = '#{val}' AND id != #{obj.id || 'NULL'}")
    errors_array << "#{attribute} must be unique" unless arr.empty?
  end

  def class(_obj, val, errors_array)
    errors_array << "#{attribute} must be #{options[:class]}" unless val.is_a?(options[:class])
  end

  def valid?(obj)
    errors(obj).empty?
  end

  def errors(obj)
    errors_array = []
    val = obj.send(attribute)

    options.each do |name, validate|
      self.send(name, obj, val, errors_array) if validate
    end

    errors_array
  end
end

module Validations

  def validators
    @validators ||= []
  end

  def validates(attribute, options = {})
    validators << Validator.new(attribute, options)
  end

  def valid?
    self.class.validators.all? { |validator| validator.valid?(self) }
  end

  def errors
    errors_array = []
    self.class.validators.each do |validator|
      errors_array += validator.errors(self)
    end

    errors_array
  end

end
