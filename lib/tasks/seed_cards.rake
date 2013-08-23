desc "Seed Database with Implemented Cards"
task :seed_cards => :environment do
  Card.destroy_all
  system 'rake db:seed'
end
