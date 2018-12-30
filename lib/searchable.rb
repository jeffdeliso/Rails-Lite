module Searchable
  
  def where(params)
  #   if params.is_a?(Hash)
  #     where_line = params_string(params)
  #     vals = params.values
  #   else
  #     where_line = params
  #     vals = []
  #   end
      
  #   # result = DBConnection.execute(<<-SQL, vals)
  #   #   SELECT
  #   #     *
  #   #   FROM
  #   #     #{self.table_name}
  #   #   WHERE
  #   #     #{where_line}
  #   # SQL
  #   # self.parse_all(result)

  #   Relation.new(where_line: where_line, where_vals: vals, from: self.table_name)

    relation = Relation.new(table_name: self.table_name)
    relation.where(params)
  end

  def joins(table_name)
    relation = Relation.new(table_name: self.table_name)
    relation.joins(table_name)
  end

  def select(*params)
    relation = Relation.new(table_name: self.table_name)
    relation.select(*params)
  end

  def find_by(params)
    where(params).first
  end
  
  # private

  # def params_string(params)
  #   params.keys.map { |key| "#{self.table_name}.#{key} = ?" }.join(" AND ")
  # end
end