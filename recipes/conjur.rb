#
# Cookbook:: conjur_configuration
# Recipe:: conjur
#
# Copyright:: 2017, Darren Khan , All Rights Reserved.

images = ['cyberark/conjur', 'postgres', 'conjurinc/cli5']

images.each do |image|
  docker_image "Pulling image #{image}" do
    repo "#{image}"
    action :pull_if_missing
  end
end

CONJUR_NETWORK = 'conjur'
CONJUR_NAME = 'conjur-master'
ACCOUNT_NAME = 'ConUser'

ruby_block 'Generate_data_Key' do
  block do
    node.default['conjur']['data_key'] = `docker container run --rm cyberark/conjur data-key generate`
  end
  notifies :run, 'docker_container[conjur]', :delayed
  action :run
end

docker_network "#{CONJUR_NETWORK}" do
  action :create
end

docker_container 'database' do
  container_name 'database'
  network_mode "#{CONJUR_NETWORK}"
  repo 'postgres'
  action :run
end

docker_container 'conjur' do
  container_name "#{CONJUR_NAME}"
  network_mode "#{CONJUR_NETWORK}"
  repo 'cyberark/conjur'
  command 'server'
  port '3000:3000'
  env lazy { ['DATABASE_URL=postgres://postgres@database/postgres', "CONJUR_DATA_KEY=#{node['conjur']['data_key']}"] }
  notifies :run, 'ruby_block[Generate_API_Key]', :immediate
  action :nothing
end

# ACCOUNT_API = `docker exec conjur-master conjurctl account create #{ACCOUNT_NAME} | awk '/admin:/{print $5}'`
ruby_block 'Generate_API_Key' do
  block do
    node.default['conjur']['account_api'] = `docker exec conjur-master conjurctl account create #{ACCOUNT_NAME}`
  end
  notifies :run, 'docker_container[cli]', :delayed
  action :nothing
end

docker_container 'cli' do
  container_name 'conjur-cli'
  network_mode "#{CONJUR_NETWORK}"
  repo 'conjurinc/cli5'
  command 'infinity'
  entrypoint 'sleep'
  env lazy { ["CONJUR_APPLIANCE_URL=http://#{CONJUR_NAME}", "CONJUR_ACCOUNT=#{ACCOUNT_NAME}", "CONJUR_AUTHN_API_KEY=#{node['conjur']['account_api']}", 'CONJUR_AUTHN_LOGIN=admin'] }
  action :nothing
end
