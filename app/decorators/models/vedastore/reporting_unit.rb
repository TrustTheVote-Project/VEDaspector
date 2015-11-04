Vedastore::ReportingUnit.class_eval do
  include Vedaspector::Entity

  def inspector_title_string
    if name
      "Reporting Unit: #{name}"
    else
      "Unnamed Reporting Unit"
    end
  end
end
