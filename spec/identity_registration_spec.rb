# encoding: UTF-8
#
# Cookbook Name:: openstack-block-storage

require_relative 'spec_helper'

describe 'openstack-block-storage::identity_registration' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'block-storage-stubs'

    connection_params = {
      openstack_auth_url: 'http://127.0.0.1:35357/v3/auth/tokens',
      openstack_username: 'admin',
      openstack_api_key: 'emc_test_pass',
      openstack_project_name: 'admin',
      openstack_domain_name: 'default',
    }
    service_name = 'cinderv2'
    service_type = 'volumev2'
    service_user = 'cinder'
    url = 'http://127.0.0.1:8776/v2/%(tenant_id)s'
    region = 'RegionOne'
    project_name = 'service'
    role_name = 'service'
    password = 'cinder-pass'
    domain_name = 'Default'

    it "registers #{project_name} Project" do
      expect(chef_run).to create_openstack_project(
        project_name
      ).with(
        connection_params: connection_params
      )
    end

    it "registers #{service_name} service" do
      expect(chef_run).to create_openstack_service(
        service_name
      ).with(
        connection_params: connection_params,
        type: service_type
      )
    end

    context "registers #{service_name} endpoint" do
      %w(admin internal public).each do |interface|
        it "#{interface} endpoint with default values" do
          expect(chef_run).to create_openstack_endpoint(
            service_type
          ).with(
            service_name: service_name,
            # interface: interface,
            url: url,
            region: region,
            connection_params: connection_params
          )
        end
      end

      it 'with custom region override' do
        node.set['openstack']['block-storage']['region'] = 'volumeRegion'
        expect(chef_run).to create_openstack_endpoint(
          service_type
        ).with(region: 'volumeRegion')
      end
    end

    it 'registers service user' do
      expect(chef_run).to create_openstack_user(
        service_user
      ).with(
        project_name: project_name,
        role_name: role_name,
        password: password,
        connection_params: connection_params
      )
    end

    it do
      expect(chef_run).to grant_domain_openstack_user(
        service_user
      ).with(
        domain_name: domain_name,
        role_name: role_name,
        connection_params: connection_params
      )
    end

    it do
      expect(chef_run).to grant_role_openstack_user(
        service_user
      ).with(
        project_name: project_name,
        role_name: role_name,
        password: password,
        connection_params: connection_params
      )
    end
  end
end
