namespace :feature do
  namespace :barclamp do
    feature_name "Test the AMQP Messaging service"

    desc "RabbitMQ Messaging service tests"
    feature_task :rabbitmq, tags: :@rabbitmq
    
    desc "Functional tests for RabbitMQ"
    feature_task  :all
  end
end
