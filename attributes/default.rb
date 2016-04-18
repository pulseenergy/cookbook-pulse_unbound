#
# Cookbook Name: pulse_unbound
# Attributes: default
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

# stub: send query to other nameserver. The other nameserver is
# authoritative, so you have to perform recursive processing yourself.
default['pulse_unbound']['stub_zone'] = Hash.new

# forward: send query to other nameserver.  The other nameserver is a
# recursive (caching) server.  So it performs recursion for you.
default['pulse_unbound']['forward_zone'] = Hash.new

# If no interfaces are specified, localhost (IPv4 and IPv6) will be used.
default['pulse_unbound']['interface'] = Hash.new

# If no netblocks are specified, then Unbound will default to allowing only localhost and denying all other networks.
default['pulse_unbound']['access_control'] = Hash.new

# Unbound will respect the TTL value provided by nameservers, up to cache_max_ttl
# If you want to disable caching for private zones, change your SOA record instead of changing this value.
default['pulse_unbound']['cache_max_ttl'] = 86400

# Set this to false if you're using localhost in any of your stub or forward zones.
default['pulse_unbound']['do_not_query_localhost'] = true
