#
# Cookbook Name:: hostname
# Recipe:: default
#
# Copyright 2013, News UK
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "suse"
	bash 'hostname configuration' do
	flags "-xv"
	code <<-EOH
		LOWECASEHOST="`hostname |tr  '[:upper:]'  '[:lower:]'`"

    
		sed -i "s/DHCLIENT_SET_HOSTNAME=.*/DHCLIENT_SET_HOSTNAME=\"no\"/" /etc/sysconfig/network/dhcp    
		sed -i "s/DHCLIENT_HOSTNAME_OPTION=.*/DHCLIENT_HOSTNAME_OPTION=\"\"/" /etc/sysconfig/network/dhcp

			    if [ "`$LOWECASEHOST |grep ^p |wc -l`" -eq "1" ];then
            		sed -i "s/NETCONFIG_DNS_POLICY=.*/NETCONFIG_DNS_POLICY=\"\"/" /etc/sysconfig/network/config
        		elsif [ "`$LOWECASEHOST |grep ^u |wc -l`" -eq "1" ]
            		echo "No change in DHCP client policies"
        		else 
            		echo "No change in DHCP client policies"
        		fi


		echo "#{node['sethostname']['name']}" > /etc/HOSTNAME
		sed -i "s/^ - set_hostname/# - set_hostname/" /etc/cloud/cloud.cfg
		sed -i "s/^ - update_hostname/# - update_hostname/" /etc/cloud/cloud.cfg

		init 6

	EOH
	not_if "hostname | grep -ow #{node['sethostname']['name']}"
	action :run
	end


when "ubuntu","debian"
	bash 'hostname configuration' do
	flags "-xv"
	code <<-EOH
		LOWECASEHOST="`hostname |tr  '[:upper:]'  '[:lower:]'`"
		echo "#{node['sethostname']['name']}" > /etc/hostname

				if [ "`$LOWECASEHOST |grep ^p |wc -l`" -eq "1" ];then
					resolvconf --disable-updates
        		elsif [ "`$LOWECASEHOST |grep ^u |wc -l`" -eq "1" ]
            		echo "No change in DHCP client policies"
        		else 
            		echo "No change in DHCP client policies"
        		fi
		
		init 6
	EOH
	not_if {node['hostname'] == node['sethostname']['name']}
	action :run
	end


when "redhat","centos","amazon"

	bash "hostname configuration" do
	flags "-x"
	flags "-v"
	code <<-EOH

		LOWECASEHOST="`hostname |tr  '[:upper:]'  '[:lower:]'`"	

		sed -i 's/HOSTNAME=.*/HOSTNAME=#{node['sethostname']['name']}/' /etc/sysconfig/network
		echo "DHCP_HOSTNAME=#{node['sethostname']['name']}" >> /etc/sysconfig/network-scripts/ifcfg-eth0

				if [ "`$LOWECASEHOST |grep ^p |wc -l`" -eq "1" ];then
					echo "PEERDNS=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        		elsif [ "`$LOWECASEHOST |grep ^u |wc -l`" -eq "1" ]
            		echo "No change in DHCP client policies"
        		else 
            		echo "No change in DHCP client policies"
        		fi
		sed -i "s/^ - set_hostname/# - set_hostname/" /etc/cloud/cloud.cfg
		sed -i "s/^ - update_hostname/# - update_hostname/" /etc/cloud/cloud.cfg
		init 6
	EOH
	not_if {node['hostname'] == node['sethostname']['name']}
	end

when "windows"
    
    powershell_script "hostname configuration" do
      code <<-EOH
        Rename-Computer   #{node['sethostname']['name']}
        Restart-Computer
      EOH
      not_if {node['hostname'] == "#{node['sethostname']['name']}".upcase}
    end


end