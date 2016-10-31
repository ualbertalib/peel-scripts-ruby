# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "curb"
  s.version = "0.8.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ross Bamford", "Todd A. Fisher"]
  s.date = "2015-04-08"
  s.description = "Curb (probably CUrl-RuBy or something) provides Ruby-language bindings for the libcurl(3), a fully-featured client-side URL transfer library. cURL and libcurl live at http://curl.haxx.se/"
  s.email = "todd.fisher@gmail.com"
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = ["LICENSE", "README.markdown"]
  s.files = ["LICENSE", "README.markdown", "ext/extconf.rb"]
  s.homepage = "http://curb.rubyforge.org/"
  s.rdoc_options = ["--main", "README.markdown"]
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = "curb"
  s.rubygems_version = "1.8.23"
  s.summary = "Ruby libcurl bindings"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
