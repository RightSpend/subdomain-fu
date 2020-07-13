require 'action_dispatch/routing/route_set'

module UrlWithSubdomains
  def url_for(options, *args)
    if SubdomainFu.needs_rewrite?(options[:subdomain], (options[:host] || (@request && @request.host_with_port))) || options[:only_path] == false
      options[:only_path] = false if SubdomainFu.override_only_path?
      options[:host] = SubdomainFu.rewrite_host_for_subdomains(options.delete(:subdomain), options[:host] || (@request && @request.host_with_port))
    else
      options.delete(:subdomain)
    end

    super(options, *args)
  end
end

ActionDispatch::Routing::RouteSet.send(:prepend, UrlWithSubdomains)
