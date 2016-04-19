require 'serverspec'
# Required by serverspec
set :backend, :exec

describe service('unbound') do
  it { should be_enabled }
  it { should be_running }
end

describe port(53) do
  it { should be_listening }
end

# Resolution for this domain is forwarded to Google public resolvers
describe host('google-public-dns-a.google.com.') do
  it { should be_resolvable.by('dns') }
end

# Resolution for this domain is forwarded to OpenDNS public resolvers
describe host('resolver1.opendns.com.') do
  it { should be_resolvable.by('dns') }
end

# This might be a good test to verify connectivity with Chef Server
describe host('chef.io.') do
  it { should be_resolvable.by('dns') }
end

# RubyGems is required for Test Kitchen verify, and sometimes Chef converge
describe host('rubygems.org') do
  it { should be_resolvable.by('dns') }
end

# This is a general test that is just expected to always work
describe host('www.iana.org.') do
  it { should be_resolvable.by('dns') }
end
