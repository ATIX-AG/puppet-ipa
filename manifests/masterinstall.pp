class freeipa::masterinstall(
  String $realm            = undef,
  String $domain           = undef,
  String $dmpw             = undef,
  String $adminpw          = undef,
  String $hostname         = undef,
  Boolean $setup_dns       = false,
  Boolean $mkhomedir       = false,
  Boolean $no_host_dns     = false,
  Boolean $no_ntp          = false,
  Boolean $no_hbac_allow   = false,
  Boolean $ssh_trust_dns   = false,
  Boolean $no_ssh          = false,
  Boolean $no_sshd         = false,
  Boolean $external_ca     = false,
  Boolean $auto_forwarders = false,
  Boolean $no_forwarders   = false,
  Boolean $no_reverse      = false,
  Boolean $auto_reverse    = false,
  $ip                      = undef,
  $idstart                 = undef,
  $idmax                   = undef,
  $ext_ca_type             = undef,
  $ext_cert_file           = undef,
  $dirsrv_cert_file        = undef,
  $dirsrv_pin              = undef,
  $dirsrv_cert_name        = undef,
  $http_cert_file          = undef,
  $http_pin                = undef,
  $http_cert_name          = undef,
  $ca_cert_file            = undef,
  $subject                 = undef,
  $ca_algorithm            = undef,
  $forward_policy          = undef,
  $reverse_zone            = undef,
  $zonemgr                 = undef,
  Array $forwarders        = [],
  Array $options           = [],
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
  $b_no_hbac_allow = $no_hbac_allow ? {
    true    => '--no_hbac_allow',
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
  $b_external_ca = $external_ca ? {
    true    => '--external-ca',
    default => '',
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

  $f_ip = $ip ? {
    undef   => '',
    default => "--ip-address=${ip}",
  }
  $f_idstart = $idstart ? {
    undef   => '',
    default => "--idstart=${idstart}",
  }
  $f_idmax = $idmax ? {
    undef   => '',
    default => "--idmax=${idmax}",
  }
  $f_ext_ca_type = $ext_ca_type ? {
    undef   => '',
    default => "--external-ca-type=${ext_ca_type}",
  }
  $f_ext_cert_file = $ext_cert_file ? {
    undef   => '',
    default => "--external-cert-file=${ext_cert_file}",
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
  $f_ca_cert_file = $ca_cert_file ? {
    undef   => '',
    default => "--ca-cert-file=${ca_cert_file}",
  }
  $f_subject = $subject ? {
    undef   => '',
    default => "--subject=${subject}",
  }
  $f_ca_algorithm = $ca_algorithm ? {
    undef   => '',
    default => "--ca-signing-algorihtm=${ca_algorihtm}",
  }
  $f_forward_policy = $forward_policy ? {
    undef   => '',
    default => "--forward-policy=${forward_policy}",
  }
  $f_reverse_zone = $reverse_zone ? {
    undef   => '',
    default => "--reverse-zone=${reverse_zone}",
  }
  $f_zonemgr = $zonemgr ? {
    undef   => '',
    default => "--zonemgr=${zonemgr}",
  }
  if $forwarders != undef {
    $forward_prefix = prefix($forwarders,"--forwarder=")
    $f_forwarders = join($forward_prefix, " ")
  } else {
    $f_forwarders = ''
  }

  $b_opts = "${b_setup_dns} ${b_mkhomedir} ${b_no_host_dns} ${b_no_ntp} ${b_no_hbac_allow} ${b_ssh_trust_dns} ${b_no_ssh} ${b_no_sshd} ${b_external_ca} ${b_auto_forwarders} ${b_no_forwarders} ${b_no_reverse} ${b_auto_reverse}"
  $f_opts = "${f_ip} ${f_idstart} ${f_idmax} ${f_ext_ca_type} ${f_ext_cert_file} ${f_dirsrv_cert_file} ${f_dirsrv_pin} ${dirsrv_cert_name} ${f_http_cert_file} ${f_http_pin} ${f_http_cert_name} ${f_ca_cert_file} ${f_subject} ${f_ca_algorithm} ${f_forward_policy} ${f_reverse_zone} ${f_zonemgr} ${f_forwarders}"
  $opts = join($options, " ")

  #  notify{"/usr/sbin/ipa-server-install --hostname=${hostname} --realm=${realm} --domain=${domain} --admin-password='${adminpw}' --ds-password='${dmpw}' ${b_opts} ${f_opts} ${opts} --unattended":}

  exec { "serverinstall-${hostname}":
    command   => "/usr/sbin/ipa-server-install --hostname=${hostname} --realm=${realm} --domain=${domain} --admin-password='${adminpw}' --ds-password='${dmpw}' ${b_opts} ${f_opts} ${opts} --unattended",
    timeout   => '0',
    unless    => '/usr/sbin/ipactl status >/dev/null 2>&1',
    creates   => '/etc/ipa/default.conf',
    logoutput => 'on_failure',
    require   => File_line['remove hostname from localhost /etc/hosts'],
  }


}
