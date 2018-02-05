name 'conjur_configuration'
maintainer 'Darren Khan'
maintainer_email 'djkhan85@gmail.com'
license 'GPL-3.0'
description 'Installs/Configures conjur_configuration'
long_description 'Installs/Configures conjur_configuration'
version '0.1.5'
chef_version '>= 12.1' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/CaptainFullyToes/conjur_configuration/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/CaptainFullyToes/conjur_configuration'

# Changelog
# [10/16/2017] - 0.1.1 - Added dependencies and .chef folder for berks uploads.  
# [10/16/2017] - 0.1.2 - added images and containers for docker install.
# [10/18/2017] - 0.1.3 - created loops for multi item resources.
# [10/30/2017] - 0.1.4 - Added new command for generating the datakey
# [02/05/2018] - 0.1.5 - Trimmed new line after the creation of the API key.  Updated organization name. 

depends 'docker_configuration'
