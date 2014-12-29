#
# Cookbook Name:: hostname
# Recipe:: default
#
# Copyright 2013, News UK
#
# All rights reserved - Do Not Redistribute
#
if node['os'] == 'linux'
  default['sethostname']['name'] = node['base']['Hostname']
elsif node['os'] == 'windows'
  if node.attribute?('ad_rodc')
    default['sethostname']['name'] = node['ad_rodc']['hostname']
  elsif node.attribute?('dfs')
    default['sethostname']['name'] = node['dfs']['hostname']
  else node.attribute?('base')
    default['sethostname']['name'] = node['base']['Hostname']
  end
end