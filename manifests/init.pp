# Class: minecraft
#
# This class installs and configures a Minecraft server
#
# Parameters:
# - $user: The user account for the Minecraft service
# - $group: The user group for the Minecraft service
# - $homedir: The directory in which Minecraft stores its data
# - $manage_java: Should this module manage the `java` package?
# - $manage_screen: Should this module manage the `screen` package?
# - $manage_curl: Should this module manage the `curl` package?
# - $heap_size: The maximum Java heap size for the Minecraft service in megabytes
# - $heap_start: The initial Java heap size for the Minecraft service in megabytes
#
# Sample Usage:
#
#  class { 'minecraft':
#    user      => 'mcserver',
#    group     => 'mcserver',
#    heap_size => 4096,
#  }
#
class minecraft(
  $user                     = $::minecraft::params::user,
  $group                     = $::minecraft::params::group,
  $homedir                  = $::minecraft::params::homedir,
  $manage_java              = $::minecraft::params::manage_java,
  $manage_screen            = $::minecraft::params::manage_screen,
  $manage_curl              = $::minecraft::params::manage_curl,
  $version                  = $::minecraft::params::version,
  $heap_size                = 2048,
  $heap_start               = 512,
  $instance                 = 'minecraft',
  $eula                     = false,
  $gamemode                 = 0,
  $difficulty               = 1,
  $server_port              = 25565,
  $online_mode              = true,
  $motd                     = 'A Minecraft Server',
) inherits minecraft::params {

  if $manage_java {
    class { 'java':
      distribution => 'jre',
      before       => Service['minecraft']
    }
  }

  if $manage_screen {
    package {'screen':
      before => Service['minecraft']
    }
  }

  if $manage_curl {
    package {'curl':
      before => S3file["${homedir}/minecraft_server_${version}.jar"],
    }
  }

  group { $group:
    ensure => present,
  }

  user { $user:
    gid        => $group,
    home       => $homedir,
    managehome => true,
  }


  file {"${homedir}/eula.txt":
    ensure  => present,
    owner   => $user,
    group   => $group,
    content => template('minecraft/eula.txt.erb'),
    require => User[$user],
  } ->
  file {"${homedir}/server.properties":
    ensure  => present,
    owner   => $user,
    group   => $group,
    content => template('minecraft/server.properties.erb'),
  } ->
  s3file { "${homedir}/minecraft_server_${version}.jar":
    source  => "Minecraft.Download/versions/${version}/minecraft_server.${version}.jar",
    require => User[$user],
  }

  file { "${homedir}/ops.txt":
    ensure => present,
    owner  => $user,
    group  => $group,
    mode   => '0664',
  } -> Minecraft::Op<| |>

  file { "${homedir}/banned-players.txt":
    ensure => present,
    owner  => $user,
    group  => $group,
    mode   => '0664',
  } -> Minecraft::Ban<| |>

  file { "${homedir}/banned-ips.txt":
    ensure => present,
    owner  => $user,
    group  => $group,
    mode   => '0664',
  } -> Minecraft::Ipban<| |>

  file { "${homedir}/white-list.txt":
    ensure => present,
    owner  => $user,
    group  => $group,
    mode   => '0664',
  } -> Minecraft::Whitelist<| |>

  file { '/etc/systemd/system/minecraft.service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0744',
    content => template('minecraft/minecraft_service.erb'),
  }

  service { 'minecraft':
    ensure    => running,
    require   => File['/etc/systemd/system/minecraft.service'],
    subscribe => [ S3file["${homedir}/minecraft_server_${version}.jar"], File["${homedir}/server.properties"] ],
  }
}
