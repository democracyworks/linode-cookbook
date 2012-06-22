# Created according to these API docs:
# http://www.linode.com/api/dns/domain%2Eresource%2Ecreate

actions :create#, :delete

attribute :name, :kind_of => String, :name_attribute => true

attribute :domain, :kind_of => String, :required => true

attribute :type, :kind_of => String,
          :equal_to => %w[ NS MX A AAAA CNAME TXT SRV ], :default => 'A'

# TODO: Figure out the validation for this
attribute :target, :kind_of => String

attribute :ttl, :kind_of => Integer

# TODO: Figure out the validation for this
attribute :priority, :kind_of => Integer

# TODO: Figure out the validation for this
attribute :weight, :kind_of => Integer

attribute :port, :kind_of => Integer, :equal_to => [1..65_535]

# TODO: Figure out the validation for this (only needed for SRV records)
attribute :protocol, :kind_of => String

# make :create the default action
def initialize(*args)
  super
  @action = :create
  @provider = Chef::Provider::LinodeDomainApi
end
