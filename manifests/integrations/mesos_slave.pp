# Class: datadog_agent::integrations::mesos_slave
#
# This class will install the necessary configuration for the mesos slave integration
#
# Parameters:
#   @param mesos_timeout
#   @param url
#     The URL for Mesos slave
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::mesos' :
#     url  => "http://localhost:5051"
#   }
#
class datadog_agent::integrations::mesos_slave (
  Integer $mesos_timeout = 10,
  String $url            = 'http://localhost:5051',
) inherits datadog_agent::params {
  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/mesos_slave.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/mesos_slave.d"
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
    content => template('datadog_agent/agent-conf.d/mesos_slave.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
