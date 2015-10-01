namespace :feature do
  feature_name "Test the database server resource"

  namespace :barclamp do
    namespace :database do
      feature_task :postgres, tags: :@postgresql

    end

    desc "Verify the database resource"
    task :database => :"database:postgres"
  end
end
