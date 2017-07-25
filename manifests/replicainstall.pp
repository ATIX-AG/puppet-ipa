class freeipa::replicainstall(
  String $realm               = undef,
  String $domain              = undef,
  $adminpw                    = undef,
  $password                   = undef,
  $principal                  = undef,
  String $hostname            = undef,
  String $server              = undef,
  Boolean $setup_dns          = false,
  Boolean $mkhomedir          = false,
  Boolean $no_host_dns        = false,
  Boolean $no_ntp             = false,
  Boolean $ssh_trust_dns      = false,
  Boolean $no_ssh             = false,
  Boolean $no_sshd            = false,
  Boolean $auto_forwarders    = false,
  Boolean $no_forwarders      = false,
  Boolean $no_reverse         = false,
  Boolean $auto_reverse       = false,
  Boolean $setup_ca           = false,
  Boolean $setup_kra          = false,
  Boolean $skip_conncheck     = false,
  Boolean $skip_schema_check  = false,
  Boolean $allow_zone_overlap = false,
  $ip                         = undef,
  $dirsrv_cert_file           = undef,
  $dirsrv_pin                 = undef,
  $dirsrv_cert_name           = undef,
  $http_cert_file             = undef,
  $http_pin                   = undef,
  $http_cert_name             = undef,
  $forward_policy             = undef,
  $reverse_zone               = undef,
  Array $forwarders           = [],
  Array $options              = [],
  Boolean $upgrade            = false,
){
  package{'ipa-server':
    ensure => installed,
  }

  file_line{'remove hostname from localhost /etc/hosts':
    ensure            => absent,
    path              => '/etc/hosts',
    line              => "#127.0.0.1 ${hostname}",
    match             => "^127.0.0.1.*${hostname}.*",
    match_for_absence => true,
  }

  if $setup_dns{
    package{'ipa-server-dns':
      ensure => installed,
    }
    $b_setup_dns = '--setup-dns'
  }
  else{
    $b_setup_dns = ''
  }

  $b_mkhomedir = $mkhomedir ? {
    true    => '--mkhomedir',
    default => '',
  }
  $b_no_host_dns = $no_host_dns ? {
    true    => '--no-host-dns',
    default => '',
  }
  $b_no_ntp = $no_ntp ? {
    true    => '--no-ntp',
    default => '',
  }
  $b_ssh_trust_dns = $ssh_trust_dns ? {
    true    => '--ssh-trust-dns',
    default => '',
  }
  $b_no_ssh = $no_ssh ? {
    true    => '--no-ssh',
    default => '',
  }
  $b_no_sshd = $no_sshd ? {
    true     => '--no-sshd',
    default  => '',
  }
  $b_auto_forwarders = $auto_forwarders ? {
    true    => '--auto-forwarders',
    default => '',
  }
  $b_no_forwarders = $no_forwarders ? {
    true    => '--no-forwarders',
    default => '',
  }
  $b_auto_reverse = $auto_reverse ? {
    true    => '--auto-reverse',
    default => '',
  }
  $b_no_reverse = $no_reverse ? {
    true    => '--no-reverse',
    default => '',
  }
  $b_setup_ca = $setup_ca ? {
    true    => '--setup-ca',
    default => '',
  }
  $b_setup_kra = $setup_kra ? {
    true    => '--setup-kra',
    default => '',
  }
  $b_skip_conncheck = $skip_conncheck ? {
    true    => '--skip-conncheck',
    default => '',
  }
  $b_skip_schema_check = $skip_schema_check ? {
    true    => '--skip-schema-check',
    default => '',
  }
  $b_allow_zone_overlap = $allow_zone_overlap ? {
    true    => '--allow-zone-overlay',
    default => '',
  }

  $f_ip = $ip ? {
    undef   => '',
    default => "--ip-address=${ip}",
  }
  $f_dirsrv_cert_file = $dirsrv_cert_file ? {
    undef   => '',
    default => "--dirsrv-cert-file=${dirsrv_cert_file}",
  }
  $f_dirsrv_pin = $dirsrv_pin ? {
    undef   => '',
    default => "--dirsrv-pin=${dirsrv_pin}",
  }
  $f_dirsrv_cert_name = $dirsrv_cert_name ? {
    undef   => '',
    default => "--dirsrv-cert-name=${dirsrv_cert_name}",
  }
  $f_http_cert_file = $http_cert_file ? {
    undef   => '',
    default => "--http-cert-file=${http_cert_file}",
  }
  $f_http_pin = $http_pin ? {
    undef   => '',
    default => "--http-pin=${http_pin}",
  }
  $f_http_cert_name = $http_cert_name ? {
    undef   => '',
    default => "--http-cert-name=${http_cert_name}",
  }
  $f_forward_policy = $forward_policy ? {
    undef   => '',
    default => "--forward-policy=${forward_policy}",
  }
  $f_reverse_zone = $reverse_zone ? {
    undef   => '',
    default => "--reverse-zone=${reverse_zone}",
  }
  if $forwarders != undef {
    $forward_prefix = prefix($forwarders,"--forwarder=")
    $f_forwarders = join($forward_prefix, " ")
  } else {
    $f_forwarders = ''
  }

  $b_opts = "${b_setup_dns} ${b_mkhomedir} ${b_no_host_dns} ${b_no_ntp} ${b_ssh_trust_dns} ${b_no_ssh} ${b_no_sshd} ${b_auto_forwarders} ${b_no_forwarders} ${b_no_reverse} ${b_auto_reverse} ${b_setup_ca} ${b_setup_kra} ${b_skip_conncheck} ${b_skip_schema_check} ${b_allow_zone_overlap}"
  $f_opts = "${f_ip} ${f_dirsrv_cert_file} ${f_dirsrv_pin} ${dirsrv_cert_name} ${f_http_cert_file} ${f_http_pin} ${f_http_cert_name} ${f_forward_policy} ${f_reverse_zone} ${f_forwarders}"
  $opts = join($options, " ")

  if $adminpw == undef {
    $f_pw = "--password='${password}'"
  } else {
    $f_pw = "--admin-password='${adminpw}'"
  }

  if $principal != undef {
    $f_princ = "--principal=${principal}"
  } else {
    $f_princ = ''
  }

  if $upgrade {

    exec { "upgrade to replica ${hostname}":
      command   => "/usr/sbin/ipa-replica-install ${f_princ} ${f_pw} --unattended",
      unless    => '/usr/sbin/ipactl status >/dev/null 2>&1',
      logoutput => 'on_failure',
      creates   => '/etc/ipa/.upgraded',
      before    => File['/etc/ipa/.upgraded'],
      timeout   => '0',
    }
    file{'/etc/ipa/.upgraded':
      ensure => present,
    }


  } else {

    #    notify{"/usr/sbin/ipa-replica-install --hostname=${hostname} --server=${server} --realm=${realm} --domain=${domain} ${f_pw} ${f_princ} ${b_opts} ${f_opts} ${opts} --unattended":}

    exec { "replica install-${hostname}":
      command   => "/usr/sbin/ipa-replica-install --hostname=${hostname} --server=${server} --realm=${realm} --domain=${domain} ${f_pw} ${f_princ} ${b_opts} ${f_opts} ${opts} --unattended",
      timeout   => '0',
      unless    => '/usr/sbin/ipactl status >/dev/null 2>&1',
      creates   => '/etc/ipa/default.conf',
      logoutput => 'on_failure',
      require   => File_line['remove hostname from localhost /etc/hosts'],
    }
  }

}
