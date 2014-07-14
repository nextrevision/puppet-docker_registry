# == Class docker_registry::config
#
# This class is called from docker_registry
#
class docker_registry::config {
  $domain = $docker_registry::domain
  $secret_key = $docker_registry::secret_key
  $log_level = $docker_registry::log_level
  $listen_ip = $docker_registry::listen_ip
  $listen_port = $docker_registry::listen_port
  $storage_type = $docker_registry::storage_type
  $storage_path = $docker_registry::storage_path
  $config_template = $docker_registry::config_template
  $manage_nginx = $docker_registry::manage_nginx
  $s3_region = $docker_registry::s3_region
  $s3_bucket = $docker_registry::s3_bucket
  $s3_access_key = $docker_registry::s3_access_key
  $s3_secret_key = $docker_registry::s3_secret_key
  $s3_storage_path = $docker_registry::s3_storage_path

  file { $docker_registry::storage_path:
    ensure => directory,
  }

  file { '/var/log/docker-registry':
    ensure => directory,
  }

  file { '/etc/docker-registry':
    ensure => directory,
  }

  file { '/etc/docker-registry/config.yml':
    ensure  => file,
    content => template($config_template),
  }

  file { '/usr/local/lib/python2.7/dist-packages/config/config.yml':
    ensure => link,
    target => '/etc/docker-registry/config.yml',
  }

  if $manage_nginx {
    nginx::resource::vhost { $docker_registry::domain:
      listen_ip            => $docker_registry::listen_ip,
      listen_port          => $docker_registry::listen_port,
      client_max_body_size => 0,
      proxy                => 'http://docker-registry',
      proxy_set_header     => [
        'Host $host',
        'X-Real-IP $remote_addr',
        'Authorization ""'
      ],
      proxy_read_timeout   => 900,
      vhost_cfg_prepend    => {
        'chunkin'        => 'on',
        'error_page 411' => '@my_411_error'
      },
    }

    nginx::resource::location { '@my_411_error':
      vhost               => $docker_registry::domain,
      location_custom_cfg => { 'chunkin_resume' => '' },
    }

    nginx::resource::location {'/v1/_ping':
      vhost              => $docker_registry::domain,
      proxy              => 'http://docker-registry',
      proxy_read_timeout => 900,
      auth_basic         => 'off',
    }

    nginx::resource::location {'/_ping':
      vhost              => $docker_registry::domain,
      proxy              => 'http://docker-registry',
      proxy_read_timeout => 900,
      auth_basic         => 'off',
    }

    nginx::resource::upstream { 'docker-registry':
      members => [ 'localhost:5000'],
    }
  }
}
