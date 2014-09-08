# == Class: icinga::preinstall
#
# This class provides anything required by the installation class.
# Such as package repositories.
#
class icinga::preinstall {
  resources {
    [
      'nagios_command',
      'nagios_contact',
      'nagios_contactgroup',
      'nagios_host',
      'nagios_hostdependency',
      'nagios_hostescalation',
      'nagios_hostextinfo',
      'nagios_hostgroup',
      'nagios_service',
      'nagios_servicedependency',
      'nagios_serviceescalation',
      'nagios_serviceextinfo',
      'nagios_servicegroup',
      'nagios_timeperiod'
    ]:
    purge => true;
  }

  file { 'fix-nagios-nrpe-uid-gid.sh':
    source => 'puppet:///modules/icinga/fix-nagios-nrpe-uid-gid.sh',
    path   => '/opt/tlc/fix-nagios-nrpe-uid-gid.sh',
    ensure => present,
    mode   => '0500',
    owner  => 'root',
    group  => 'root',
  }

  exec { 'unfuckify-nagios-nrpe_uid-gid':
    command => '/opt/tlc/fix-nagios-nrpe-uid-gid.sh',
    unless  => "[ $(id -u nagios) == 303 -a $(id -g nagios) == 303 -a $(id -u nrpe) == 301 -a $(id -g nrpe) == 301 ]",
    timeout => 0,
    require => File['fix-nagios-nrpe-uid-gid.sh'],
  }

  user { 'nagios':
    uid        => '303',
    gid        => '303',
    home       => '/var/spool/nagios',
    shell      => '/sbin/nologin',
    ensure     => present,
    allowdupe  => false,
    managehome => true,
    require    => Group['nagios'],
  }

  group { 'nagios':
    gid       => '303',
    ensure    => present,
    allowdupe => false,
    require   => Exec['unfuckify-nagios-nrpe_uid-gid'],
  }

  user { 'nrpe':
    uid        => '301',
    gid        => '301',
    home       => '/var/run/nrpe',
    shell      => '/sbin/nologin',
    ensure     => present,
    allowdupe  => false,
    managehome => true,
    require    => Group['nrpe'],
  }

  group { 'nrpe':
    gid       => '301',
    ensure    => present,
    allowdupe => false,
    require   => Exec['unfuckify-nagios-nrpe_uid-gid'],
  }

  if $icinga::manage_repo == 'true' {
    case $::operatingsystem {
      'Debian', 'Ubuntu': {
      }

      'RedHat', 'CentOS', 'Scientific', 'OEL', 'Amazon': {
        $epel_mirror = $::operatingsystemrelease ? {
          /^5/    => 'https://mirrors.fedoraproject.org/metalink?repo=epel-5&arch=$basearch',
          /^6/    => 'https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch',
          default => Fail['Operating system or release version not supported.'],
        }

        $epel_gpgkey = $::operatingsystemrelease ? {
          /^5/    => 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-5',
          /^6/    => 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6',
          default => Fail['Operating system or release version not supported.'],
        }

        $rpmforge_mirror = $::operatingsystemrelease ? {
          /^5/     => 'http://apt.sw.be/redhat/el5/en/mirrors-rpmforge',
          /^6/     => 'http://apt.sw.be/redhat/el6/en/mirrors-rpmforge',
          default  => Fail['Operating system or release version not supported.'],
        }

        $inuits_mirror = $::operatingsystemrelease ? {
          /^5/     => 'http://repo.inuits.eu/centos/5/os',
          /^6/     => 'http://repo.inuits.eu/centos/6/os',
          default  => Fail['Operating system or release version not supported.'],
        }

        yumrepo { 'epel':
          descr      => 'Extra Packages for Enterprise Linux',
          mirrorlist => $epel_mirror,
          gpgkey     => $epel_gpgkey,
          enabled    => 1,
          gpgcheck   => 1;
        }

        yumrepo {
          'rpmforge':
            descr      => 'RHEL - RPMforge.net - dag',
            mirrorlist => $rpmforge_mirror,
            gpgkey     => 'http://apt.sw.be/RPM-GPG-KEY.dag.txt',
            exclude    => 'nagios-plugins-*',
            enabled    => 1,
            gpgcheck   => 1;
        }

        yumrepo {
          'inuits':
            descr    => 'Inuits repository',
            baseurl  => $inuits_mirror,
            exclude  => '!^nagios-plugins-*',
            enabled  => 1,
            gpgcheck => 0;
        }
      }

      default: {}
    }
  }
}

