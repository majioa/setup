%define     pkgname setup

Name:       ruby-%pkgname
Version:    5.2.0
Release:    alt1

Summary:    Ruby's Classic Site Installer
Group:      Development/Ruby
License:    BSD 2-clause Simplified License
Url:        https://github.com/rubyworks/setup
# VCS:      https://github.com/rubyworks/setup.git

Source:     %pkgname-%version.tar

BuildRequires(pre): rpm-build-ruby

%description
Every well practiced Rubyist is aware of Minero Aoki's ever setup.rb script.
It's how most of us used to install our Ruby programs before RubyGems came
along. And it's still mighty useful in certain scenarios, not the least of
which is the job of the distro package maintainer.

Ruby Setup converts setup.rb into a stand-alone application. No longer
requiring the distribution of the setup.rb script with every Ruby package.
Just instruct one's users to install Ruby Setup (gem install setup) and go from
there. As long as a project is setup.rb compliant, as most are, then there is
little to nothing it's developer must do.

%package doc
Summary: Documentation files for %name
Group: Documentation
BuildArch: noarch

%description doc 
Documentation files for %name.

%prep
%setup -n %pkgname-%version
%update_setup_rb

%build 
%ruby_config
%ruby_build
mv .gemspec %pkgname.gemspec

%install
%ruby_install
%rdoc lib/

%check
%ruby_test

%files
%doc README.rdoc HISTORY.rdoc MANIFEST
%_bindir/*
%ruby_sitelibdir/*
%rubygem_specdir/*

%files doc
%ruby_ri_sitedir/

%changelog
* Fri Jan 25 2019 Pavel Skrylev <majioa@altlinux.org> 5.2.0-alt1
- Initial gemified build for Sisyphus.
