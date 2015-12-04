Vedastore::Contest.class_eval do
  include Vedaspector::Entity
  
  def inspector_title_string
    "Contest: #{name}"
  end
  
  def self.concrete_types
    [Vedastore::BallotMeasureContest, Vedastore::CandidateContest]
  end
  
end
