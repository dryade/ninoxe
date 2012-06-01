class Chouette::ConnectionLink < Chouette::TridentActiveRecord
  # FIXME http://jira.codehaus.org/browse/JRUBY-6358
  set_primary_key :id

  attr_accessible :departure_id, :arrival_id, :objectid, :object_version, :creation_time, :creator_id, :name, :comment, :link_distance, :link_type, :default_duration, :frequent_traveller_duration, :occasional_traveller_duration, :mobility_restricted_traveller_duration, :mobility_restricted_suitability, :stairs_availability, :lift_availability, :int_user_needs

  attr_accessor :connection_link_type

  belongs_to :departure, :class_name => 'Chouette::StopArea'
  belongs_to :arrival, :class_name => 'Chouette::StopArea'

  validates_presence_of :name

  def connection_link_type
    link_type && Chouette::ConnectionLinkType.new( link_type.underscore)
  end

  def connection_link_type=(connection_link_type)
    self.link_type = (connection_link_type ? connection_link_type.camelcase : nil)
  end

  @@connection_link_types = nil
  def self.connection_link_types
    @@connection_link_types ||= Chouette::ConnectionLinkType.all
  end

  def possible_areas
    Chouette::StopArea.where("area_type != 'ITL'")
  end

  def stop_areas
    Chouette::StopArea.where(:id => [self.departure_id,self.arrival_id])
  end

end

