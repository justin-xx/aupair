class Time
  def beginning_of_day
    Time.mktime(year, month, day).send(gmt? ? :gmt : :localtime)
  end
  
  def end_of_day
    Time.mktime(year, month, day, '23', '59', '59').send(gmt? ? :gmt : :localtime)
  end
end