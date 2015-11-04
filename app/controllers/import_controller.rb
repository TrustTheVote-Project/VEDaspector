class ImportController < ApplicationController

  def index

  end

  def upload
    report = Vedastore::ElectionReport.parse_ved_file params[:entity]
    report.save!

    redirect_to "/election_reports/#{report.id}"
  end

end