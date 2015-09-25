# Private Class
class minecraft::params {
  $user          = 'mcserver'
  $group         = 'mcserver'
  $homedir       = '/home/mcserver'
  $manage_java   = true
  $manage_screen = true
  $manage_curl   = true
  $heap_size     = 2048
  $heap_start    = 512
  $version       = '1.8.8'

  case $::osfamily {
    'RedHat': {
    }
      
    default: {
      fail("Unsupported platform: ${module_name} currently doesn't support ${::osfamily}")
    }
  }
}

