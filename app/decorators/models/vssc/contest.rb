Vssc::Contest.class_eval do
  include VsscEntity
  
  def inspector_title_string
    "Contest: #{name}"
  end
end
