# Private Class
class minecraft::params {
  $user          = 'mcserver'
  $group         = 'mcserver'
  $homedir       = "/home/$user"
  $manage_java   = true
  $manage_screen = true
  $manage_curl   = true
  $heap_size     = 2048
  $heap_start    = 512

  case $::osfamily {
    'RedHat': {
    }
      
    default: {
      fail("Unsupported platform: ${module_name} currently doesn't support ${::osfamily}")
    }
  }
}

