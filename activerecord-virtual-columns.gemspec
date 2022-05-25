require_relative 'lib/activerecord-virtual-columns/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-virtual-columns"
  spec.version       = Activerecord::VirtualColumns::VERSION
  spec.authors       = ["Reid Lynch"]
  spec.email         = ["reid.lynch@gmail.com"]

  spec.summary       = %q{Use your ActiveRecord relations to conventiently run sub-select queries}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/rigoleto/activerecord-virtual-columns"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rigoleto/activerecord-virtual-columns"
  spec.metadata["changelog_uri"] = "https://github.com/rigoleto/activerecord-virtual-columns"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 5"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "sqlite3", "~> 1.4"
end
