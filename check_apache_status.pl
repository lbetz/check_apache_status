#!/usr/bin/perl

use Monitoring::Plugin;
use Monitoring::Plugin::Getopt;
use Monitoring::Plugin::Threshold;
use LWP::UserAgent;
use HTTP::Status qw(:constants :is status_message);

our $VERSION = '1.4.2';

our ( $plugin, $option );

$plugin = Monitoring::Plugin->new( shortname => '' );


$options = Monitoring::Plugin::Getopt->new(
  usage   => 'Usage: %s [OPTIONS]',
  version => $VERSION,
  url     => 'https://github.com/lbetz/check_apache_status',
  blurb   => 'Check apache server status',
);

$options->arg(
  spec     => 'hostname|H=s',
  help     => 'hostname or ip address to check',
  required => 1,
);

$options->arg(
  spec     => 'port|p=i',
  help     => 'port, default 80 (http) or 443 (https)',
  required => 0,
);

$options->arg(
  spec     => 'uri|u=s',
  help     => 'uri, default /server-status',
  required => 0,
  default => '/server-status',
);

$options->arg(
  spec     => 'username|U=s',
  help     => 'username for basic auth',
  required => 0,
);

$options->arg(
  spec     => 'password|P=s',
  help     => 'password for basic auth',
  required => 0,
);

$options->arg(
  spec     => 'ssl|s',
  help     => 'use https instead of http',
  required => 0,
);

$options->arg(
  spec     => 'no_validate|N',
  help     => 'do not validate the SSL certificate chain',
  required => 0,
);

$options->arg(
  spec     => 'warning|w=s',
  help     => 'warning threshold',
  required => 0,
);

$options->arg(
  spec     => 'critical|c=s',
  help     => 'critical threshold',
  required => 0,
);

$options->arg(
  spec     => 'unreachable|R',
  help     => 'CRITICAL if socket timed out or http code >= 500',
  required => 0,
);

$options->getopts();

# if socket timed out or http code >= 500
my $unreachable = 'UNKNOWN';
if (defined($options->unreachable)) {
  $unreachable = 'CRITICAL';
}

alarm $options->timeout;
# override default alarm handler
$SIG{ALRM} = sub {
  $plugin->die(
    sprintf("plugin timed out (timeout %ss)",
      $options->timeout), $unreachable);
};


my @warning = split(",", $options->warning);
my @critical = split(",", $options->critical);

$threshold_OpenSlots = Monitoring::Plugin::Threshold->set_thresholds(
  warning  => $warning[0],
  critical => $critical[0],
);
$threshold_BusyWorkers = Monitoring::Plugin::Threshold->set_thresholds(
  warning  => $warning[1],
  critical => $critical[1],
);
$threshold_IdleWorkers = Monitoring::Plugin::Threshold->set_thresholds(
  warning  => $warning[2],
  critical => $critical[2],
);
$threshold_ReqPerSec = Monitoring::Plugin::Threshold->set_thresholds(
  warning  => $warning[3],
  critical => $critical[3],
);
$threshold_BytesPerSec = Monitoring::Plugin::Threshold->set_thresholds(
  warning  => $warning[4],
  critical => $critical[4],
);
$threshold_BytesPerReq = Monitoring::Plugin::Threshold->set_thresholds(
  warning  => $warning[5],
  critical => $critical[5],
);

## Username without password
$plugin->nagios_exit( UNKNOWN, 'If you specify an username, you have to set a password too!') if ( ($options->username  ne '') && ($options->password eq '') );

## Password without username
$plugin->nagios_exit( UNKNOWN, 'If you specify a password, you have to set an username too!') if ( ($options->username  eq '') && ($options->password ne '') );

## Set account
if ( ($options->username ne '') && ($options->password ne '') ) {
  $account = $options->username.':'.$options->password.'@';
}

my $ua = LWP::UserAgent->new( protocols_allowed => ['http','https'], timeout => 15);
$ua->ssl_opts ( SSL_cipher_list => '' );

if (defined($options->no_validate)) {
  $ua->ssl_opts ( verify_hostname => 0 );
  $ua->ssl_opts ( SSL_verify_mode => 0 );
}

if (defined($options->ssl)) {
  $proto = 'https://';
} else {
  $proto = "http://";
}

if (defined($options->port)) {
  $request = HTTP::Request->new(GET => $proto.$account.$options->hostname.':'.$options->port.$options->uri.'?auto');
} else {
  $request = HTTP::Request->new(GET => $proto.$account.$options->hostname.$options->uri.'?auto');
}

$response = $ua->request($request);

if ($response->is_success) {

  unless ($response->content =~ /(?s).*ReqPerSec:\s([0-9\.]+).*BytesPerSec:\s([0-9\.]+).*BusyWorkers:\s([0-9]+).*IdleWorkers:\s([0-9]+).*Scoreboard:\s(.*)/) {
    $plugin->plugin_exit( UNKNOWN, "No status information found at ".$response->base );
  }

  $ReqPerSec = $1;
  $BytesPerSec = $2;
  $BusyWorkers = $3;
  $IdleWorkers = $4;
  $OpenSlots   = ($5 =~ tr/[._]//);

  $response->content =~ /(?s).*BytesPerReq:\s([0-9\.]+)/;
  $BytesPerReq = $1;
  unless ($BytesPerReq) {
    $BytesPerReq = 0;
  }

  $output = 'OpenSlots:'.$OpenSlots.' BusyWorkers:'.$BusyWorkers.' IdleWorkers:'.$IdleWorkers.
    ' ReqPerSec:'.$ReqPerSec.' BytesPerSec:'.$BytesPerSec.' BytesPerReq:'.$BytesPerReq;

  $plugin->add_perfdata(
    label => 'OpenSlots',
    value => $OpenSlots,
    uom   => q{},
    threshold => $threshold_OpenSlots,
  );

  $plugin->add_perfdata(
    label => 'BusyWorkers',
    value => $BusyWorkers,
    uom   => q{},
    threshold => $threshold_BusyWorkers,
  );

  $plugin->add_perfdata(
    label => 'IdleWorkers',
    value => $IdleWorkers,
    uom   => q{},
    threshold => $threshold_IdleWorkers,
  );

  $plugin->add_perfdata(
    label => 'ReqPerSec',
    value => $ReqPerSec,
    uom   => q{},
    threshold => $threshold_ReqPerSec,
  );

  $plugin->add_perfdata(
    label => 'BytesPerSec',
    value => $BytesPerSec,
    uom   => B,
    threshold => $threshold_BytesPerSec,
  );

  $plugin->add_perfdata(
    label => 'BytesPerReq',
    value => $BytesPerReq,
    uom   => B,
    threshold => $threshold_BytesPerReq,
  );


  my @thresholds = (
    $threshold_OpenSlots->get_status($OpenSlots),
    $threshold_BusyWorkers->get_status($BusyWorkers),
    $threshold_IdleWorkers->get_status($IdleWorkers),
    $threshold_ReqPerSec->get_status($ReqPerSec),
    $threshold_BytesPerSec->get_status($BytesPerSec),
    $threshold_BytesPerReq->get_status($BytesPerReq)
  );

  my $status = 0;
  foreach(@thresholds) {
    if ($_ > $status) {
      $status = $_;
    }
  }

  $plugin->nagios_exit( $status, $output );

} elsif ( $response->code >= HTTP_INTERNAL_SERVER_ERROR ) {
  $plugin->plugin_exit( $unreachable, $response->status_line );
} else {
  $plugin->plugin_exit( UNKNOWN, $response->status_line );
}
