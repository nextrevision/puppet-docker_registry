require 'spec_helper'

describe 'docker_registry' do
  context 'supported operating systems' do
    ['Debian'].each do |osfamily|
      describe "docker_registry class without any parameters on #{osfamily}" do
        concat_dir = '/tmp/concat' if concat_dir.nil?
        let(:params) {{ }}
        let(:facts) {{
          :kernel          => 'linux',
          :lsbdistid       => 'ubuntu',
          :lsbdistcodename => 'precise',
          :osfamily        => osfamily,
          :concat_basedir  => concat_dir,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('docker_registry::params') }
        it { should contain_class('docker_registry::install').that_comes_before('docker_registry::config') }
        it { should contain_class('docker_registry::config') }
        it { should contain_class('docker_registry::service').that_subscribes_to('docker_registry::config') }

        it { should contain_service('docker_registry') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'docker_registry class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('docker_registry') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
