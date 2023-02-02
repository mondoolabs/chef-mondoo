#
# Cookbook:: mondoo
# Recipe:: default
#
# Copyright:: 2022, Mondoo, Inc, All Rights Reserved.

require 'yaml'

Chef::Log.info("Detected platform: #{node['platform_family']}")

# install package repository
case node['platform_family']
when 'debian'
  # configure ubuntu, debian
  include_recipe 'mondoo::deb'
when 'rhel', 'fedora', 'amazon', 'suse'
  # configure rhel-family
  include_recipe 'mondoo::rpm'
end

directory '/etc/opt/mondoo/' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# register the mondoo client
execute 'cnspec_login' do
  command "cnspec login --config /etc/opt/mondoo/mondoo.yml --token #{node['mondoo']['registration_token']}"
  user 'root'
  creates '/etc/opt/mondoo/mondoo.yml'
end

# enable the service
service 'cnspec.service' do
  action [:start, :enable]
end

# disable deprecated mondoo service
service 'mondoo.service' do
  action [:stop, :disable]
  ignore_failure true
end