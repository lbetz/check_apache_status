Steps to setup a local test environment on macOS


- Install plenv
  ```brew install plenv```
  ```brew install perl-build```

  Add this to ~/.bash_profile

  ```if which plenv > /dev/null; then eval "$(plenv init -)"; fi```

  Install plenv-contrib:

  ```git clone git://github.com/miyagawa/plenv-contrib.git ~/.plenv/plugins/plenv-contrib/´´´

- Install Perl 5.18.4
  ```plenv install 5.18.4```

- Install cpanm
  ```plenv install-cpanm```


- Install CPAN modules
  ```cpanm Monitoring::Plugin```
  ```cpanm LWP::UserAgent```
  ```cpanm HTTP::Status```



If you want to test against https:

```brew install openssl```
```cpanm Net::SSLeay```
```LWP::Protocol::https```
