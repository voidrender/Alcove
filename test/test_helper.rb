require 'codeclimate-test-reporter'
ENV['CODECLIMATE_REPO_TOKEN'] = '6298f1286a1bcb4263816164ce1a3ef5d6b8f7159f69b54c20c6fdc39ec3d173'
CodeClimate::TestReporter.start
puts "Started CodeClimate test reporter."
