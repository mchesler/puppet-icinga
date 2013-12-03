# == Class: icinga::plugins::icingaweb
#
# This class provides the icinga-web plugin
#
class icinga::plugins::icingaweb {
  if $icinga::server {
    include icinga::plugins::icingaweb::install
    include icinga::plugins::icingaweb::config

    Class['icinga::plugins::icingaweb::install'] -> Class['icinga::plugins::icingaweb::config']
  }
}
