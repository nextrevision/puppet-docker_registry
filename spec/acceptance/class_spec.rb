require 'spec_helper_acceptance'

describe 'docker_registry class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'docker_registry': }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to_not eq(1)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to eq(0)
    end

    describe service('docker-registry') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('nginx') do
      it { should be_enabled }
      it { should be_running }
    end
    describe file("/etc/docker-registry/config.yml") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'storage_path: /mnt/registry' }
      it { is_expected.to contain 'sqlalchemy_index_database: sqlite:////mnt/registry/docker-registry.db' }
      it { is_expected.to contain 'secret_key: cd8fbaa639122edad0617212ff0a6666' }
      it { is_expected.to contain 'loglevel: info' }
    end
    it 'should respond to docker registry ping' do
      shell("/usr/bin/wget -O- -q http://localhost/v1/_ping", {:acceptable_exit_codes => 0}) do |r|
        expect(r.stdout).to eq("true")
      end
    end
    it 'should respond to docker registy index' do
      shell("/usr/bin/wget -O- -q http://localhost/", {:acceptable_exit_codes => 0}) do |r|
        expect(r.stdout).to match(/docker-registry server \(prod\)/)
      end
    end
  end
  context 'with custom parameters' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'docker_registry':
          domain       => 'localhost.localdomain',
          secret_key   => 'changeme',
          log_level    => 'warn',
          storage_path => '/tmp/registry_store',
          listen_ip    => '127.0.0.1',
          listen_port  => '8050',
        }
      EOS
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to_not eq(1)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to eq(0)
    end
    describe file("/etc/nginx/sites-enabled/localhost.localdomain.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'localhost.localdomain;' }
      it { is_expected.to contain '127.0.0.1:8050;' }
    end
    describe file("/etc/docker-registry/config.yml") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'storage_path: /tmp/registry_store' }
      it { is_expected.to contain 'sqlalchemy_index_database: sqlite:////tmp/registry_store/docker-registry.db' }
      it { is_expected.to contain 'secret_key: changeme' }
      it { is_expected.to contain 'loglevel: warn' }
    end
    describe service('docker-registry') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('nginx') do
      it { should be_enabled }
      it { should be_running }
    end
    it 'should respond to docker registry ping' do
      shell("/usr/bin/wget -O- -q http://localhost:8050/v1/_ping", {:acceptable_exit_codes => 0}) do |r|
        expect(r.stdout).to eq("true")
      end
    end
    it 'should respond to docker registy index' do
      shell("/usr/bin/wget -O- -q http://localhost:8050/", {:acceptable_exit_codes => 0}) do |r|
        expect(r.stdout).to match(/docker-registry server \(prod\)/)
      end
    end
  end
end
