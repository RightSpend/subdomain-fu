require 'spec_helper'

describe 'SubdomainFu URL Writing' do
  before do
    SubdomainFu.config.tld_size = 1
    SubdomainFu.config.mirrors = SubdomainFu::Configuration.defaults[:mirrors].dup
    SubdomainFu.config.override_only_path = true
    SubdomainFu.config.preferred_mirror = nil
    default_url_options[:host] = 'example.com'
  end

  describe '#url_for' do
    it 'able to add a subdomain' do
      url = url_for(controller: 'something', action: 'other', subdomain: 'awesome')

      expect(url).to eq('http://awesome.example.com/something/other')
    end

    it 'ables to remove a subdomain' do
      url = url_for(controller: 'something', action: 'other', subdomain: false, host: 'awesome.example.com')

      expect(url).to eq('http://example.com/something/other')
    end

    it 'does not change a mirrored subdomain' do
      url = url_for(controller: 'something', action: 'other', subdomain: false, host: 'www.example.com')

      expect(url).to eq('http://www.example.com/something/other')
    end

    it 'does not force the full url with :only_path if override_only_path is false (default)' do
      SubdomainFu.config.override_only_path = false
      url = url_for(controller: 'something', action: 'other', subdomain: 'awesome', only_path: true)

      expect(url).to eq('/something/other')
    end

    it 'force the full url, even with :only_path if override_only_path is true' do
      SubdomainFu.config.override_only_path = true
      url = url_for(controller: 'something', action: 'other', subdomain: 'awesome', only_path: true)

      expect(url).to eq('http://awesome.example.com/something/other')
    end
  end

  describe 'Standard Routes' do
    it 'able to add a subdomain' do
      url = needs_subdomain_url(subdomain: 'awesome')

      expect(url).to eq('http://awesome.example.com/needs_subdomain')
    end

    it 'able to remove a subdomain' do
      default_url_options[:host] = 'awesome.example.com'
      url = needs_subdomain_url(subdomain: false)

      expect(url).to eq('http://example.com/needs_subdomain')
    end

    it 'does not change a mirrored subdomain' do
      default_url_options[:host] = 'www.example.com'
      url = needs_subdomain_url(subdomain: false)

      expect(url).to eq('http://www.example.com/needs_subdomain')
    end
  end

  describe "Resourced Routes" do
    it 'be able to add a subdomain' do
      url = foo_url(id: 'something', subdomain: 'awesome')

      expect(url).to eq('http://awesome.example.com/foos/something')
    end

    it 'be able to remove a subdomain' do
      default_url_options[:host] = 'awesome.example.com'
      url = foo_url(id: 'something', subdomain: false)

      expect(url).to eq('http://example.com/foos/something')
    end

    it 'works when passed in a paramable object' do
      url = foo_url(Paramed.new('something'), subdomain: 'awesome')

      expect(url).to eq('http://awesome.example.com/foos/something')
    end

    it 'works when passed in a paramable object' do
      url = foo_url(Paramed.new('something'), subdomain: 'awesome')

      expect(url).to eq('http://awesome.example.com/foos/something')
    end

    it 'works when passed in a paramable object and no subdomain to a _url' do
      default_url_options[:host] = 'awesome.example.com'
      url = foo_url(Paramed.new('something'))

      expect(url).to eq('http://awesome.example.com/foos/something')
    end

    it 'works on nested resource collections' do
      url = foo_bars_url(Paramed.new('something'), subdomain: 'awesome')

      expect(url).to eq('http://awesome.example.com/foos/something/bars')
    end

    it 'works on nested resource members' do
      url = foo_bar_url(Paramed.new('something'), Paramed.new('else'), subdomain: 'awesome')

      expect(url).to eq('http://awesome.example.com/foos/something/bars/else')
    end
  end

  describe 'Preferred Mirror' do
    before do
      SubdomainFu.config.preferred_mirror = 'www'
      SubdomainFu.config.override_only_path = true
    end

    it 'switch to the preferred mirror instead of no subdomain' do
      default_url_options[:host] = 'awesome.example.com'

      expect(needs_subdomain_url(subdomain: false)).to eq('http://www.example.com/needs_subdomain')
    end

    it 'switch to the preferred mirror automatically' do
      default_url_options[:host] = 'example.com'

      expect(needs_subdomain_url).to eq('http://www.example.com/needs_subdomain')
    end

    it 'works when passed in a paramable object and no subdomain to a _url' do
      default_url_options[:host] = 'awesome.example.com'

      expect(foo_url(Paramed.new('something'))).to eq('http://awesome.example.com/foos/something')
    end

    it 'force a switch to no subdomain on a mirror if preferred_mirror is false' do
      SubdomainFu.config.preferred_mirror = false
      default_url_options[:host] = 'www.example.com'

      expect(needs_subdomain_url(subdomain: false)).to eq('http://example.com/needs_subdomain')
    end

    after do
      SubdomainFu.config.preferred_mirror = nil
    end
  end

  after do
    SubdomainFu.config.tld_size = 0
    default_url_options[:host] = 'localhost'
  end
end
