#
# Cookbook:: openstack-block-storage
# Recipe:: volume
#
# Copyright:: 2012-2021, Rackspace US, Inc.
# Copyright:: 2012-2021, AT&T Services, Inc.
# Copyright:: 2013-2021, Chef Software, Inc.
# Copyright:: 2013-2021, SUSE Linux Gmbh.
# Copyright:: 2013-2021, IBM, Corp.
# Copyright:: 2020-2021, Oregon State University
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
#

# Chef
class ::Chef::Recipe
  include ::Openstack
end

include_recipe 'rcs-openstack-block-storage::cinder-common'

platform_options = node['openstack']['block-storage']['platform']

package platform_options['cinder_volume_packages'] do
  options platform_options['package_overrides']
  action :upgrade
end

db_type = node['openstack']['db']['block_storage']['service_type']
package node['openstack']['db']['python_packages'][db_type] do
  action :upgrade
end

package platform_options['cinder_iscsitarget_packages'] do
  options platform_options['package_overrides']
  action :upgrade
end

service 'cinder-volume' do
  service_name platform_options['cinder_volume_service']
  supports status: true, restart: true
  action [:enable, :start]
  subscribes :restart, 'template[/etc/cinder/cinder.conf]'
end

service 'iscsitarget' do
  service_name platform_options['cinder_iscsitarget_service']
  supports status: true, restart: true
  action :enable
end
