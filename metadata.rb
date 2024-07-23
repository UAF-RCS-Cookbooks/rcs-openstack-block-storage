name             'rcs-openstack-block-storage'
maintainer       'UAF RCS'
maintainer_email 'chef@rcs.alaska.edu'
license          'Apache-2.0'
description      'The OpenStack Advanced Volume Management service Cinder.'
version          '20.0.1'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'apache2', '~> 8.6'
depends 'lvm'
depends 'rcs-openstackclient'
depends 'rcs-openstack-common', '>= 20.0.0'
depends 'rcs-openstack-identity', '>= 20.0.0'
depends 'rcs-openstack-image', '>= 20.0.0'

chef_version '>= 16.0'
