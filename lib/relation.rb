class Relation
  attr_reader :where_line, :obj_class, :where_vals, :table_name

  def initialize(options)
    default = {
      class: options[:from].singularize.capitalize.constantize,
      select: "*",
      from: "",
      where_line: "",
      where_vals: []
    }
    default.merge!(options)

    @table_name = default[:from]
    @where_line = default[:where_line]
    @where_vals = default[:where_vals]
    @obj_class = default[:class]
  end

  def where(params)
    if params.is_a?(Hash)
      new_line = params_string(params)
      new_vals = params.values
    else
      new_line = params
      new_vals = []
    end

    self.where_line = "#{where_line} AND #{new_line}"
    self.where_vals = where_vals + new_vals
    self
  end

  def includes(*args)
  end

  def joins(table_name)
  end

  def method_missing(m, *args, &block)
    query.send(m, *args, &block)
  end

  def query
    result = DBConnection.execute(<<-SQL, where_vals)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    parse_all(result)
  end
  
  private
  attr_writer :where_line, :where_vals
  
  def parse_all(results)
    obj_class.parse_all(results)
  end

  def params_string(params)
    params.keys.map { |key| "#{key} = ?" }.join(" AND ")
  end
end