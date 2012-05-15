class Chouette::TimeTableDate < Chouette::ActiveRecord
  set_primary_keys :timetableid, :position
  belongs_to :time_table
  acts_as_list :scope => 'timetableid = #{time_table_id}',:top_of_list => 0
  
  def self.model_name
    ActiveModel::Name.new Chouette::TimeTableDate, Chouette, "TimeTableDate"
  end
end

