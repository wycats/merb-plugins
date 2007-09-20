namespace :sequel do
  namespace :db do
    desc "Perform migration using migrations in schema/migrations"
    task :migrate => :merb_env do
      Sequel::Migrator.apply(Merb::Orms::Sequel.connect, "schema/migrations", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end
  end
end