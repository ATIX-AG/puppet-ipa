class freeipa::clientinstall(
  String $domain         = undef,
  String $realm          = undef,
  $principal             = undef,
  String $password       = undef,
  String $hostname       = undef,
  String $server         = undef,
  $keytab                = undef,
  $ntpserver             = undef,
  $nisdomain             = undef,
  $ca_cert_file          = undef,
  $ip                    = undef,
  Array $options         = [],
  Boolean $no_ntp        = true,
  Boolean $mkhomedir     = false,
  Boolean $force         = false,
  Boolean $no_ssh        = false,
  Boolean $no_sshd       = false,
  Boolean $fixed_primary = false,
  Boolean $no_nisdomain  = false,
  Boolean $ssh_trust_dns = false,
  Boolean $force_join    = false,
  Boolean $force_ntp     = false,
  Boolean $no_sudo       = false,
  Boolean $no_dns_sshfp  = false,
  Boolean $noac          = false,
  Boolean $request_cert  = false,
  Boolean $no_sssd       = false,
){

  package{'ipa-client':
    ensure => installed,
  }

  file_line{'remove hostname from localhost /etc/hosts':
    ensure            => absent,
    path              => '/etc/hosts',
    line              => "#127.0.0.1 ${hostname}",
    match             => "^127.0.0.1.*${hostname}.*",
    match_for_absence => true,
  }

  $b_no_ntp = $no_ntp ? {
    true    => '--no-ntp',
    default => '',
  }
  $b_mkhomedir = $mkhomedir ? {
    true    => '--mkhomedir',
    default => '',
  }
  $b_force = $force ? {
    true    => '--force',
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
  $b_fixed_primary = $fixed_primary ? {
    true    => 'no-fixed-primary',
    default =>  '',
  }
  $b_no_nisdomain = $no_nisdomain ? {
    true    => '--no-nisdomain',
    default => '',
  }
  $b_ssh_trust_dns = $ssh_trust_dns ? {
    true    => '--ssh-trust-dns',
    default => '',
  }
  $b_force_join = $force_join ? {
    true    => '--force-join',
    default => '',
  }
  $b_force_ntp = $force_ntp ? {
    true    => '--force-ntp',
    default => '',
  }
  $b_no_sudo = $no_sudo ? {
    true    => '--no-sudo',
    default => '',
  }
  $b_noac = $noac ? {
    true    => '--noac',
    default => '',
  }
  $b_request_cert = $request_cert ? {
    true    => '--request-cert',
    default => '',
  }
  $b_no_sssd = $no_sssd ? {
    true    => '--no-sssd',
    default => '',
  }

  $f_keytab = $keytab ? {
    undef   => '',
    default => "--keytab=${keytab}",
  }
  $f_ntpserver = $ntpserver ? {
    undef   => '',
    default => "--ntp-server=${ntpserver}",
  }
  $f_nisdomain = $nisdomain ? {
    undef   => '',
    default => "--nisdomain=${nisdomain}",
  }
  $f_ca_cert = $ca_cert_file ? {
    undef   => '',
    default => "--ca-cert-file=${ca_cert_file}",
  }
  $f_ip = $ip ? {
    undef   => '',
    default => "--ip-address=${ip}",
  }

  if $principal != undef {
    $f_princ = "--principal=${principal}"
  } else {
    $f_princ = ''
  }

  $optstring = join($options, ' ')
  $opts = "${optstring} ${f_keytab} ${f_ntp_server} ${f_nisdomain} ${f_ca_cert} ${f_ip} ${b_no_ssh} ${b_force} ${b_mkhomedir} ${b_no_ntp} ${b_no_ssh} ${b_no_sshd} ${b_fixed_primary} ${b_no_nisdomain} ${b_ssh_trust_dns} ${b_force_join} ${b_force_ntp} ${b_no_sudo} ${b_noac} ${b_request_cert} ${b_no_sssd}"

  #  notify{"ipa-client-install --server=${server} --hostname=${hostname} --realm=${realm} --domain=${domain} ${f_princ} --password='${password}' ${opts} --unattended":}

  exec { "client install-${hostname}":
    command   => "/usr/sbin/ipa-client-install --server=${server} --hostname=${hostname} --realm=${realm} --domain=${domain} ${f_princ} --password='${password}' ${opts} --unattended",
    timeout   => '0',
    creates   => '/etc/ipa/default.conf',
    logoutput => 'on_failure',
    require   => File_line['remove hostname from localhost /etc/hosts'],
  }


}
