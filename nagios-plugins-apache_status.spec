# spec file for package check_apache_status.pl

%define lname	check_apache_status

Name:          nagios-plugins-apache_status
Summary:       Nagios Plugins - check_apache_status.pl
Version:       1.4.3
Url:           http://github.com/lbetz/check_apache_status
License:       GPL-2.0+
Group:         System/Monitoring
Source0:       %{lname}-%{version}.tar.gz
Provides:      nagios-plugins-apache_status = %{version}-%{release}
Obsoletes:     nagios-plugins-apache_status < %{version}-%{release}
Requires:      perl(Monitoring::Plugin)
Requires:      perl(LWP::UserAgent)
Requires:      perl(Data::Dumper)

%if 0%{?suse}
Release:       1
BuildRequires: nagios-rpm-macros
BuildRoot:     %{_tmppath}/%{name}-%{version}-build
%endif

%if 0%{?fedora} || 0%{?rhel} || 0%{?centos}
Release:       1%{?dist}
Requires:      nagios-common
%endif

%if 0%{?fedora} >= 16 || 0%{?rhel} >= 7 || 0%{?centos} >= 7
Requires:      perl(LWP::Protocol::https)
%endif

%description
Checks against the apache status site.

%prep
%setup -q -n %{lname}-%{version}

%install
%{__mkdir_p} %{buildroot}/%{_libdir}/nagios/plugins
%{__install} -m755 check_apache_status.pl %{buildroot}/%{_libdir}/nagios/plugins/

%clean
rm -rf %buildroot

%files -n nagios-plugins-apache_status
%defattr(-,root,root)
# avoid build dependecy of nagios - own the dirs
%if 0%{?suse_version}
%dir %{_libdir}/nagios
%dir %{_libdir}/nagios/plugins
%endif
%{_libdir}/nagios/plugins/check_apache_status.pl

%changelog
* Fri Apr 14 2023 Lennart Betz <lennart.betz@netways.de> 1.4.3-1
- Bugfix release version 1.4.3
- fix #13 Extend status?auto to get the whole Scoreboard
* Mon Apr 20 2020 Lennart Betz <lennart.betz@netways.de> 1.4.2-1
- Bugfix release version 1.4.2
- fix #12 fix for SSLv3 errors
* Sun Nov 19 2017 Lennart Betz <lennart.betz@netways.de> 1.4.1-1
- Bugfix release version 1.4.1
- fix #9 detect idle waits
* Thu Oct 12 2017 Yves Vogl <yves.vogl@dock42.com> 1.4.0-1
- feature version 1.4.0
- feature: added requests per second, bytes per second, bytes per request as metrics
- feature: Improved error handling and documentation
* Tue May 06 2017 Lennart Betz <lennart.betz@netways.de> 1.3.0-1
- feature version 1.3.0
- feature add option unreacheable
* Fri Feb 17 2017 Lennart Betz <lennart.betz@netways.de> 1.2.0-1
- feature version 1.2.0
- feature add option no_validate
- fix projekt website url in spec
* Thu Jan 19 2017 Lennart Betz <lennart.betz@netways.de> 1.1.0-1
- feature version 1.1.0
- LWP::Protocol::https is required on redhat
* Mon Apr 29 2016 Lennart Betz <lennart.betz@netways.de> 1.0.0-1
- initial setup
