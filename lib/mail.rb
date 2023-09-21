# -*- encoding: utf-8 -*-

module Papamira
  class App < Sinatra::Base

    def mail_send(params)
      RestClient.post(
        "https://api:#{ENV['MAIL_API_KEY']}" "@api.mailgun.net/v3/#{ENV['MAIL_API_URL']}/messages",
        :from => ENV['MAIL_FROM'],
        :to => ENV['MAIL_TO'],
        :subject => "[Contact Us] (" + params[:req_uid].to_s + ")",
        :text => "-----------------------------------------------\n" +
          "お問い合わせ\n" +
          "-----------------------------------------------\n" +
          "From1: " + request.env['HTTP_X_FORWARDED_FOR'].to_s + "\n" +
          "From2: " + request.env['REMOTE_ADDR'].to_s + "\n" +
          "Agent: " + request.env['HTTP_USER_AGENT'].to_s + "\n" +
          "-----------------------------------------------\n" +
          "Name: " + params[:f_name].toutf8 + "\n" +
          "Mail: " + params[:f_mail].toutf8 + "\n" +
          "Subject: " + params[:f_subject].toutf8 + " (" + params[:req_uid].to_s + ")\n" +
          "-----------------------------------------------\n" +
          "Text: " + params[:f_text].toutf8 + "\n" +
          "-----------------------------------------------\n"
      )
    end

  end
end
