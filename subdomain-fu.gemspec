# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'subdomain_fu/version'

Gem::Specification.new do |s|
  s.name = %q{subdomain-fu}
  s.version = SubdomainFu::VERSION
  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ['Michael Bleigh', 'Jared Beck']
  s.date = %q{2011-01-04}
  s.description = %q{SubdomainFu is a Rails plugin to provide all of the basic functionality necessary to handle multiple subdomain applications (such as Basecamp-esque subdomain accounts and more).}
  s.email = %q{michael@intridea.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "CHANGELOG",
    "MIT-LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/subdomain-fu.rb",
    "lib/subdomain_fu/engine.rb",
    "lib/subdomain_fu/plugin.rb",
    "lib/subdomain_fu/subdomain_fu.rb",
    "lib/subdomain_fu/url_rewriter.rb"
  ]
  s.homepage = %q{http://github.com/mbleigh/subdomain-fu}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{SubdomainFu is a Rails plugin that provides subdomain routing and URL writing helpers.}
  s.test_files = [
    "spec/spec_helper.rb",
    "spec/subdomain_fu_spec.rb",
    "spec/url_rewriter_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end

  s.add_runtime_dependency 'rails', '~> 6.0', '< 7.0'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec-core', '~> 3.0'
  s.add_development_dependency 'rspec-expectations', '~> 3.0'
  s.add_development_dependency 'rspec-mocks', '~> 3.0'
end
