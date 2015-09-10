namespace :feature do
  feature_name "Test the database server resource"

  namespace :barclamp do
    namespace :database do
      desc "Verify the postresql database server"
      feature_task :postgres, tags: :@postgresql
    end
  end
end
