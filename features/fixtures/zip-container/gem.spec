%define        gemname zip_container

Name:          gem-zip-container
Version:       4.0.2
Release:       alt1
Summary:       A Ruby library for working with ZIP Container Format files
License:       BSD
Group:         Development/Ruby
Url:           http://mygrid.github.io/ruby-zip-container/
Vcs:           https://github.com/mygrid/ruby-zip-container.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-build-ruby
BuildRequires: gem(rubyzip) >= 2.0.0 gem(rubyzip) < 2.1
BuildRequires: gem(bundler) >= 0
BuildRequires: gem(coveralls) >= 0.8 gem(coveralls) < 1
BuildRequires: gem(rake) >= 10.1 gem(rake) < 11
BuildRequires: gem(rdoc) >= 4.1 gem(rdoc) < 5
BuildRequires: gem(rubocop) >= 0.59 gem(rubocop) < 1
BuildRequires: gem(test-unit) >= 3.0 gem(test-unit) < 4

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
%ruby_alias_names zip_container,zip-container
Requires:      gem(rubyzip) >= 2.0.0 gem(rubyzip) < 2.1
Obsoletes:     ruby-zip-container < %EVR
Provides:      ruby-zip-container = %EVR
Provides:      gem(zip_container) = 4.0.2

%description
A Ruby library for working with ZIP Container Format files. See
http://www.idpf.org/epub/30/spec/epub30-ocf.html for the OCF specification and
https://learn.adobe.com/wiki/display/PDFNAV/Universal+Container+Format for the
UCF specification.


%package       -n gem-zip-container-doc
Version:       4.0.2
Release:       alt1
Summary:       A Ruby library for working with ZIP Container Format files documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета zip_container
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(zip_container) = 4.0.2

%description   -n gem-zip-container-doc
A Ruby library for working with ZIP Container Format files documentation
files.

A Ruby library for working with ZIP Container Format files. See
http://www.idpf.org/epub/30/spec/epub30-ocf.html for the OCF specification and
https://learn.adobe.com/wiki/display/PDFNAV/Universal+Container+Format for the
UCF specification.

%description   -n gem-zip-container-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета zip_container.


%package       -n gem-zip-container-devel
Version:       4.0.2
Release:       alt1
Summary:       A Ruby library for working with ZIP Container Format files development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета zip_container
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(zip_container) = 4.0.2
Requires:      gem(bundler) >= 0
Requires:      gem(coveralls) >= 0.8 gem(coveralls) < 1
Requires:      gem(rake) >= 10.1 gem(rake) < 11
Requires:      gem(rdoc) >= 4.1 gem(rdoc) < 5
Requires:      gem(rubocop) >= 0.59 gem(rubocop) < 1
Requires:      gem(test-unit) >= 3.0 gem(test-unit) < 4

%description   -n gem-zip-container-devel
A Ruby library for working with ZIP Container Format files development
package.

A Ruby library for working with ZIP Container Format files. See
http://www.idpf.org/epub/30/spec/epub30-ocf.html for the OCF specification and
https://learn.adobe.com/wiki/display/PDFNAV/Universal+Container+Format for the
UCF specification.

%description   -n gem-zip-container-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета zip_container.


%prep
%setup

%build
%ruby_build

%install
%ruby_install

%check
%ruby_test

%files
%doc ReadMe.rdoc
%ruby_gemspec
%ruby_gemlibdir

%files         -n gem-zip-container-doc
%doc ReadMe.rdoc
%ruby_gemdocdir

%files         -n gem-zip-container-devel
%doc ReadMe.rdoc


%changelog
* Wed Apr 21 2021 Pavel Skrylev <majioa@altlinux.org> 4.0.2-alt1
- ^ 3.0.2 -> 4.0.2

* Wed Sep 05 2018 Andrey Cherepanov <cas@altlinux.org> 3.0.2-alt1
- New version.

* Wed Jul 11 2018 Andrey Cherepanov <cas@altlinux.org> 3.0.1-alt1.1
- Rebuild with new Ruby autorequirements.

* Tue Feb 17 2015 Andrey Cherepanov <cas@altlinux.org> 3.0.1-alt1
- Initial build for ALT Linux (without tests)
