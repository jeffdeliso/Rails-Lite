require_relative 'searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.to_s.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    default = {foreign_key: "#{name}_id".to_sym, class_name: name.to_s.capitalize , primary_key: :id}
    default.merge!(options)

    @foreign_key = default[:foreign_key]
    @class_name = default[:class_name]
    @primary_key = default[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    default = {foreign_key: "#{self_class_name.downcase}_id".to_sym, class_name: name.to_s.capitalize.singularize , primary_key: :id}
    default.merge!(options)

    @foreign_key = default[:foreign_key]
    @class_name = default[:class_name]
    @primary_key = default[:primary_key]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    key = options.class_name.to_s.downcase.to_sym
    assoc_options[key] = options
    self.define_method(name) do 
      options.model_class.find(self.send(options.foreign_key))
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    self.define_method(name) do 
      options.model_class.where(options.foreign_key => self.send(options.primary_key))
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    self.define_method(name) do 
      self.send(through_name).send(source_name)
    end
  end
end