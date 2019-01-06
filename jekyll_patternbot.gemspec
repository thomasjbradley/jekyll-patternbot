require 'yaml'

config = YAML.load_file(File.expand_path('_config.yml', __dir__))

Gem::Specification.new do |spec|
  spec.name          = 'jekyll_patternbot'
  spec.version       = config['patternbot']['version']
  spec.authors       = ['Thomas J Bradley']
  spec.email         = ['hey@thomasjbradley.ca']

  spec.summary       = 'Your pompous and persnickety patterning robot.'
  spec.description   = 'A Jekyll plugin for developing pattern libraries & style guides that can be used to generate a Jekyll website.'
  spec.homepage      = 'https://github.com/thomasjbradley/jekyll_patternbot/'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.add_runtime_dependency 'jekyll', '~> 3.8'
  spec.add_runtime_dependency 'unicode_titlecase'
  spec.add_runtime_dependency 'css_parser'
  spec.add_runtime_dependency 'rgb'
  spec.add_runtime_dependency 'jekyll_patternbot_plugins'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
