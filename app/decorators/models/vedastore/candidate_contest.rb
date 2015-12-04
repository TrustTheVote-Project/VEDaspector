Vedastore::CandidateContest.class_eval do
  include Vedaspector::Entity
  
  preferred_name "Candidate Contest"
  
  specific_type "BallotSelection", Vedastore::CandidateSelection
  
end
