class TrashDay
  attr_reader :date, :types

  def initialize(date, types)
    @date = date
    @types = Array(types)
  end

  def to_s
    types.join(", ")
  end

  def days_from_today
    (date - Date.today).to_i
  end
end
