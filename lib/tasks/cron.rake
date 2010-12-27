desc "Cron for sending pending emails"
task :cron => :environment do
  sent, failed, errors = MailsProcessor.instance.process
  puts "Successfully sent #{sent} mails; #{failed} failed"
  errors.each do |err|
    puts " #{err.inspect}"
  end
end
