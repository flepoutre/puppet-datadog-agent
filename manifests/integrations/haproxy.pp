# Class: datadog_agent::integrations::haproxy
#
# This class will install the necessary configuration for the haproxy integration
#
# Parameters:
#   @param url
#     The URL for haproxy
#   @param creds
#   @param options
#   @param instances
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::haproxy' :
#     url     => 'http://localhost:8080',
#     creds   => { username => 'admin',
#                  password => 'password',
#                },
#     options => { collect_aggregates_only => 'False' },
#   }
#
class datadog_agent::integrations::haproxy (
  Hash $creds                = {},
  String $url                = "http://${facts['networking']['ip']}:8080",
  Hash $options              = {},
  Optional[Array] $instances = undef
) inherits datadog_agent::params {
  require datadog_agent

  if !$instances and $url {
    $_instances = [{
        'creds'   => $creds,
        'url'     => $url,
        'options' => $options,
    }]
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/haproxy.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/haproxy.d"
    file { $legacy_dst:
      ensure => 'absent',
    }

    file { $dst_dir:
      ensure  => directory,
      owner   => $datadog_agent::dd_user,
      group   => $datadog_agent::params::dd_group,
      mode    => $datadog_agent::params::permissions_directory,
      require => Package[$datadog_agent::params::package_name],
      notify  => Service[$datadog_agent::params::service_name],
    }
    $dst = "${dst_dir}/conf.yaml"
  } else {
    $dst = $legacy_dst
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_file,
    content => template('datadog_agent/agent-conf.d/haproxy.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
