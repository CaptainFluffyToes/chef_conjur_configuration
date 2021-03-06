#
# Cookbook:: conjur_configuration
# Recipe:: conjur
#
# Copyright:: 2017, Darren Khan , All Rights Reserved.

conjur_network = 'pipeline'
conjur_name = 'conjur-master'
account_name = 'solsys'

images = ['cyberark/conjur', 'postgres', 'conjurinc/cli5']

images.each do |image|
  docker_image "Pulling image #{image}" do
    repo "#{image}"
    action :pull_if_missing
  end
end

docker_network "#{conjur_network}" do
  action :create
end

ruby_block 'Generate_data_Key' do
  block do
    node.default['conjur']['data_key'] = `docker container run --rm cyberark/conjur data-key generate`
  end
  notifies :run, 'docker_container[database]', :immediate
  action :run
end

docker_container 'database' do
  container_name 'database'
  network_mode "#{conjur_network}"
  repo 'postgres'
  notifies :run, 'docker_container[conjur]', :immediate
  action :nothing
end

docker_container 'conjur' do
  container_name "#{conjur_name}"
  network_mode "#{conjur_network}"
  repo 'cyberark/conjur'
  command 'server'
  port ['3000:3000', '443:443', '80:80']
  env lazy { ['DATABASE_URL=postgres://postgres@database/postgres', "CONJUR_DATA_KEY=#{node['conjur']['data_key']}"] }
  notifies :run, 'ruby_block[sleep]', :immediate
  action :nothing
end

ruby_block 'sleep' do
  block do
    sleep 10
  end
  notifies :run, 'ruby_block[Generate_API_Key]', :immediate
  action :nothing
end

ruby_block 'Generate_API_Key' do
  block do
    node.default['conjur']['account_api'] = `docker exec #{conjur_name} conjurctl account create #{account_name} | awk '/admin:/{print $5}' | tr -d '\r\n'`
  end
  notifies :run, 'ruby_block[sleep_key]', :immediate
  action :nothing
end

ruby_block 'sleep_key' do
  block do
    sleep 10
  end
  notifies :run, 'docker_container[cli]', :immediate
  action :nothing
end

docker_container 'cli' do
  container_name 'conjur-cli'
  network_mode "#{conjur_network}"
  repo 'conjurinc/cli5'
  command 'infinity'
  entrypoint 'sleep'
  env lazy { ["CONJUR_APPLIANCE_URL=http://#{conjur_name}", "CONJUR_ACCOUNT=#{account_name}", "CONJUR_AUTHN_API_KEY=#{node['conjur']['account_api']}", 'CONJUR_AUTHN_LOGIN=admin'] }
  notifies :run, 'ruby_block[setup_cli]', :immediate
  action :nothing
end

ruby_block 'setup_cli' do
  block do
    `docker exec conjur-cli rm -f /root/.conjurrc`
    `docker exec conjur-cli conjur init -u #{conjur_name} -a #{account_name}`
    `docker exec conjur-cli conjur authn login -u admin`
  end
  action :nothing
end
