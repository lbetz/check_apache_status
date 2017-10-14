# check_apache_status.pl

Plugin for Icinga, Nagios and Shinken to check the Apache httpd status.

If the Apache httpd status page is accessible then this plugin checks for following metrics:

- open slots
- busy workers
- idle workers
- requests per second
- bytes per second
- bytes per request



## Command Line Options

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

 -U, --username

  username for basic auth, requires password

 -P, password

  password for basic auth, requires username

 -u, --uri=STRING

   uri, default /server-status

 -s, --ssl

   use https instead of http

 -N, --no\_validate

   do not validate the SSL certificate chain

 -R, --unreachable

   CRITICAL if socket timed out or http code >= 500

 -w, --warning=STRING

   warning threshold

 -c, --critical=STRING

   critical threshold

 -t, --timeout=INTEGER

   Seconds before plugin times out (default: 15)

 -v, --verbose

   Show details for command-line debugging (can repeat up to 3 times)



## Threshold and ranges

A threshold is a [range](https://www.monitoring-plugins.org/doc/guidelines.html#THRESHOLDFORMAT) with an alert level (either WARNING or CRITICAL).
Thresholds will be set comma separated in the following order:

- open slots
- busy workers
- idle workers
- requests per second
- bytes per second
- bytes per request

A range is defined as a start and end point (inclusive) on a numeric scale (possibly negative or positive infinity).

This is the generalised format for ranges:

```[@]start:end```

### Notes

- start ≤ end
- start and ":" is not required if start=0
- if range is of format "start:" and end is not specified, assume end is infinity
- to specify negative infinity, use "~"
- alert is raised if metric is outside start and end range (inclusive of endpoints)
- if range starts with "@", then alert if inside this range (inclusive of endpoints)

### Examples


Setting non for one of them is also possible. The following example sets the threshold for _busy workers_ to WARNING for at least 10 _busy workers_ and CRITICAL to at least of 25 _busy workers_:

```check_apache_status.pl -H localhost -w ,10,,,, -c ,25,,,,```

To additionally set the threshold for _open_slots_ to WARNING when at or below 10 and CRITICAL when at or below 5:

```check_apache_status.pl -H localhost -w 10:,10,,,, -c 5:,25,,,,```
