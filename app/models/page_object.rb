class PageObject < ActiveRecord::Base
  include ThriveSmartObjectMethods
  self.caching_default = "data_update[events]" #[in :forever, :page_update, :any_page_update, 'data_update[datetimes]', :never, 'interval[5]']

  attr_accessor :month, :year, :events
  
  def fetch_events(attrs = {})
    old_zone = Time.zone
    Time.zone = self.time_zone if self.time_zone
    now = Time.zone.now
    self.month = now.month
    self.year = now.year
    month_start = Time.zone.local(now.year, now.month, 1)
    month_end = Time.zone.local(now.year, now.month, 31)
    self.events = self.organization.find_data(:events, 
      :include => [:url, :start, :end, :name, :description, :picture], 
      :conditions => { :start => [month_start, month_end], :end => [month_start, month_end] })
    Time.zone = old_zone
  end
end
