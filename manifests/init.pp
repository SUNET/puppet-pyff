class pyff ($dir = '/opt/pyff') {
  include python
  package {"python-virtualenv":
     ensure => latest
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
  Package["python-virtualenv"] -> Service["pyffd"]
}
