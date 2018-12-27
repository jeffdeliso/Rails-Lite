require_relative 'db_connection'
require_relative 'searchable'
require_relative 'associatable'
require 'active_support/inflector'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  extend Searchable
  extend Associatable

  def self.columns
    @columns ||= DBConnection.instance.execute2("Select * FROM '#{self.table_name}' LIMIT 1").first.map { |str| str.to_sym }
  end

  def self.finalize!
    columns.each do |column|
      setter_name = column.to_s + "="
      define_method(column) do 
        attributes[column]
      end
      define_method(setter_name) do |val|
        attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.downcase.pluralize
  end

  def self.all
    results = DBConnection.execute("Select * FROM #{self.table_name}")
    parse_all(results)
  end

  def self.parse_all(results)
    results.map do |params|
      new(params)
    end
  end

  def self.find(id)
    results = DBConnection.instance.execute(<<-SQL, id)
      Select * 
      FROM '#{table_name}' 
      WHERE id = ?
    SQL
    parse_all(results).first
  end

  def initialize(params = {})
    # self.class.finalize!
    params.each do |k, v|
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k.to_sym)
      str = k.to_s + "="
      self.send(str, v)
    end
  end

  def update_params(params = {})
    params.each do |k, v|
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k.to_sym)
      str = k.to_s + "="
      self.send(str, v)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    raise "#{self} already in database" if self.id
    DBConnection.instance.execute(<<-SQL)
      INSERT INTO
        #{insert_str}
      VALUES
        #{insert_values}
    SQL
    self.id = DBConnection.instance.last_insert_row_id
  end

  def insert_str
    result = "#{self.class.table_name} ("
    vars = self.class.columns[1..-1]
    vars.each_with_index do |ivar, idx|
      result += ivar.to_s
      result += ", " unless idx == vars.length - 1
    end
    result += ")"
  end

  def insert_values
    result = "("
    vars = self.class.columns[1..-1]
    vars.each_with_index do |ivar, idx|
      if ivar..to_s.to_i.zero?
        result += "'#{self.send(ivar)}'" 
      else
        result += "#{self.send(ivar)}" 
      end
      result += ", " unless idx == vars.length - 1
    end
    result += ")"
  end


  def update
      DBConnection.instance.execute(<<-SQL, id)
        UPDATE
          #{self.class.table_name}
        SET
          #{update_str}
        WHERE
          id = ?
      SQL
  end

  def update_str
    result = ""
    vars = self.class.columns[1..-1]
    vars.each_with_index do |ivar, idx|
      if ivar.to_s.to_i.zero?
        result += "#{ivar} = '#{self.send(ivar)}'" 
      else
        result += "#{ivar} = #{self.send(ivar)}" 
      end
      result += ", " unless idx == vars.length - 1
    end
    result
  end

  def save
    if id
      update
    else
      insert
    end
  end

  def destroy
    DBConnection.instance.execute(<<-SQL, id)
      DELETE
      FROM
        #{self.class.table_name}
      WHERE
        id = ?
    SQL
  end
end
