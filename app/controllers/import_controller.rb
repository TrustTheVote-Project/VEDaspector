class ImportController < ApplicationController

  def index

  end

  def upload
    report = Vssc::ElectionReport.parse_vssc_file params[:entity]
    report.save!

    redirect_to "/election_reports/#{report.id}"
  end

end