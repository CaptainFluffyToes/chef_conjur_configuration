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

docker_container 'database' do
	container_name 'database'
	repo 'postgres'
	action :run
end

if node[platform_family] == 'debian'
	execute 'Generate random file' do
		command 'DATA_KEY = $(docker container run --rm cyberark/conjur conjur data-key generate > data_key)'
		action :run
	end
end

docker_container 'conjur' do
	container_name 'conjur-master'
	repo 'cyberark/conjur'
	command 'server'
	env ['DATABASE_URL=postgres://postgres@database/postgres', 'CONJUR_DATA_KEY=$DATA_KEY']
	action :run
end