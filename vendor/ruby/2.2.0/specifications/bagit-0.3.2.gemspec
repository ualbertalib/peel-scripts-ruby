# -*- encoding: utf-8 -*-
# stub: bagit 0.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "bagit"
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Tom Johnson, Francesco Lazzarino"]
  s.date = "2013-08-07"
  s.description = "Ruby Library and Command Line tools for bagit"
  s.email = "johnson.tom@gmail.com"
  s.executables = ["bagit"]
  s.files = ["bin/bagit"]
  s.homepage = "http://github.com/tipr/bagit"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "BagIt package generation and validation"

  s.installed_by_version = "2.4.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<validatable>, ["~> 1.6"])
      s.add_runtime_dependency(%q<docopt>, ["~> 0.5.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<validatable>, ["~> 1.6"])
      s.add_dependency(%q<docopt>, ["~> 0.5.0"])
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<validatable>, ["~> 1.6"])
    s.add_dependency(%q<docopt>, ["~> 0.5.0"])
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
