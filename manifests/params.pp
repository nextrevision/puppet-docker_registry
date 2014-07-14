# == Class docker_registry::params
#
# This class is meant to be called from docker_registry
# It sets variables according to platform
#
class docker_registry::params {
  $domain          = 'localhost'
  $secret_key      = 'cd8fbaa639122edad0617212ff0a6666'
  $log_level       = 'info'
  $storage_type    = 'file'
  $storage_path    = '/mnt/registry'
  $enabled         = true
  $config_template = 'docker_registry/config.yml.erb'
  $manage_nginx    = true
  $listen_ip       = '0.0.0.0'
  $listen_port     = 80

  case $::osfamily {
    'Debian': {
      $package_name = undef
      $service_name = 'docker-registry'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
