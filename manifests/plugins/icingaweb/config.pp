class icinga::plugins::icingaweb::config {
  File {
    owner   => $icinga::webserver_user,
    group   => $icinga::webserver_group,
    require => Package[$icinga::icingaweb_pkg],
    notify  => [
      Service[$icinga::service_server],
      Service[$icinga::service_webserver],
    ]
  }

  mysql::db { $icinga::icingaweb_dbname:
    user     => $icinga::icingaweb_dbuser,
    password => $icinga::icingaweb_dbpass,
  }

  file {
    $icinga::icingaweb_confdir:
      ensure => directory;

    "${icinga::icingaweb_confdir}/etc/conf.d":
      ensure => directory;

    $icinga::icingaweb_logdir:
      ensure => directory;

    "${icinga::icingaweb_confdir}/etc/conf.d/databases.xml":
      ensure  => present,
      content => template('icinga/plugins/icingaweb/databases.xml'),
      notify  => Exec['db-initialize'];

    "${icinga::icingaweb_confdir}/app/modules/AppKit/config/auth.xml":
      ensure  => present,
      content => template('icinga/plugins/icingaweb/auth.xml.erb'),
      notify  => Service[$icinga::service_webserver];
  }

  exec { 'db-initialize':
    path    => $icinga::icingaweb_bindir,
    cwd     => "${icinga::icingaweb_confdir}/etc",
    command => 'echo y | phing -Dproperties=etc/build.properties db-initialize',
    unless  => "mysqlshow ${icinga::icingaweb_dbname} | grep cronk",
  }
}
