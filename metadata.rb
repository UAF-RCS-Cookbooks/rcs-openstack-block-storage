name             'rcs-openstack-block-storage'
maintainer       'UAF RCS'
maintainer_email 'chef@rcs.alaska.edu'
license          'Apache-2.0'
description      'The OpenStack Advanced Volume Management service Cinder.'
version          '20.0.2'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'apache2'
depends 'lvm'
depends 'rcs-openstackclient'
depends 'rcs-openstack-common'
depends 'rcs-openstack-identity'
depends 'rcs-openstack-image'

chef_version '>= 16.0'
