require_relative 'db_connection'
require_relative 'searchable'
require_relative 'associatable'
require 'active_support/inflector'

class SQLObject
  extend Searchable
  extend Associatable

  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)
      Select 
        * 
      FROM 
        '#{self.table_name}' 
      LIMIT 0
    SQL
    .first.map!(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do 
        attributes[column]
      end
      
      setter_name = column.to_s + "="
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
    results = DBConnection.execute(<<-SQL, id)
      Select 
        * 
      FROM 
        '#{table_name}' 
      WHERE 
        id = ?
    SQL
    parse_all(results).first
  end

  def initialize(params = {})
    self.class.finalize!

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
  
  private
  
  def insert
    raise "#{self} already in database" if self.id
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{column_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end
  
  def update
    DBConnection.instance.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{update_string}
      WHERE
        id = ?
    SQL
  end
  
  def question_marks
    (["?"] * attributes.count).join(", ")
  end
  
  def column_names 
    attributes.keys.map(&:to_s).join(", ")
  end
  
  def update_string
    attributes.keys.map { |attr| "#{attr} = ?" }.join(", ")
  end
end

# def insert_str
#   result = "#{self.class.table_name} ("
#   vars = self.class.columns[1..-1]
#   vars.each_with_index do |ivar, idx|
#     result += ivar.to_s
#     result += ", " unless idx == vars.length - 1
#   end
#   result += ")"
# end

# def insert_values
#   result = "("
#   vars = self.class.columns[1..-1]
#   vars.each_with_index do |ivar, idx|
#     if ivar..to_s.to_i.zero?
#       result += "'#{self.send(ivar)}'" 
#     else
#       result += "#{self.send(ivar)}" 
#     end
#     result += ", " unless idx == vars.length - 1
#   end
#   result += ")"
# end

# def update_str
#   result = ""
#   vars = self.class.columns[1..-1]
#   vars.each_with_index do |ivar, idx|
#     if ivar.to_s.to_i.zero?
#       result += "#{ivar} = '#{self.send(ivar)}'" 
#     else
#       result += "#{ivar} = #{self.send(ivar)}" 
#     end
#     result += ", " unless idx == vars.length - 1
#   end
#   result
# end