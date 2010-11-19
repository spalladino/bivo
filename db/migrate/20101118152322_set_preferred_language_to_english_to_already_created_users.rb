class SetPreferredLanguageToEnglishToAlreadyCreatedUsers < ActiveRecord::Migration
  def self.up
    User.update_all("preferred_language = 'en'")
  end

  def self.down
    User.update_all("preferred_language = NULL")
  end
end
