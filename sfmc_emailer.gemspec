Gem::Specification.new do |s|
  s.name        = "sfmc_emailer"
  s.version     = "1.0.1"
  s.summary     = "API wrapper for SFMC"
  s.description = "API wrapper for Salesforce Marketing Cloud's Transactional and Triggered Send APIs"
  s.authors     = ["Angel Ruiz-Bates"]
  s.email       = "angeljrbt@gmail.com"
  s.files       = Dir['lib/**/*.rb', '*.md']
  s.homepage    =
    "https://github.com/angeljruiz/SFMC-Email-Client"
  s.license     = "MIT"
  s.add_dependency 'httparty', '~> 0.20', '>= 0.20'
  s.add_development_dependency 'webmock', '~> 3.18.1', '>= 3.18.1'
  s.add_development_dependency 'rspec', '~> 3.11.0', '>= 3.11.0'
end