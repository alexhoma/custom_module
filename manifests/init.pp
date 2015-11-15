# == custom_module == #
# Modulo para provisionar nuestro centOS-65
# + Para añadir index.php a nuestros virtualhosts
==============================================

class custom_module {
    ### HOSTS
    host { 'mysql1':
  		ensure => 'present',
  		target => '/etc/hosts',
  		ip => '127.0.0.1',
  		host_aliases => ['mysql']
  	}

  	host { 'memcached1':
  		ensure => 'present',
  		target => '/etc/hosts',
  		ip => '127.0.0.1',
  		host_aliases => ['memcached']
  	}

    ### APACHE
    class {'apache':}
    apache::vhost { 'centos.dev':
        port => '80',
        docroot => '/var/www',
        add_listen => 'false',
        docroot_owner => 'vagrant',
        docroot_group => 'vagrant',
    }
    apache::vhost { 'project1.dev':
        port => '80',
        docroot => '/var/www/project1/',
        add_listen => 'false',
        docroot_owner => 'vagrant',
        docroot_group => 'vagrant',
    }

    ### MYSQL
    class { '::mysql::server':
      root_password           => 'vagrantpass',
      remove_default_accounts => true,
      override_options        => $override_options
    }
    mysql::db { 'mpwar_test':
      user     => 'mpwar_test',
      password => 'mpwardb',
      host     => 'localhost',
      grant    => ['ALL'],
    }

    ### PHP
    $php_version = '56'

    include ::yum::repo::remi

    if $php_version == '55' {
        include ::yum::repo::remi_php55
    }
    elsif $php_version == '56'{
        ::yum::managed_yumrepo { 'remi-php56':
          descr          => 'Les RPM de remi pour Enterpise Linux $releasever - $basearch - PHP 5.6',
          mirrorlist     => 'http://rpms.famillecollet.com/enterprise/$releasever/php56/mirror',
          enabled        => 1,
          gpgcheck       => 1,
          gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi',
          gpgkey_source  => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-remi',
          priority       => 1,
        }
    }
    class { 'php':
        version => 'latest',
        require => Yumrepo['remi-php56']
    }

    ### EPEL
  	include ::yum::repo::epel

    ### MEMCACHED
    class { 'memcached':
      max_memory => '15%'
    }

    ### INDEX.PHP ADDITIONS
    file {'/var/www/index.php':
      ensure => 'file',
      owner => 'root',
      group => 'root',
      replace => 'true',
      source => 'puppet:///modules/my_module/content.txt'
    }
    file {'/var/www/project1/index.php':
      ensure => 'file',
      owner => 'root',
      group => 'root',
      replace => 'true',
      source => 'puppet:///modules/my_module/content2.txt'
    }


}
