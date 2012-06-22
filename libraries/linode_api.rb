begin
  require 'linode'
rescue LoadError
  Chef::Log.info "Missing gem 'linode'"
end

module LinodeApi
  def linode_api
    @linode_api ||= (
      api_key = Chef::EncryptedDataBagItem.load("passwords", "linode")['api_key']
      Linode.new(:api_key => api_key)
    )
  end

  def get_domain(domain)
    linode_api.domain.list.each do |d|
      return d if d.domain == domain
    end
    nil
  end

  def lookup_domain_id(domain)
    get_domain(domain).domainid
  end

  def dns_record_exists?(params)
    linode_api.domain.resource.list(:DomainId => params[:DomainId]).any? do |r|
      Chef::Log.debug "Checking for pre-existing DNS record #{params.inspect}"
      params.keys.all? do |k|
        Chef::Log.debug "Matching #{r.send(k.to_s.downcase)} against #{params[k]}"
        r.send(k.to_s.downcase) == params[k]
      end
    end
  end
end
