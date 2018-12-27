require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    result = DBConnection.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{param_str(params)}
    SQL
    self.parse_all(result)
  end

  def param_str(params)
    params.map do |k, v|
      if v.to_i.zero?
       "#{k} = '#{v}'"
      else
        "#{k} = #{v}"
      end
    end
    .join(" AND ")
  end
end
