Vedastore::GpUnit.class_eval do
  include Vedaspector::Entity
  
  def inspector_title_string
    if name
      "GP Unit: #{name}"
    else
      "Unnamed GP Unit"
    end
  end
end
