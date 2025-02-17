# Class: datadog_agent::integrations::pgbouncer
#
# This class will install the necessary configuration for the pgbouncer integration
#
# Parameters:
#   @param password
#       The password for the datadog user
#   @param host
#       The host pgbouncer is listening on
#   @param port
#       The pgbouncer port number
#   @param username
#       The username for the datadog user
#   @param tags
#       Optional array of tags
#   @param pgbouncers
#       Optional array of pgbouncer hashes. See example
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::pgbouncer' :
#    host           => 'localhost',
#    username       => 'datadog',
#    port           => '6432',
#    password       => 'some_pass',
#  }
#
#  class { 'datadog_agent::integrations::pgbouncer' :
#    pgbouncers     => [
#      {
#        'host'     => 'localhost',
#        'username' => 'datadog',
#        'port'     => '6432',
#        'password' => 'some_pass',
#        'tags'     => ['instance:one'],
#      },
#      {
#        'host'     => 'localhost',
#        'username' => 'datadog2',
#        'port'     => '6433',
#        'password' => 'some_pass2',
#      },
#    ],
#  }
#
class datadog_agent::integrations::pgbouncer (
  Optional[String] $password     = undef,
  String $host                   = 'localhost',
  Variant[String, Integer] $port = '6432',
  String $username               = 'datadog',
  Array $tags                    = [],
  Array $pgbouncers              = [],
) inherits datadog_agent::params {
  require datadog_agent

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/pgbouncer.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/pgbouncer.d"
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
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/pgbouncer.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
