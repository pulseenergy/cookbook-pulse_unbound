<!--
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
-->
# Pulse Unbound Cookbook

[![CodeClimate](https://codeclimate.com/github/pulseenergy/cookbook-pulse_unbound/badges/gpa.svg)](https://codeclimate.com/github/pulseenergy/cookbook-pulse_unbound) [![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

This cookbook installs [Unbound](https://www.nlnetlabs.nl/projects/unbound/), a validating, recursive, and caching DNS server.

The default configuration provides a simple caching DNS resolver that respects TTL values provided by authoritative nameservers. Advanced configuration enables routing of DNS requests through the use of stub zones and forward zones.

## Basic Usage
Modify the run_list of any role or node to include the default recipe.

```
run_list "recipe[pulse_unbound::default]"
```

Or use include_recipe in one of your own cookbooks.

```
include_recipe 'pulse_unbound::default'
```

## Security
Unbound is a DNS server that listens on udp/53 and tcp/53. In order to ensure that your servers are not used as part of a [DNS Amplification Attack](https://www.us-cert.gov/ncas/alerts/TA13-088A), you must ensure that port 53 (UDP and TCP) on your servers is not reachable from the public internet.

## Advanced Usage
WARNING: Installing Unbound changes your `/etc/resolv.conf` configuration. Once Unbound is installed, all DNS queries will be served by Unbound. If Unbound is configured incorrectly, chef-client will be unable to converge. It is a very good idea to test your configuration on a small number of servers first.

### Stub Zones
Stub zones are appropriate when the other nameserver is an authoritative nameserver, so you have to perform recursive processing yourself. Stub zones enable you to configure [split-horizon DNS](https://en.wikipedia.org/wiki/Split-horizon_DNS).

You might want to use a stub zone if you need to resolve names that don't exist in the global namespace of the internet. For example, if you are using [Consul](https://www.consul.io/) for service discovery then you could use Unbound to resolve DNS requests to the Consul agent.

Use override attributes to change the Unbound configuration.

```
override['pulse_unbound']['stub_zone']['consul'] = {
  'stub_addr' => ['172.31.0.2@8600']
}
```

Need an authoritative DNS server to handle your stub zone? Unbound pairs well with [NSD](http://www.nlnetlabs.nl/projects/nsd/), also from NLnet labs.

<!-- I normally prefer putting override statements into recipes, but I'm concerned that people will accidentally include the pulse_unbound::default recipe before including the recipe that overrides the attributes, thus resulting in the override being ignored. So it's simpler to use the attribute file syntax. -->

### Forward Zones
Forward zones let you forward queries to some other nameserver. Forward zones are appropriate when the other nameserver is a recursive (caching) resolver that will perform recursion. <!-- For example, if your ISP provides a DNS server then it is likely a recursive resolver. Or if you are on AWS EC2 Classic (not VPC) then `172.31.0.2` is your DNS resolver. -->

Here's how to forward all DNS queries from Unbound to Cisco [OpenDNS](https://www.opendns.com/).

```
override['pulse_unbound']['forward_zone']['.'] = {
  'forward_addr' => ['208.67.222.222', '208.67.220.220']
}
```

### Interfaces and Access Controls

```
node.override['pulse_unbound']['interface'] = {
  '127.0.0.1' => true,
  '172.17.0.1' => true,
}
```

Non-localhost interfaces must be supported by additional access control rules.

```
node.override['pulse_unbound']['access_control'] = {
  '127.0.0.1/8' => 'allow',
  '172.16.0.1/16' => 'allow',
}
```

<!-- I feel a bit nervous about including an example that affects the root domain, because any slight misconfiguration can cripple the system. -->

## License and Authors

Author: Nic Waller (<nicholas.waller@enernoc.com>)
