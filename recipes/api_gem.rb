# Install the linode gem so we can use it in this recipe
# Follows these instructions:http://www.opscode.com/blog/2009/06/01/cool-chef-tricks-install-and-use-rubygems-in-a-chef-run/

begin # Chef 0.10.10
  chef_gem 'linode'
rescue # Chef < 0.10.10
  linode_gem = gem_package "linode" do
    action :nothing
  end
  linode_gem.run_action(:install)
  Gem.clear_paths
end

require 'linode'
