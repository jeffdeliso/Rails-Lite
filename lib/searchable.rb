# require_relative 'db_connection'
# require_relative 'sql_object'

module Searchable
  
  def where(params)
    result = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{params_string(params)}
    SQL
    self.parse_all(result)
  end
  
  private

  def params_string(params)
    params.keys.map { |key| "#{key} = ?" }.join(" AND ")
  end
end

# def param_str(params)
#   params.map do |k, v|
#     if v.to_i.zero?
#      "#{k} = '#{v}'"
#     else
#       "#{k} = #{v}"
#     end
#   end
#   .join(" AND ")
# end