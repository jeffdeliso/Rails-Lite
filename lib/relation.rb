class Relation
  attr_reader :where_line, :obj_class, :where_vals, :table_name, :join_line, :select_line

  def initialize(options)
    default = {
      class: options[:table_name].singularize.capitalize.constantize,
      select_line: "*",
      table_name: "",
      where_line: "",
      where_vals: [],
      join_line: ""
    }
    default.merge!(options)

    @table_name = default[:table_name]
    @where_line = default[:where_line]
    @where_vals = default[:where_vals]
    @obj_class = default[:class]
    @join_line = default[:join_line]
    @select_line = default[:select_line]
  end

  def select(*params)
    if params.is_a?(Array)
      new_line = select_string(*params)
    else
      new_line = params
    end

    self.select_line = new_line
    self
  end

  def where(params)
    if params.is_a?(Hash)
      new_line = params_string(params)
      new_vals = params.values
    else
      new_line = params
      new_vals = []
    end
    
    if where_line.blank?
      self.where_line = new_line
    else
      self.where_line = "#{where_line} AND #{new_line}"
    end
    
    self.where_vals = where_vals + new_vals
    self
  end

  def includes(assoc)
    join_table_name = obj_class.assoc_options[assoc]
    joins(join_table_name)
    obj1_params = obj_class.columns
    # TODO
  end

  def joins(name)
    join_options = obj_class.assoc_options.values.find { |options| options.table_name == name }
    if join_options.is_a?(BelongsToOptions)
      table_id = join_options.foreign_key
      join_table_id = join_options.primary_key
    else
      table_id = join_options.primary_key
      join_table_id = join_options.foreign_key
    end

    self.join_line = "JOIN #{join_options.table_name} on #{join_options.table_name}.#{join_table_id} = #{table_name}.#{table_id}"
    self
  end

  def method_missing(m, *args, &block)
    parsed_query.send(m, *args, &block)
  end

  def parsed_query
    parse_all(query)
  end

  def query
    result = DBConnection.execute(<<-SQL, where_vals)
      SELECT
        #{select_line}
      FROM
        #{table_name}
      #{join_line}
      #{where_line.blank? ? "" : "WHERE"}
        #{where_line}
    SQL

    result
  end
  
  private
  attr_writer :where_line, :where_vals, :join_line, :select_line
  
  def parse_all(results)
    obj_class.parse_all(results)
  end

  def params_string(params)
    params.keys.map { |key| "#{table_name}.#{key} = ?" }.join(" AND ")
  end

  def select_string(*params)
    params.map { |column| "#{table_name}.#{column}" }.join(", ")
  end
end