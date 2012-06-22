include_recipe "apt"

execute "apt-get upgrade on first boot" do
  notifies :run, "execute[apt-get upgrade]", :immediately
  notifies :run, "execute[restart networking]", :immediately
  command "touch /var/local/apt-get-upgraded"
  creates "/var/local/apt-get-upgraded"
end
