Vedastore::ElectionReport.class_eval do
  include Vedaspector::Entity

  entity_action :title => 'Download', :action => 'download_report', :button_class => 'download-button btn-success'

  def download_report(controller)
    if election and election.name
      filename = "#{election.name.preferred_language_text}_report.xml"
    else
      filename = "election_report.xml"
    end

    content = self.to_xml_node.to_xml
    controller.send_data_and_set_cookie content, filename, 'application/xml; charset=utf-8'
  end

  def inspector_title_string
    if election and election.name and election.name.preferred_language_text
        "Election Report: #{election.name.preferred_language_text}"
    else
        "Election Report"
    end
  end
end
