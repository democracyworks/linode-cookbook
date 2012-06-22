include_recipe "linode::api_gem"

class Chef::Recipe
  include LinodeApi # :linode_api method
end

# TODO: Move all this into a Linode Ohai plugin

# Currently we have to iterate through all the Linodes and hunt for a clue
# that we've found the one we're running on. Dumb, Linode.
linodes = linode_api.linode.list
linode_ips = nil
node_addrs = node[:network][:interfaces][:eth0][:addresses].to_hash
if node[:network][:interfaces].has_key?('eth0:0')
  node_addrs.merge! node[:network][:interfaces]['eth0:0'][:addresses].to_hash
end

# try to match the node name to the label first
this_linode = linodes.detect do |l|
  l.label == node.name
end

if this_linode
  linode_ips = linode_api.linode.ip.list(:LinodeId => this_linode.linodeid)
else
  # now try to find the IPv4 address already on eth0
  my_eth0_ip = node_addrs.keys.detect { |ip|
    node_addrs[ip][:family] == 'inet'
  }
  linodes.each do |l|
    ips = linode_api.linode.ip.list(:LinodeId => l.linodeid)
    if ips.any? { |ip| ip.ipaddress == my_eth0_ip }
      linode_ips = ips
    end
    break if linode_ips
  end
end

raise "Couldn't find my Linode IPs via the API" unless linode_ips

node.set[:private_ipv4] = linode_ips.detect { |ip| ip.ispublic == 0 }.ipaddress
node.set[:public_ipv4]  = linode_ips.detect { |ip| ip.ispublic == 1 }.ipaddress
node.set[:public_ipv6]  = node_addrs.keys.detect { |ip|
                            node_addrs[ip][:family] == 'inet6' &&
                            node_addrs[ip][:scope].downcase == 'global'
                          }

execute "set_hostname" do
  command "hostname #{node.name}"
  only_if { `hostname`.chomp != node.name }
end

file "/etc/hostname" do
  content node.name
  owner 'root'
  group 'root'
  mode "0644"
end

template "/etc/hosts" do
  source "hosts.erb"
  owner 'root'
  group 'root'
  mode "0644"
  variables :public_ip => node[:public_ipv4],
            :domain    => node[:set_domain],
            :hostname  => node.name
end

template "/etc/resolv.conf" do
  source "resolv.conf.erb"
  owner 'root'
  group 'root'
  mode "0644"
  variables :domain => node[:set_domain],
            :search_domains => %W[ int.#{node[:set_domain]} #{node[:set_domain]}
                                   members.linode.com ],
            :nameservers    => %w[ 97.107.133.4 207.192.69.4 207.192.69.5 ]
end

service "networking" do
  action :nothing
end

template "/etc/network/interfaces" do
  source "interfaces.erb"
  owner 'root'
  group 'root'
  mode "0644"
  variables :ips => (linode_ips.sort do |a,b|
    private_regex = /^192\.168/
    if private_regex =~ a.ipaddress && private_regex !~ b.ipaddress
      1
    elsif /^192\.168/ =~ b.ipaddress && private_regex !~ a.ipaddress
      -1
    else
      0
    end
  end)
  notifies :restart, "service[networking]"
end
