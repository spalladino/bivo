class MailsProcessor
  include Singleton

  def process
    to_be_removed = []
    to_increase_retries = []
    errors = []

    PendingMail.where("retries < ?", max_retries).limit(batch_size).each do |mail|
      begin
        I18n.locale = Language.by_id(mail.language) || Language.default
        Mailer.send(mail.method, Marshal.load(mail.data).to_struct).deliver
        to_be_removed << mail.id
      rescue => e
        errors << e
        to_increase_retries << mail.id
      end
    end
    
    PendingMail.delete_all(:id => to_be_removed) if to_be_removed.any?
    PendingMail.update_all("retries = retries + 1", :id => to_increase_retries) if to_increase_retries.any?
    
    [to_be_removed.size, to_increase_retries.size, errors]
  end
  
  def max_retries
    Bivo::Application.config.mails_max_retries
  end
  
  def batch_size
    Bivo::Application.config.mails_batch_size
  end
end
