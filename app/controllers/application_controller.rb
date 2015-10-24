class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def send_data_and_set_cookie(data, filename, file_type)
    cookies['fileDownload'] = 'true'
    send_data data, :filename => filename, :type => file_type
  end

end
