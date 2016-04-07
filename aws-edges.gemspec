$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'aws-edges/version'

Gem::Specification.new 'aws-edges', AWSEdges::VERSION do |s| 
  s.license = 'GPL-3.0'
  s.date  = '2016-04-07'
  s.summary = 'Simple AWS architecture charts'
  s.description = 'AWS Edges is used to chart out your AWS environments'
  s.files = `git ls-files`.split("\n") - %w[]
  s.author  = 'Rick Briganti'
  s.email = 'jeviolle@newaliases.org'
  s.homepage  = 'http://github.com/jeviolle/aws-edges'
  s.add_runtime_dependency 'aws-sdk', '~> 1.34', '>=1.34.0'
  s.add_runtime_dependency 'graph', '~> 2.6', '>=2.6.0'
  s.bindir = 'bin'
  s.executables << 'aws-edges'
end
