class pyff ($dir = '/opt/pyff', 
            $version = undef, 
            $key = "default.key", 
            $cert = "default.crt", 
            $load = [],
            $cacheDuration = "PT5H",
            $validUntil = "PT10D",
            $replace = true,
            $port = "8080",
            $address = "127.0.0.1") {
  package {'build-essential': ensure => installed}
  package {'libyaml-dev': ensure => installed}
  package {'libxml2-dev': ensure => installed} 
  package {'libxslt-dev': ensure => installed}
  Package['build-essential'] -> Package['libxml2-dev'] -> Package['libxslt-dev'] -> Package['libyaml-dev']
  class { 'python':
    version    => 'system',
    dev        => true,
    virtualenv => true,
    gunicorn   => false,
  }
  Package['libyaml-dev'] -> Class['python']
  python::virtualenv { $dir:
    ensure => present
  }
  $ver = $version ? {
    undef     => '',
    /[0-9]/   => "==${version}",
    default   => ''
  }
  python::pip { 'pyff${ver}':
    virtualenv => $dir
  }
  File[$dir] -> Exec['default-keygen']
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
    replace   => $replace,
    notify    => Service['pyffd']
  }
  exec { "default-keygen":
    command => "openssl genrsa 2048 > ${dir}/default.key",
    creates => "${dir}/default.key"
  }
  exec { "default-signer":
    command => "openssl req -x509 -sha1 -new -subj \"/CN=Default Signer (${fqdn})\" -key ${dir}/default.key -out ${dir}/default.crt",
    creates => "${dir}/default.crt"
  }
  Exec['default-keygen'] -> Exec['default-signer']
  file {"mdx.fd":
    ensure  => file,
    path    => "${dir}/mdx.fd",
    content => template('pyff/mdx.erb'),
    replace => $replace,
    notify  => Service['pyffd']
  }
  service {'pyffd':
    ensure    => 'running',
    require   => [File['pyffd-upstart'],File['pyffd-defaults'],File['mdx.fd']]
  }
  Exec['default-signer'] -> Service['pyffd']
}
