#Agregar lineas a /etc/sysctl.conf
file { '/etc/sysctl.conf':
  ensure => present,
}->
file_line { 'Append a line to /etc/sysctl.conf':
  path => '/etc/sysctl.conf',
  line => 'fs.file-max = 6815744
    kernel.sem = 250 32000 100 128
    kernel.shmmni = 4096
    kernel.shmall = 1073741824
    kernel.shmmax = 4398046511104
    net.core.rmem_default = 262144
    net.core.rmem_max = 4194304
    net.core.wmem_default = 262144
    net.core.wmem_max = 1048576
    fs.aio-max-nr = 1048576
    net.ipv4.ip_local_port_range = 9000 65500',
}

#Cambiar parametros de kernel
exec { 'sysctl -p':
  path   => '/sbin',
  require => File['/etc/sysctl.conf'],
}

#Agregar lineas a /etc/security/limits.conf
file { '/etc/security/limits.conf':
  ensure => present,
}->
file_line { 'Append a line to /etc/security/limits.conf':
  path => '/etc/security/limits.conf',
  line => 'oracle   soft   nofile    1024
    oracle   hard   nofile    65536
    oracle   soft   nproc    16384
    oracle   hard   nproc    16384
    oracle   soft   stack    10240
    oracle   hard   stack    32768',
}

#Instalar
$paquetes = [ 'binutils', 'compat-libcap1', 'compat-libstdc++-33', 'compat-libstdc++-33.i686', 'gcc', 'gcc-c++', 'glibc', 'glibc.i686', 'glibc-devel', 'glibc-devel.i686', 'ksh', 'libgcc', 'libgcc.i686', 'libstdc++', 'libstdc++.i686', 'libstdc++-devel', 'libstdc++-devel.i686', 'libaio', 'libaio.i686', 'libaio-devel', 'libaio-devel.i686', 'libXext', 'libXext.i686', 'libXtst', 'libXtst.i686', 'libX11', 'libX11.i686', 'libXau', 'libXau.i686', 'libxcb', 'libxcb.i686', 'libXi', 'libXi.i686', 'make', 'sysstat', 'unixODBC', 'unixODBC-devel' ]
package { $paquetes: ensure => 'installed' }

#Agregar grupos oinstall, dba, oper
group { 'oinstall':
  ensure => present,
  gid => 54321,
}
group { 'dba':
  ensure => present,
  gid => 54322,
}
group { 'oper':
  ensure => present,
  gid => 54323,
}

#Agregar usuario oracle
user { 'oracle':
  ensure => present,
  uid => 54321,
  gid => 'oinstall',
  managehome => true,
  groups => ['dba', 'oper'],
}

#Cambiar contraseña de oracle
exec { 'echo datum2016 | passwd oracle --stdin':
  path   => '/usr/bin',
  require => User['oracle'],
}

#Crear /etc/security/limits.d/90-nproc.conf con
file { '/etc/security/limits.d/90-nproc.conf':
  ensure => present,
  content => '* - nproc 16384',
}

#Editar etc/selinux/config y reiniciar el server
file { '/etc/selinux/config':
  ensure => present,
}->
file_line { 'Append a line to /etc/selinux/config':
  path => '/etc/selinux/config',
  line => 'SELINUX=permissive',
  match   => "^SELINUX=enforcing",
  notify => Reboot['reinicio'],
}
reboot { 'reinicio':
  apply  => finished,
}

#Correr comando
exec { 'setenforce Permissive':
  path   => '/usr/sbin',
  require => File['/etc/selinux/config'],
}

#Bajar el firewall
exec { 'service iptables stop':
  path   => '/usr/sbin',
  require => Exec['setenforce Permissive'],
}
exec { 'chkconfig iptables off':
  path   => '/usr/sbin',
  require => Exec['service iptables stop'],
}

#Crear directorios donde Oracle será instalado
exec { 'mkdir -p /u01/app/oracle/product/12.1.0.2/db_1':
  path   => '/usr/bin',
  require => User['oracle'],
}
exec { 'chown -R oracle:oinstall /u01':
  path   => '/usr/bin',
  require => Exec['mkdir -p /u01/app/oracle/product/12.1.0.2/db_1'],
}
exec { 'chmod -R 775 /u01':
  path   => '/usr/bin',
  require => Exec['mkdir -p /u01/app/oracle/product/12.1.0.2/db_1'],
}

#Agregar lineas a /home/oracle/.bash_profile
file { '/home/oracle/.bash_profile':
  ensure => present,
}->
file_line { 'Append a line to /home/oracle/.bash_profile':
  path => '/home/oracle/.bash_profile',
  line => '# Oracle Settings
    export TMP=/tmp
    export TMPDIR=$TMP

    export ORACLE_HOSTNAME=ol6-121.localdomain
    export ORACLE_UNQNAME=cdb1
    export ORACLE_BASE=/u01/app/oracle
    export ORACLE_HOME=$ORACLE_BASE/product/12.1.0.2/db_1
    export ORACLE_SID=cdb1

    export PATH=/usr/sbin:$PATH
    export PATH=$ORACLE_HOME/bin:$PATH

    export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
    export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib',
}
