include_recipe "linode::static_net"
include_recipe "linode::dns"
include_recipe "apt"

execute "apt-get upgrade on first boot" do
  notifies :run, "execute[apt-get upgrade]", :immediately
  notifies :run, "execute[restart networking]", :immediately
  command "touch /var/local/apt-get-upgraded"
  creates "/var/local/apt-get-upgraded"
end

execute "restart networking" do
  command "/etc/init.d/networking restart"
  action :nothing
end
