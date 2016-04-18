#
# Cookbook Name: pulse_unbound
# Recipe:: default
#
# Copyright 2016 EnerNOC, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Installing the Unbound package on Ubuntu also causes the service to start immediately.
# So let's make sure that appropriate configuration is in place before we install the package.
user 'unbound'
group 'unbound'
directory '/etc/unbound' do
  owner 'unbound'
  group 'unbound'
  mode '0755'
  action :create
end

config = {
  'server' => {
    'cache-max-ttl' => node['pulse_unbound']['cache_max_ttl'],
    'do-ip6' => false,
    'username' => 'unbound',
    'logfile' => '/var/log/unbound',
    'use-syslog' => false,
    'module-config' => 'iterator', # This disables DNSSEC. DNSSEC does not work with forwarding.
    'do-not-query-localhost' => node['pulse_unbound']['do_not_query_localhost'],
    'private-domain' => [],
    'local-zone' => [],
    'local-data' => [],
    'interface' => node['pulse_unbound']['interface'].select { |interface, enable| enable }.keys,
    'access-control' => node['pulse_unbound']['access_control'].map { |x,y| "\"#{x}\" \"#{y}\"" },
  },
  'stub-zone' => [],
  'forward-zone' => [],
}

node[cookbook_name]['stub_zone'].each { |zone, details|
  config['stub-zone'].push({
    'name' => zone,
    'stub-host' => details['stub_host'] || [],
    'stub-addr' => details['stub_addr'] || [],
    'stub-prime' => details['stub_prime'] || false,
    #'stub-first' => details['stub_first'] || false, # Not supported by NSD 3.x
  })
}

node[cookbook_name]['forward_zone'].each { |zone, details|
  # TODO: add sanity check to help people avoid breaking root DNS resolution if forward-addr is omitted
  config['forward-zone'].push({
    'name' => zone,
    'forward-host' => details['forward_host'] || [],
    'forward-addr' => details['forward_addr'] || [],
    #'forward-first' => details['forward_first'] || false, # Not supported by NSD 3.x
  })
}

# Writing one big config file is the easiest way to ensure that the configuration
# always represents the latest attribute values, even when things are removed.
# That's why I'm choosing not to use the "conf.d" model here.
Chef::Resource::File.send(:include, UnboundHelper) # I don't know how else to make the Library helper callable - NW
file '/etc/unbound/unbound.conf' do
  action :create
  mode '0444'
  owner 'root'
  group 'root'
  content render_unbound_configfile(config)
  notifies :reload, 'service[unbound]'
end

# On Ubuntu, installing the unbound package immediately alters /etc/resolv.conf.
apt_package 'unbound' do
  # Tell apt-get to not overwrite our config files, but still add default config files that we haven't created ourself
  options '-o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" '
end

file '/var/log/unbound' do
  mode '0644'
  owner 'unbound'
  group 'unbound'
  action :create_if_missing
end

# TODO: call unbound-checkconf before restarting the service

service 'unbound' do
  action [:enable, :start]
  supports :reload => true
  subscribes :reload, 'file[/etc/unbound/unbound.conf]', :delayed
end
