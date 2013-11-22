#
# This class defines our users
#
class icinga::users {
  icinga::user {
    'mchesler':
      ensure => present,
      password => 'password',
      email  => 'mchesler@theladders.com',
  }
}

