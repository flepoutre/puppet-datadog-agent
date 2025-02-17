# Class: datadog_agent::integrations::kubernetes
#
# This class will install the necessary configuration for the kubernetes integration
#
# Parameters:
#   @param url
#     The URL for kubernetes metrics
#
#   @param tags
#     optional array of tags
#
#
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::kubernetes_state' :
#     url  => 'http://kubernetes.com:8080/metrics',
#   }
#
class datadog_agent::integrations::kubernetes_state (
  String $url = 'Enter_State_URL',
  Array $tags = [],
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/kubernetes_state.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/kubernetes_state.d"
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
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
    content => template('datadog_agent/agent-conf.d/kubernetes_state.yaml.erb'),
  }
}
