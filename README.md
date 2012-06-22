= Linode Cookbook

A collection of useful recipes for configuring Linodes. Currently there are just
2: one for setting up static networking and one for adding DNS entries. OK I
lied, there's a third one that installs the linode gem, but that's more of a
dependancy of the other recipes.

You'll need to put your Linode API key into an encrypted data bag called
"passwords" and an item within it called "linode". It should look like this
(when decrypted):

    {
      "id": "linode",
      "api_key": "your-api-key-here"
    }

== linode::static_net

This recipe will detect the configured IPv4 addresses and setup static
networking for them as [described here](http://library.linode.com/networking/configuring-static-ip-interfaces).

== linode::dns

This recipe will add entries to the Linode DNS system for your Linode. It will
create the following entries:

* node.name + '.' + node[:set_domain] => node[:public_ipv4]
* node.name + '.int.' + node[:set_domain] => node[:private_ipv4]
* node.name + '.' + node[:set_domain] => node[:public_ipv6]

It requires the configuration performed in static_net, so it runs that first.

== linode::api_gem

This recipe installs the linode gem for API access. The cookbook uses this gem
extensively.

== linode::default

The default recipe runs both static_net & dns.
