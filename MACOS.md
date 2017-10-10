Steps to setup a local test environment on macOS


- Install plenv
  ```brew install plenv```
  ```brew install perl-build```

  Add this to ~/.bash_profile

  ```if which plenv > /dev/null; then eval "$(plenv init -)"; fi```


- Install Perl 5.18.4
  ```plenv install 5.18.4```

- Install cpanm
  ```plenv install-cpanm```


- Install CPAN modules
  ```cpanm Monitoring::Plugin```
  ```cpanm LWP::UserAgent```
  ```cpanm HTTP::Status```
