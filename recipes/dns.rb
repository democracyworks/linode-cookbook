include_recipe "linode::static_net"

linode_dns_record "#{node.name}" do
  domain node[:set_domain]
  target node[:public_ipv4]
end

linode_dns_record "#{node.name}.int" do
  domain node[:set_domain]
  target node[:private_ipv4]
end

linode_dns_record "#{node.name}" do
  type 'AAAA' # IPv6
  domain node[:set_domain]
  target node[:public_ipv6]
end
