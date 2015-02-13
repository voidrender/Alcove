require './lib/alcove/version'
Gem::Specification.new do |s|
    s.name        = 'alcove'
    s.version     = Alcove::VERSION
    s.date        = '2015-02-10'
    s.summary     = "Painless code coverage reporting for Objective-C."
    s.description = "Painless code coverage reporting for Xcode projects written in Objective-C."
    s.authors     = ['Isaac Overacker']
    s.email       = 'isaac@overacker.me'
    s.files       = Dir["lib/**/*.rb"] + %w{ bin/alcove README.md LICENSE }
    s.executables = 'alcove'
    s.homepage    = 'https://github.com/ioveracker/alcove'
    s.license     = 'MIT'

    s.add_runtime_dependency 'colored', '~> 1.2'
end
