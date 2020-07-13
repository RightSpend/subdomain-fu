require 'spec_helper'

describe 'SubdomainFu' do
  before do
    SubdomainFu.config.tld_sizes = SubdomainFu::Configuration.defaults[:tld_sizes].dup
    SubdomainFu.config.mirrors = SubdomainFu::Configuration.defaults[:mirrors].dup
    SubdomainFu.config.preferred_mirror = nil
  end

  describe 'TLD Sizes' do
    before do
      SubdomainFu.config.tld_sizes = SubdomainFu::Configuration.defaults[:tld_sizes].dup
    end

    it { expect(SubdomainFu.config.tld_sizes).to be_kind_of(Hash) }

    it 'has default values for development, test, and production' do
      expect(SubdomainFu.config.tld_sizes[:development]).to eq(0)
      expect(SubdomainFu.config.tld_sizes[:test]).to eq(0)
      expect(SubdomainFu.config.tld_sizes[:production]).to eq(1)
    end

    it '#tld_size should be for the current environment' do
      expect(SubdomainFu.config.tld_size).to eq(SubdomainFu.config.tld_sizes[Rails.env.to_sym])
    end

    it 'able to be set for the current environment' do
      SubdomainFu.config.tld_size = 5

      expect(SubdomainFu.config.tld_size).to eq(5)
      expect(SubdomainFu.config.tld_sizes[:test]).to eq(5)
    end
  end

  describe '#has_domain?' do
    it 'returns true for domains with tld' do
      expect(SubdomainFu.has_domain?('my.example.com')).to be_truthy
      expect(SubdomainFu.has_domain?('bonkers.example.net')).to be_truthy
    end

    it 'returns false for IP addresses' do
      expect(SubdomainFu.has_domain?('192.168.100.252')).to be_falsy
      expect(SubdomainFu.has_domain?('127.0.0.1')).to be_falsy
      expect(SubdomainFu.has_domain?('4.2.2.2')).to be_falsy
    end

    it 'returns true for localhost' do
      expect(SubdomainFu.has_domain?('localhost:3000')).to be_truthy
      expect(SubdomainFu.has_domain?('www.localhost')).to be_truthy
      expect(SubdomainFu.has_domain?('www.localhost:3000')).to be_truthy
      expect(SubdomainFu.has_domain?('localhost')).to be_truthy
    end

    it 'returns false for a nil or blank subdomain' do
      expect(SubdomainFu.has_domain?('')).to be_falsy
      expect(SubdomainFu.has_domain?(nil)).to be_falsy
      expect(SubdomainFu.has_domain?(false)).to be_falsy
    end
  end

  describe '#has_subdomain?' do
    it 'returns true for non-mirrored subdomains' do
      expect(SubdomainFu.has_subdomain?('awesome')).to be_truthy
    end

    it 'returns false for mirrored subdomains' do
      expect(SubdomainFu.has_subdomain?(SubdomainFu.config.mirrors.first)).to be_falsy
    end

    it 'returns false for a nil or blank subdomain' do
      expect(SubdomainFu.has_subdomain?('')).to be_falsy
      expect(SubdomainFu.has_subdomain?(nil)).to be_falsy
      expect(SubdomainFu.has_subdomain?(false)).to be_falsy
    end
  end

  describe '#subdomain_from' do
    it 'returns the subdomain based on the TLD of the current environment' do
      expect(SubdomainFu.subdomain_from('awesome.localhost')).to eq('awesome')

      SubdomainFu.config.tld_size = 2

      expect(SubdomainFu.subdomain_from('awesome.localhost.co.uk')).to eq('awesome')

      SubdomainFu.config.tld_size = 1

      expect(SubdomainFu.subdomain_from('awesome.localhost.com')).to eq('awesome')

      SubdomainFu.config.tld_size = 0
    end

    it 'joins deep subdomains with a period' do
      expect(SubdomainFu.subdomain_from('awesome.coolguy.localhost')).to eq('awesome.coolguy')
    end

    it 'returns nil for no subdomain' do
      expect(SubdomainFu.subdomain_from('localhost')).to be_nil
    end
  end

  describe '#host_without_subdomain' do
    it 'chop of the subdomain and return the rest' do
      expect(SubdomainFu.host_without_subdomain('localhost:3000')).to eq('localhost:3000')
      expect(SubdomainFu.host_without_subdomain('awesome.localhost:3000')).to eq('localhost:3000')
      expect(SubdomainFu.host_without_subdomain('something.awful.localhost:3000')).to eq('localhost:3000')
    end
  end

  describe '#preferred_mirror?' do
    context 'when preferred_mirror is false' do
      before { SubdomainFu.config.preferred_mirror = false }

      it 'returns true for false' do
        expect(SubdomainFu.preferred_mirror?(false)).to be_truthy
      end
    end
  end

  describe '#rewrite_host_for_subdomains' do
    it 'does not change the same subdomain' do
      expect(SubdomainFu.rewrite_host_for_subdomains('awesome', 'awesome.localhost')).to eq('awesome.localhost')
    end

    it 'does not change an equivalent (mirrored) subdomain' do
      expect(SubdomainFu.rewrite_host_for_subdomains('www', 'localhost')).to eq('localhost')
    end

    it 'changes the subdomain if it\'s different' do
      expect(SubdomainFu.rewrite_host_for_subdomains('cool', 'www.localhost')).to eq('cool.localhost')
    end

    it 'does not change the subdomain for a host the same or smaller than the tld size' do
      SubdomainFu.config.tld_size = 1

      expect(SubdomainFu.rewrite_host_for_subdomains('cool', 'localhost')).to eq('localhost')
    end

    it 'remove the subdomain if passed false when it\'s not a mirror' do
      expect(SubdomainFu.rewrite_host_for_subdomains(false, 'cool.localhost')).to eq('localhost')
    end

    it 'does not remove the subdomain if passed false when it is a mirror' do
      expect(SubdomainFu.rewrite_host_for_subdomains(false, 'www.localhost')).to eq('www.localhost')
    end

    it 'does not remove the subdomain if passed nil when it\'s not a mirror' do
      expect(SubdomainFu.rewrite_host_for_subdomains(nil, 'cool.localhost')).to eq('cool.localhost')
    end

    context 'when preferred_mirror is false' do
      before { SubdomainFu.config.preferred_mirror = false }

      it 'removes the subdomain if passed false when it is a mirror' do
        expect(SubdomainFu.rewrite_host_for_subdomains(false, 'www.localhost')).to eq('localhost')
      end

      it 'does not remove the subdomain if passed nil when it\'s not a mirror' do
        expect(SubdomainFu.rewrite_host_for_subdomains(nil, 'cool.localhost')).to eq('cool.localhost')
      end
    end
  end

  describe '#change_subdomain_of_host' do
    it 'changes it if passed a different one' do
      expect(SubdomainFu.change_subdomain_of_host('awesome', 'cool.localhost')).to eq('awesome.localhost')
    end

    it 'removes it if passed nil' do
      expect(SubdomainFu.change_subdomain_of_host(nil, 'cool.localhost')).to eq('localhost')
    end

    it 'adds it if there isn\'t one' do
      expect(SubdomainFu.change_subdomain_of_host('awesome', 'localhost')).to eq('awesome.localhost')
    end
  end

  describe '#current_subdomain' do
    it 'returns the current subdomain if there is one' do
      request = double('request', subdomains: %w[awesome])

      expect(SubdomainFu.current_subdomain(request)).to eq('awesome')
    end

    it 'returns nil if there\'s no subdomain' do
      request = double('request', subdomains: [])

      expect(SubdomainFu.current_subdomain(request)).to be_nil
    end

    it 'returns nil if the current subdomain is a mirror' do
      request = double('request', subdomains: %w[www])

      expect(SubdomainFu.current_subdomain(request)).to be_nil
    end

    it 'returns current subdomain without a mirror' do
      request = double('request', subdomains: %w[www stuff])

      expect(SubdomainFu.current_subdomain(request)).to eq('stuff')
    end

    it 'returns the whole thing (including a .) if there\'s multiple subdomains' do
      request = double('request', subdomains: %w[awesome rad])

      expect(SubdomainFu.current_subdomain(request)).to eq('awesome.rad')
    end
  end

  describe '#current_domain' do
    it 'returns the current domain if there is one' do
      request = double('request', subdomains: [], domain: 'example.com', port_string: '')

      expect(SubdomainFu.current_domain(request)).to eq('example.com')
    end

    it 'returns empty string if there is no domain' do
      request = double('request', subdomains: [], domain: '', port_string: '')

      expect(SubdomainFu.current_domain(request)).to eq('')
    end
    
    it 'returns an IP address if there is only an IP address' do
      request = double('request', subdomains: [], domain: '127.0.0.1', port_string: '')

      expect(SubdomainFu.current_domain(request)).to eq('127.0.0.1')
    end

    it 'returns the current domain if there is only one level of subdomains' do
      request = double('request', subdomains: %w[www], domain: 'example.com', port_string: '')

      expect(SubdomainFu.current_domain(request)).to eq('example.com')
    end

    it 'returns everything but the first level of subdomain when there are multiple levels of subdomains' do
      request = double('request', subdomains: %w[awesome rad cheese chevy ford], domain: 'example.com', port_string: '')

      expect(SubdomainFu.current_domain(request)).to eq('rad.cheese.chevy.ford.example.com')
    end

    it 'returns the domain with port if port is given' do
      request = double('request', subdomains: %w[awesome rad cheese chevy ford], domain: 'example.com', port_string: ':3000')

      expect(SubdomainFu.current_domain(request)).to eq('rad.cheese.chevy.ford.example.com:3000')
    end
  end

  describe '#same_subdomain?' do
    it { expect(SubdomainFu.same_subdomain?('www', 'www.localhost')).to be_truthy }
    it { expect(SubdomainFu.same_subdomain?('www', 'localhost')).to be_truthy }
    it { expect(SubdomainFu.same_subdomain?('awesome', 'www.localhost')).to be_falsy }
    it { expect(SubdomainFu.same_subdomain?('cool', 'awesome.localhost')).to be_falsy }
    it { expect(SubdomainFu.same_subdomain?(nil, 'www.localhost')).to be_truthy }
    it { expect(SubdomainFu.same_subdomain?('www', 'awesome.localhost')).to be_falsy }
  end

  describe '#same_host?' do
    it { expect(SubdomainFu.same_host?('localhost', 'awesome.localhost')).to be_truthy }
    it { expect(SubdomainFu.same_host?('localhost', 'www.localhost')).to be_truthy }
    it { expect(SubdomainFu.same_host?('localhost', 'localhost')).to be_truthy }
    it { expect(SubdomainFu.same_host?('awesome', 'awesome.localhost')).to be_falsy }
    it { expect(SubdomainFu.same_host?('awesome', 'cool.localhost')).to be_falsy }
    it { expect(SubdomainFu.same_host?('awesome', 'www.localhost')).to be_falsy }
    it { expect(SubdomainFu.same_host?('awesome', 'localhost')).to be_falsy }
    it { expect(SubdomainFu.same_host?(nil, 'www.localhost')).to be_falsy }
  end

  describe '#needs_rewrite?' do
    it { expect(SubdomainFu.needs_rewrite?('www', 'www.localhost')).to be_falsy }
    it { expect(SubdomainFu.needs_rewrite?('www', 'localhost')).to be_falsy }
    it { expect(SubdomainFu.needs_rewrite?('awesome', 'www.localhost')).to be_truthy }
    it { expect(SubdomainFu.needs_rewrite?('cool', 'awesome.localhost')).to be_truthy }
    it { expect(SubdomainFu.needs_rewrite?(nil, 'www.localhost')).to be_falsy }
    it { expect(SubdomainFu.needs_rewrite?(nil, 'awesome.localhost')).to be_falsy }
    it { expect(SubdomainFu.needs_rewrite?(false, 'awesome.localhost')).to be_truthy }
    it { expect(SubdomainFu.needs_rewrite?(false, 'www.localhost')).to be_falsy }
    it { expect(SubdomainFu.needs_rewrite?('www', 'awesome.localhost')).to be_truthy }
    it { expect(SubdomainFu.needs_rewrite?(nil, nil)).to be_falsy }

    context 'when preferred_mirror is false' do
      before { SubdomainFu.config.preferred_mirror = false }

      it { expect(SubdomainFu.needs_rewrite?('www', 'www.localhost')).to be_falsy }
      it { expect(SubdomainFu.needs_rewrite?('www', 'localhost')).to be_falsy }
      it { expect(SubdomainFu.needs_rewrite?('awesome', 'www.localhost')).to be_truthy }
      it { expect(SubdomainFu.needs_rewrite?('cool', 'awesome.localhost')).to be_truthy }
      it { expect(SubdomainFu.needs_rewrite?(nil, 'www.localhost')).to be_falsy }
      it { expect(SubdomainFu.needs_rewrite?(nil, 'awesome.localhost')).to be_falsy }
      it { expect(SubdomainFu.needs_rewrite?(false, 'awesome.localhost')).to be_truthy }
      #Only one different from default set of tests
      it { expect(SubdomainFu.needs_rewrite?(false, 'www.localhost')).to be_truthy }
      it { expect(SubdomainFu.needs_rewrite?('www', 'awesome.localhost')).to be_truthy }
    end

    context 'when preferred_mirror is string' do
      before { SubdomainFu.config.preferred_mirror = 'www' }

      it { expect(SubdomainFu.needs_rewrite?('www', 'awesome.localhost')).to be_truthy }
      it { expect(SubdomainFu.needs_rewrite?('awesome', 'www.localhost')).to be_truthy }
      # Following is different from default set of tests
      it { expect(SubdomainFu.needs_rewrite?('www', 'localhost')).to be_truthy }
      it { expect(SubdomainFu.needs_rewrite?('cool', 'awesome.localhost')).to be_truthy }
      it { expect(SubdomainFu.needs_rewrite?(nil, 'www.localhost')).to be_falsy }
      it { expect(SubdomainFu.needs_rewrite?(nil, 'awesome.localhost')).to be_falsy }
      it { expect(SubdomainFu.needs_rewrite?(false, 'awesome.localhost')).to be_truthy }
      it { expect(SubdomainFu.needs_rewrite?(false, 'www.localhost')).to be_falsy }
      it { expect(SubdomainFu.needs_rewrite?('www', 'awesome.localhost')).to be_truthy }
    end
  end
end
