# == Class: docker_registry
#
# Full description of class docker_registry here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class docker_registry (
  $domain          = $docker_registry::params::domain,
  $secret_key      = $docker_registry::params::secret_key,
  $log_level       = $docker_registry::params::log_level,
  $storage_type    = $docker_registry::params::storage_type,
  $storage_path    = $docker_registry::params::storage_path,
  $listen_ip       = $docker_registry::params::listen_ip,
  $listen_port     = $docker_registry::params::listen_port,
  $package_name    = $docker_registry::params::package_name,
  $service_name    = $docker_registry::params::service_name,
  $enabled         = $docker_registry::params::enabled,
  $config_template = $docker_registry::params::config_template,
  $manage_nginx    = $docker_registry::params::manage_nginx,
  $s3_region       = undef,
  $s3_bucket       = undef,
  $s3_access_key   = undef,
  $s3_secret_key   = undef,
  $s3_storage_path = undef,
) inherits docker_registry::params {

  validate_string($domain)
  validate_string($secret_key)
  validate_string($log_level)
  validate_re($storage_type, '^(file|s3)$')
  validate_absolute_path($storage_path)
  if !is_ip_address($listen_ip) {
    fail('$listen_ip must be an IP address')
  }
  if !is_integer($listen_port) {
    fail('$listen_port must be an integer')
  }
  if ($package_name != undef) {
    validate_string($package_name)
  }
  validate_string($service_name)
  validate_bool($enabled)
  validate_string($config_template)
  validate_bool($manage_nginx)
  if ($s3_region != undef) {
    validate_string($s3_region)
  }
  if ($s3_bucket != undef) {
    validate_string($s3_bucket)
  }
  if ($s3_access_key != undef) {
    validate_string($s3_access_key)
  }
  if ($s3_secret_key != undef) {
    validate_string($s3_secret_key)
  }
  if ($s3_storage_path != undef) {
    validate_string($s3_storage_path)
  }

  class { 'docker_registry::install': } ->
  class { 'docker_registry::config': } ~>
  class { 'docker_registry::service': } ->
  Class['docker_registry']
}
