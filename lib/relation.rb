class Relation
  attr_reader :options

  def initialize(options)
    default = {
      select: "*",
      from: "",
      where_line: "",
      where_vals: []
    }
    default.merge!(options)
  end

  def where
  end

  def includes
  end

  def joins
  end

  
end