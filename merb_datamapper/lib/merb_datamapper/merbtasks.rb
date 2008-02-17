namespace :dm do
  desc "Automigrates all models"
  task :auto_migrate => :merb_init do
    DataMapper::Base.auto_migrate!
  end
end
    