Vssc::BallotStyle.class_eval do
  include VsscEntity

  def inspector_title_string
    if object_id
      "Ballot Style: #{object_id}"
    else
      "Unidentified Ballot Style"
    end
  end
end
