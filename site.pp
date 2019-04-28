## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# Disable filebucket by default for all File resources:
File { backup => false }

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {

# variables
  $pkgs = ['lynx','elinks','w3m','python36']
  if ($osfamily == 'RedHat') {
    $str = "#Managed by Puppet. This is $osfamily system. Specifically $operatingsystem $operatingsystemrelease. Hostname: $hostname"
  }
  else {
    $str = "#Managed by Puppet. This is $operatingsystem $operatingsystemrelease. Hostname: $hostname"
  }
# Example of including external class : rtorrent client package install
  include rtorrent::install
  include vimrc::install

# user creation
  user { 'test':
    ensure => present,
    uid    => 1050,
    groups => 'wheel',
    shell  => '/bin/bash',
    home   => '/home/test',
  }

# file, directories creation
  file { '/home/test':
    ensure  => directory,
    path    => '/home/test',
    owner   => 'test',
    group   => 'test',
    mode    => '0750',
    require => User['test'],
  }

  file { 'home/test/documents':
    ensure  => directory,
    path    => '/home/test/documents',
    owner   => 'test',
    group   => 'test',
    mode    => '0770',
    require => File['/home/test'],
  }
  
  file { 'home/test/documents/file1.txt':
    ensure  => present,
    path    => '/home/test/documents/file1.txt',
    content => $str,
    owner   => 'test',
    group   => 'test',
    mode    => '0777',
    require => File['/home/test/documents'],
  }

  file { 'test.txt':
    ensure  => present,
    path    => '/home/test/test.txt',
    content => $str,
    owner   => 'test',
    group   => 'test',
    mode    => '0666',
    require => User['test'],
  }

# cron jobs
  cron { 'list':
    command => '/usr/bin/ls -lR /home/test > /home/test/listing.txt 2>/dev/null',
    user    => 'test',
    hour    => 16,
    minute  => 0,
  }


# packages with variable array (at the top)
  package { $pkgs:
    ensure => latest,
  }
}


node 'peres091c.mylabserver.com' { 
  include nginx
  include vimrc
}

node 'peres095c.mylabserver.com' {
  $pkgs = ['lynx','git']
  package { $pkgs:
    ensure => 'present',
  }
}
