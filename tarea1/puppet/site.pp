
$group      = "datum"
$user       = "datum"
$cassandra  = "http://apache.claz.org/cassandra/2.1.14/apache-cassandra-2.1.14-bin.tar.gz"
# -------------- Usuario datum:datum---------------
user {$user:
  ensure      => present,
  gid         => $group,
  managehome  => true,
  password => '$6$7pe0INu/$Uxsn.lb/mJjd9394DIJx5JS9a1NVhrpWDpXRtPGS78/BfyShhOf1G0ft7mRHspXDZo6.ezyqpqIXHQ8Tl8ZJt0',
  require     => Group[$group]
}
group {$group:
  ensure      => present,
}

package {'java-1.8.0-openjdk':
  ensure      => installed
}
package {'wget':
  ensure      => installed,
}

node 'cas00.datum.com.gt' {
  #Directorio del nodo
  $base_dir   = "/home/${user}/node0"
  file {"${base_dir}":
    ensure      => directory,
    owner       => $user,
    group       => $group,
    mode        => "755",
    require     => User[$user],
  }

  #Instalacion de casandra
  exec{ 'download_cassandra':
    command     => "wget -O ${$base_dir}/cassandra-2.1.14.tar.gz ${cassandra}",
    path        => ['/usr/bin','/bin'],
    timeout     => 1200,
    require     => [Package["wget"],File[$base_dir]],
  }
  exec { "decompress_cassandra":
	command     => "/bin/tar -zxvf ${$base_dir}/cassandra-2.1.14.tar.gz",
	cwd         => "${$base_dir}",
	require     => Exec["download_cassandra"],
  }

  #Hosts de los nodos
  host { 'nodo1':
    ip => '5.5.5.1',
  }
  host { 'nodo2':
    ip => '5.5.5.2',
  }
}

node 'cas01.datum.com.gt' {
  #Directorio del nodo
  $base_dir   = "/home/${user}/node1"
  file {"${base_dir}":
    ensure      => directory,
    owner       => $user,
    group       => $group,
    mode        => "755",
    require     => User[$user],
  }

  #Instalacion de casandra
  exec{ 'download_cassandra':
    command     => "wget -O ${$base_dir}/cassandra-2.1.14.tar.gz ${cassandra}",
    path        => ['/usr/bin','/bin'],
    timeout     => 1200,
    require     => [Package["wget"],File[$base_dir]],
  }
  exec { "decompress_cassandra":
	command     => "/bin/tar -zxvf ${$base_dir}/cassandra-2.1.14.tar.gz",
	cwd         => "${$base_dir}",
	require     => Exec["download_cassandra"],
  }

  #Hosts de los nodos
  host { 'nodo0':
    ip => '5.5.5.0',
  }
  host { 'nodo2':
    ip => '5.5.5.2',
  }
}

node 'cas02.datum.com.gt' {
  #Directorio del nodo
  $base_dir   = "/home/${user}/node2"
  file {"${base_dir}":
    ensure      => directory,
    owner       => $user,
    group       => $group,
    mode        => "755",
    require     => User[$user],
  }

  #Instalacion de casandra
  exec{ 'download_cassandra':
    command     => "wget -O ${$base_dir}/cassandra-2.1.14.tar.gz ${cassandra}",
    path        => ['/usr/bin','/bin'],
    timeout     => 1200,
    require     => [Package["wget"],File[$base_dir]],
  }
  exec { "decompress_cassandra":
	command     => "/bin/tar -zxvf ${$base_dir}/cassandra-2.1.14.tar.gz",
	cwd         => "${$base_dir}",
	require     => Exec["download_cassandra"],
  }

  #Hosts de los nodos
  host { 'nodo0':
    ip => '5.5.5.0',
  }
  host { 'nodo1':
    ip => '5.5.5.1',
  }
}
