# == Class docker_registry::service
#
# This class is meant to be called from docker_registry
# It ensure the service is running
#
class docker_registry::service {

  $service_name = $docker_registry::service_name
  $enabled = $docker_registry::enabled
  $ensure = $enabled ? {
    true  => running,
    false => stopped
  }

  service { $service_name:
    ensure     => $ensure,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
  }
}
