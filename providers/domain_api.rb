include LinodeApi

action :create do
  domain = new_resource.domain
  domain_id = lookup_domain_id(domain)
  params = {
    :DomainId => domain_id,
    :Type     => new_resource.type,
  }
  params[:Name]     = new_resource.name if new_resource.name
  params[:Target]   = new_resource.target if new_resource.target
  params[:Priority] = new_resource.priority if new_resource.priority
  params[:Weight]   = new_resource.weight if new_resource.weight
  params[:Port]     = new_resource.port if new_resource.port
  params[:Protocol] = new_resource.protocol if new_resource.protocol
  params[:TTL_sec]  = new_resource.ttl if new_resource.ttl

  unless dns_record_exists?(params)
    Chef::Log.info "Creating Linode DNS record for #{params.inspect}"
    new_record = linode_api.domain.resource.create(params)

    # TODO: Figure out how to persist this
    # new_resource.linode_id = new_record.resourceid

    # TODO: Make sure the API call succeeded first
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info "Not creating Linode DNS record for #{params.inspect} because it already exists"
  end
end

# I think I need to learn more about load_current_resource before this will work
# action :delete do
#   domain = new_resource.domain
#   domain_id = lookup_domain_id(domain)
#   resource_id = current_resource.resourceid
#
#   Chef::Log.info "Deleting Linode DNS record for #{params.inspect}"
#   linode_api.domain.resource.delete(:DomainId => domain_id,
#                                   :ResourceId => resource_id)
#
#   # TODO: Make sure the API call succeeded first
#   new_resource.updated_by_last_action(true)
# end
