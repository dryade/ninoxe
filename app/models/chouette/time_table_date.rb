class Chouette::TimeTableDate < Chouette::ActiveRecord
  set_primary_key :id
  belongs_to :time_table
  acts_as_list :scope => 'time_table_id = #{time_table_id}',:top_of_list => 0
  
  validates_presence_of :date
  validates_uniqueness_of :date, :scope => :time_table_id

  attr_accessible :date, :position, :time_table_id, :time_table
  def self.model_name
    ActiveModel::Name.new Chouette::TimeTableDate, Chouette, "TimeTableDate"
  end
end

