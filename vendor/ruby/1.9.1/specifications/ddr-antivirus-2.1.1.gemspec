# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ddr-antivirus"
  s.version = "2.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Chandek-Stark"]
  s.date = "2015-11-04"
  s.description = "Pluggable antivirus scanning service."
  s.email = ["dchandekstark@gmail.com"]
  s.homepage = "https://github.com/duke-libraries/ddr-antivirus"
  s.licenses = ["BSD-3-Clause"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Pluggable antivirus scanning service."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.6"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.6"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.6"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
  end
end
