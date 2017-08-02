# encoding: UTF-8
#
# Cookbook Name:: openstack-block-storage
# Recipe:: volume_driver_lvm
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

platform_options = node['openstack']['block-storage']['platform']
platform_options['cinder_lvm_packages'].each do |pkg|
  package pkg do
    options platform_options['package_overrides']
    action :upgrade
  end
end

# TODO: (jklare) this whole section should be refactored and probably include an
# external cookbook for managing lvm stuff

vg_name = node['openstack']['block-storage']['conf']['DEFAULT']['volume_group']
case node['openstack']['block-storage']['volume']['create_volume_group_type']
when 'file'
  volume_size = node['openstack']['block-storage']['volume']['volume_group_size']
  seek_count = volume_size.to_i * 1024
  vg_file = "#{node['openstack']['block-storage']['conf']['DEFAULT']['state_path']}/#{vg_name}.img"

  # create volume group
  execute 'Create Cinder volume group' do
    command "dd if=/dev/zero of=#{vg_file} bs=1M seek=#{seek_count} count=0; vgcreate #{vg_name} $(losetup --show -f #{vg_file})"
    action :run
    not_if "vgs #{vg_name}"
  end

  cookbook_file '/etc/systemd/system/cinder-group-active.service' do
    source 'cinder-group-active.service'
    mode '0644'
    action :create_if_missing
  end

  template '/etc/init.d/cinder-group-active' do
    source 'cinder-group-active.erb'
    mode '0755'
    variables(
      volume_name: vg_name,
      volume_file: vg_file
    )
    notifies :start, 'service[cinder-group-active]', :immediately
  end

  service 'cinder-group-active' do
    service_name 'cinder-group-active'
    action [:enable, :start]
  end

when 'block_devices'
  block_devices = node['openstack']['block-storage']['volume']['block_devices']
  execute 'Create Cinder volume group with block devices' do
    command "pvcreate #{block_devices}; vgcreate #{vg_name} #{block_devices}"
    action :run
    not_if "vgs #{vg_name}"
  end
end
