# == Class docker_registry::install
#
class docker_registry::install {

  include docker_registry::params

  $package_name = $docker_registry::package_name
  $manage_nginx = $docker_registry::manage_nginx

  if !defined(Package['build-essential']) {
    package { 'build-essential': }
  }

  if !defined(Package['libevent-dev']) {
    package { 'libevent-dev': }
  }

  if !defined(Package['libssl-dev']) {
    package { 'libssl-dev': }
  }

  if !defined(Package['liblzma-dev']) {
    package { 'liblzma-dev': }
  }

  if ($package_name != undef) {
    package { $package_name:
      ensure => present,
    }
  } else {
    class { 'python':
      version    => 'system',
      pip        => true,
      dev        => true,
    }

    python::pip { 'docker-registry':
      pkgname  => 'docker-registry',
      require  => Class['python'],
    }
  }

  if $manage_nginx {
    if ! defined(Class['nginx']) {
      class { 'nginx':
        package_name => 'nginx-extras',
      }
    }
  }

  file { '/etc/init/docker-registry.conf':
    ensure => present,
    source => 'puppet:///modules/docker_registry/docker-registry.conf',
  }

}
