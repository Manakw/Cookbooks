hostname Cookbook
============
Sets the hostname on Red Hat, Debian, SUSE and Windows like systems.




Supported OS
------------
1. Red Hat Enterprise 6+ distributions within this platform family.
2. Ubuntu Linux 11.x+, 12.x+, and 13.x+ distributions.
3. Suse 11.2 service pack 2 and service pack 3 distributions.
4. Amazon Linux 2013.
5. Windows server 2008, 2008R2, 2012



Attributes
----------
* `setHostname['name']`
    - The hostname to be set on the machine.
    - Default value can be mentioned, or can be passed at runtime by `node.json` file.


Recipes
-------
### default
The default recipe includes the code which is to be run on the node. It contains different code blocks for linux systems and windows systems. For linux platform systems, the recipe has been divided into blocks for Debian/ubuntu like systems, Red-Hat platform family distributions, Amazon Linux systems and Suse distribution systems. 

A restart is required for the setting to take place. Also, the code blocks are escaped if the not_if condition, which checks if the current hostname is same as the attribute, returns true.

#### Linux platform machines
- SUSE: The code block to update the hostname first update the `/etc/sysconfig/network/dhcp` file, to allow `/etc/hostname` file to able to override hostname. Then update the `/etc/hostname` file itself.
- Disable dns entries update from dhcp and make them static by making entry in /etc/sysconfig/network/config with option NETCONFIG_DNS_POLICY

```ruby
when "suse"
		bash 'hostname configuration-suse' do
		flags "-xv"
		code <<-EOH
		sed -i "s/DHCLIENT_SET_HOSTNAME=.*/DHCLIENT_SET_HOSTNAME=\"no\"/" /etc/sysconfig/network/dhcp    
		sed -i "s/DHCLIENT_HOSTNAME_OPTION=.*/DHCLIENT_HOSTNAME_OPTION=\"\"/" /etc/sysconfig/network/dhcp
		sed -i "s/NETCONFIG_DNS_POLICY=.*/NETCONFIG_DNS_POLICY=\"\"/" /etc/sysconfig/network/config
		echo "#{node['sethostname']['name']}" > /etc/HOSTNAME
			echo "-----Hostname has been changed to #{node['setHostname']['name']}. The new hostname will be applicable once the machine is restarted.-----"
		EOH
		not_if "hostname | grep -ow #{node['sethostname']['name']}"
		action :run
		end
```


- Debian/Ubuntu: The code block updates the `etc/hostname` file with the corresponding attribute through terminal.


```ruby
when "ubuntu","debian"
		bash 'hostname configuration-ubuntu' do
		flags "-xv"
		code <<-EOH
			echo "#{node['setHostname']['name']}" > /etc/hostname
			echo "-----Hostname has been changed to #{node['setHostname']['name']}. The new hostname will be applicable once the machine is restarted.-----"
		EOH
		not_if {node['hostname'] == node['setHostname']['name']}
		action :run
		end
```


- Red-Hat Platform Family and Amazon Linux: The code block updates the `/etc/sysconfig/network` fileand sets the `HOSTNAME` parameter with the attribute value. Using DHCP_HOSTNAME option for static hostname without geting update from DHCP server. There is one more parameter which will keep the dhcp client entries (/etc/resolve.conf)static without having any update from dhcp server by using PEERDNS option.
 Template resource is used to create/change the respective configuration file.

```ruby

when "redhat","centos","amazon"

	bash "hostname configuration" do
	flags "-x"
	flags "-v"
	code <<-EOH
		sed -i 's/HOSTNAME=.*/HOSTNAME=#{node['sethostname']['name']}/' /etc/sysconfig/network
		echo "DHCP_HOSTNAME=#{node['sethostname']['name']}" >> /etc/sysconfig/network-scripts/ifcfg-eth0
		echo "PEERDNS=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0

		echo "-----Hostname has been changed to #{node['setHostname']['name']}. The new hostname will be applicable once the machine is restarted.-----"
	EOH
	not_if {node['hostname'] == node['sethostname']['name']}
	end
```



#### Windows

- A powershell script block is ran to set the hostname. The command `RENAME-HOSTNAME` followed by the attribute value is executed.


```ruby
when "windows"
		powershell_script "hostname configuration" do
		  code <<-EOH
			Rename-Computer   #{node['setHostname']['name']}
			echo "-----Hostname has been changed to #{node['setHostname']['name']}. The new hostname will be applicable once the machine is restarted.-----"
		  EOH
		  not_if {node['hostname'] == "#{node['setHostname']['name']}".upcase}      
		end
```


Usage
-----
Set the attribute value in the `attributes/default.rb` file and put `recipe[setHostname]` in the run list to ensure hostname is configured correctly for your machine within your Chef run. See example for details.

#### Example
```json
{
  "name":"my_node",
  "run_list": [
    "recipe[setHostname]"
  ]
}
```
Also you can setup the ntp attributes in a role and apply to all the nodes. For example in a base.rb role applied to all the nodes:

#### Example

```ruby
name 'base'
description 'Role applied to all systems'
default_attributes(
  'hostname' => {
    'setHostname' => ['your-hostname-here']
  }
)
```

Make sure to restart the system after a successful Chef run, so that the changes to the system locales are applied.


License & Authors
-----------------
- Author:: Suraj Savita
- Author:: Himanshu Tyagi
- Author:: Sandeep Sharma



```text
Copyright:: News UK
```


