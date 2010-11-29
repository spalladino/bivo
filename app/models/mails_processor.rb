class MailsProcessor
  BATCH_SIZE = 100
  MAX_RETRIES = 5
  
  def process
    to_be_removed = []
    to_increase_retries = []

    PendingMail.where("retries < ?", MAX_RETRIES).limit(BATCH_SIZE).each { |mail|
      begin
        Mailer.send mail.method, mail.unserialize
        to_be_removed << mail.id
      rescue
        to_increase_retries << mail.id
      end
    }
    
    if to_be_removed.any?
      PendingMail.delete_all(:id => to_be_removed)
    end

    if to_increase_retries.any?
      PendingMail.update_all("retries = retries + 1", :id => to_increase_retries)
    end
  end
end
