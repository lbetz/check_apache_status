#!/usr/bin/perl

use Monitoring::Plugin;
use Monitoring::Plugin::Getopt;
use Monitoring::Plugin::Threshold;
use LWP::UserAgent;
use Data::Dumper;

our $VERSION = '1.0.1';

our ( $plugin, $option );

$plugin = Monitoring::Plugin->new( shortname => '' );


$options = Monitoring::Plugin::Getopt->new(
  usage   => 'Usage: %s [OPTIONS]',
  version => $VERSION,
  url     => 'https://github.com/lbetz/nagios-plugins',
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
  spec     => 'ssl|s+',
  help     => 'use https instead of http',
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

$options->getopts();
alarm $options->timeout;

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

my $ua = LWP::UserAgent->new( protocols_allowed => ['http','https'], timeout => 15);

if (defined($options->ssl)) {
  $proto = 'https://';
} else {
  $proto = "http://";
}

if (defined($options->port)) {
  $request = HTTP::Request->new(GET => $proto.$options->hostname.':'.$options->port.$options->uri.'/?auto');
} else {
  $request = HTTP::Request->new(GET => $proto.$options->hostname.$options->uri.'/?auto');
}

$response = $ua->request($request);

if ($response->is_success) {
  $response->content =~ /(?s).*BusyWorkers:\s([0-9]+).*IdleWorkers:\s([0-9]+).*Scoreboard:\s(.*)$/;

  $BusyWorkers = $1;
  $IdleWorkers = $2;
  $OpenSlots   = ($3 =~ tr/\.//);

  $output = 'OpenSlots:'.$OpenSlots.' BusyWorkers:'.$BusyWorkers.' IdleWorkers:'.$IdleWorkers;

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

  my @thresholds = (
    $threshold_OpenSlots->get_status($OpenSlots),
    $threshold_BusyWorkers->get_status($BusyWorkers),
    $threshold_IdleWorkers->get_status($IdleWorkers)
  );

  my $status = 0;
  foreach(@thresholds) {
    if ($_ > $status) {
      $status = $_;
    }
  }

  $plugin->nagios_exit( $status, $output );

} else {

  $plugin->plugin_exit( UNKNOWN, $response->headers->title );

}
