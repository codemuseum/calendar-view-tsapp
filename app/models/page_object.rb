class PageObject < ActiveRecord::Base
  include ThriveSmartObjectMethods
  self.caching_default = "data_update[events]" #[in :forever, :page_update, :any_page_update, 'data_update[datetimes]', :never, 'interval[5]']
  self.caching_scope_default = 'request_param[month]' #[in '', 'request_param[month]'] - a new cached object will be created for each scope value

  attr_accessor :month, :year, :events
  
  def fetch_events(attrs = {})
    Time.zone = self.time_zone if self.time_zone
    unless page_query_parameters[:month].blank?
      self.month, self.year = page_query_parameters[:month].split('-', 2).map(&:to_i)
    else
      now = Time.zone.now
      self.month, self.year = now.month, now.year
    end
    month_start = Time.zone.local(self.year, self.month, 1)
    month_end = Time.zone.local(self.year, self.month, 31)
    
    self.events = self.organization.find_data(:events, 
      :include => [:url, :start, :end, :name, :description, :picture], 
      :conditions => { :start => [month_start, month_end], :end => [month_start, month_end] })
  end
end
