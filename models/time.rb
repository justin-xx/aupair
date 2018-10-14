class Time
  def beginning_of_day
    Time.mktime(year, month, day)
  end
  
  def end_of_day
    Time.mktime(year, month, day, '23', '59', '59')
  end
end