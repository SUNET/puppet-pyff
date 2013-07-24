class pyff ($dir = '/opt/pyff') {
  class { 'python':
    version    => 'system',
    dev        => true,
    virtualenv => true,
    gunicorn   => false,
  }
  python::virtualenv { $dir:
    ensure => present
  }
  python::pip { 'pyff':
    virtualenv => $dir
  }
  file {'pyffd-upstart':
    ensure    => file,
    path      => '/etc/init/pyffd.conf',
    content   => template('pyff/pyffd-upstart.erb'),
    notify    => Service['pyffd']
  }
  file {'pyffd-defaults':
    ensure    => file,
    path      => '/etc/default/pyffd',
    content   => template('pyff/pyffd-defaults.erb'),
    notify    => Service['pyffd']
  }
  service {'pyffd':
    ensure    => 'running',
    require   => [File['pyffd-upstart'],File['pyffd-defaults']]
  }
}
