Vedastore::Candidate.class_eval do
  include Vedaspector::Entity
  
  def inspector_title_string
    if ballot_name
      "Candidate: #{ballot_name.preferred_language_text}"
    else
      "Unnamed Candidate"
    end

  end
end



