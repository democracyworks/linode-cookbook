include_recipe "linode::static_net"
include_recipe "linode::dns"
include_recipe "linode::apt_get_upgrade"

execute "restart networking" do
  command "/etc/init.d/networking restart"
  action :nothing
end
