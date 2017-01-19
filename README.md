# check_apache_status
Plugin for Icinga, Nagios and Shinken to check the apache status.

If the apache status page accessable then this plugin checks for open slots, busy workers and idle workers.

Usage: check_apache_status.pl [OPTIONS]

 -?, --usage

   Print usage information

 -h, --help

   Print detailed help screen

 -V, --version

   Print version information

 --extra-opts=[section][@file]

   Read options from an ini file. See https://www.monitoring-plugins.org/doc/extra-opts.html
   for usage and examples.

 -H, --hostname=STRING

   hostname or ip address to check

 -p, --port=INTEGER

   port, default 80 (http) or 443 (https)

 -u, --uri=STRING

   uri, default /server-status

 -s, --ssl

   use https instead of http

 -N, --no\_validate

   do not validate the SSL certificate chain

 -w, --warning=STRING

   warning threshold

 -c, --critical=STRING

   critical threshold

 -t, --timeout=INTEGER

   Seconds before plugin times out (default: 15)

 -v, --verbose

   Show details for command-line debugging (can repeat up to 3 times)

Thresholds will be set comma seperated in the correct row, first for open slots followed by busy works and at last idle workers. Setting non for one of them is also possible, i.e.

./check_apache_status.pl -H localhost -w ,,10 -c ,,5
