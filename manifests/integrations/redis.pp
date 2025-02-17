# Class: datadog_agent::integrations::redis
#
# This class will install the necessary configuration for the redis integration
#
# Parameters:
#   @param host
#       The host redis is running on
#   @param password
#       The redis password (optional)
#   @param port
#       The main redis port.
#   @param ports
#       Array of redis ports: overrides port (optional)
#   @param slowlog_max_len
#       The max length of the slow-query log (optional)
#   @param tags
#       Optional array of tags
#   @param keys
#       Optional array of keys to check length
#   @param command_stats
#       Collect INFO COMMANDSTATS output as metrics
#   @param instances
#       Optional array of hashes should you wish to specify multiple instances.
#       If this option is specified all other parameters will be overriden.
#       This parameter may also be used to specify instances with hiera.
#   @param warn_on_missing_keys 
#
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::redis' :
#    host => 'localhost',
#  }
#
# Hiera Usage:
#
#   datadog_agent::integrations::redis::instances:
#     - host: 'localhost'
#       password: 'datadog'
#       port: 6379
#       slowlog_max_len: 1000
#       warn_on_missing_keys: true
#       command_stats: false
#
class datadog_agent::integrations::redis (
  String $host                                        = 'localhost',
  Optional[String] $password                          = undef,
  Variant[String, Integer] $port                      = '6379',
  Optional[Array] $ports                              = undef,
  Optional[Variant[String, Integer]] $slowlog_max_len = undef,
  Array $tags                                         = [],
  Array $keys                                         = [],
  Boolean $warn_on_missing_keys                       = true,
  Boolean $command_stats                              = false,
  Optional[Array] $instances                          = undef,
) inherits datadog_agent::params {
  require datadog_agent

  if $ports == undef {
    $_ports = [$port]
  } else {
    $_ports = $ports
  }

  $_port_instances = $_ports.map |$instance_port| {
    {
      'host'                 => $host,
      'password'             => $password,
      'port'                 => $instance_port,
      'slowlog_max_len'      => $slowlog_max_len,
      'tags'                 => $tags,
      'keys'                 => $keys,
      'warn_on_missing_keys' => $warn_on_missing_keys,
      'command_stats'        => $command_stats,
    }
  }

  $legacy_dst = "${datadog_agent::params::legacy_conf_dir}/redisdb.yaml"
  if versioncmp($datadog_agent::_agent_major_version, '5') > 0 {
    $dst_dir = "${datadog_agent::params::conf_dir}/redisdb.d"
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

  if !$instances and $host {
    $_instances = $_port_instances
  } elsif !$instances {
    $_instances = []
  } else {
    $_instances = $instances
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => $datadog_agent::params::permissions_protected_file,
    content => template('datadog_agent/agent-conf.d/redisdb.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name],
  }
}
