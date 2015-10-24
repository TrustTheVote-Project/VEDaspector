Vssc::ElectionReport.class_eval do

  def download_report(controller)
    if election and election.name
      filename = "#{election.name.inspector_preferred_text}_report.xml"
    else
      filename = "election_report.xml"
    end

    content = self.to_xml_node.to_xml
    controller.send_data_and_set_cookie content, filename, 'application/xml; charset=utf-8'
  end

  def inspector_action_buttons(request)
    [{:title => "Download", :href => request.original_url + '/download_report', :button_class => 'download_link btn-success'}]
  end

  def inspector_title_string
    if election and election.name
        s = "Election Report: #{election.name.inspector_preferred_text}"
        if generated_date
          s += " (#{generated_date.to_formatted_s(:short_date)})"
        end
        s
    else
        "Unnamed Election Report"
    end
  end
end
