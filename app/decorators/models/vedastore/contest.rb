Vedastore::Contest.class_eval do
  include Vedaspector::Entity
  
  def inspector_title_string
    "Contest: #{name}"
  end
end
