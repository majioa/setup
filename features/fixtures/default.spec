Name:          rpm
Epoch:         1
Version:       5.2
Release:       rc1
Summary:       
License:       MIT
Group:         Group
Url:           https://uri.domain
Vcs:           https://vcs.domain

Source:        source_file.tar
Source1:        source_file1.tar
Patch:         patch.patch
Patch1:         patch1.patch
BuildRequires(pre): req >= 1
BuildRequires(pre): req_new < 0.1
BuildRequires(pre): req_newline >= 2
BuildRequires: req >= 1
BuildRequires: req_new < 0.1
BuildRequires: req_newline >= 2

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:            req >= 1
Requires:            req_new < 0.1
Requires:            req_newline >= 2
Obsoletes:           req >= 1
Obsoletes:           req_new < 0.1
Obsoletes:           req_newline >= 2
Provides:            req >= 1
Provides:            req_new < 0.1
Provides:            req_newline >= 2
Conflicts:           req >= 1
Conflicts:           req_new < 0.1
Conflicts:           req_newline >= 2

%description
RPM desc
%description         -l ru_RU.UTF8
Заметка




%package       -n sub
Version:       20210413
Group:         Development/Ruby


%package       -n sub-doc
Summary:       Documentation files for sub gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета sub
Group:         Development/Documentation
BuildArch:     noarch

%description   -n sub-doc
Documentation files for sub gem.

%description   -n sub-doc -l ru_RU.UTF8
Файлы сведений для самоцвета sub.


%package       -n gem-foo-boo
Version:       5.2
Summary:       Foo Boo gem summary
Group:         Development/Ruby

%description   -n gem-foo-boo
Foo Boo gem


%package       -n foo
Summary:       Executable file for foo_boo gem
Summary(ru_RU.UTF-8): Исполнямка для самоцвета foo_boo
Group:         Development/Ruby
BuildArch:     noarch

%description   -n foo
Executable file for foo_boo gem.

%description   -n foo -l ru_RU.UTF8
Исполнямка для foo_boo самоцвета.


%package       -n gem-foo-boo-doc
Summary:       Documentation files for foo_boo gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета foo_boo
Group:         Development/Documentation
BuildArch:     noarch

%description   -n gem-foo-boo-doc
Documentation files for foo_boo gem.

%description   -n gem-foo-boo-doc -l ru_RU.UTF8
Файлы сведений для самоцвета foo_boo.


%package       -n gem-foo-boo-devel
Summary:       Development files for foo_boo gem
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(b_oofoo) = 5.2.4.4

%description   -n gem-foo-boo-devel
Development files for foo_boo gem.

%description   -n gem-foo-boo-devel -l ru_RU.UTF8
Файлы заголовков для самоцвета foo_boo.


%package       -n gem-foo-boo-ext
Version:       1.1.7
Summary:       Foo boo Ext gem.
Group:         Development/Ruby

%description   -n gem-foo-boo-ext
Foo boo Ext gem desc


%package       -n gem-foo-boo-ext-doc
Summary:       Documentation files for foo_boo_ext gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета foo_boo_ext
Group:         Development/Documentation
BuildArch:     noarch

%description   -n gem-foo-boo-ext-doc
Documentation files for foo_boo_ext gem.

%description   -n gem-foo-boo-ext-doc -l ru_RU.UTF8
Файлы сведений для самоцвета foo_boo_ext.


%package       -n gem-foo-boo-ext-devel
Summary:       Development files for foo_boo_ext gem
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(foo_boo) = 5.2
Requires:      gem(b_oofoo_dev) >= 5.2.4

%description   -n gem-foo-boo-ext-devel
Development files for foo_boo_ext gem.

%description   -n gem-foo-boo-ext-devel -l ru_RU.UTF8
Файлы заголовков для самоцвета foo_boo_ext.


%package       -n gem-railties
Version:       5.2.4.4
Summary:       Tools for creating, working with, and running Rails applications.
Group:         Development/Ruby

%description   -n gem-railties
Rails internals: application bootup, plugins, generators, and rake tasks.


%package       -n rails
Summary:       Executable file for railties gem
Summary(ru_RU.UTF-8): Исполнямка для самоцвета railties
Group:         Development/Ruby
BuildArch:     noarch

%description   -n rails
Executable file for railties gem.

%description   -n rails -l ru_RU.UTF8
Исполнямка для railties самоцвета.


%package       -n gem-railties-doc
Summary:       Documentation files for railties gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета railties
Group:         Development/Documentation
BuildArch:     noarch

%description   -n gem-railties-doc
Documentation files for railties gem.

%description   -n gem-railties-doc -l ru_RU.UTF8
Файлы сведений для самоцвета railties.


%package       -n gem-railties-devel
Summary:       Development files for railties gem
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(activesupport) = 5.2.4.4
Requires:      gem(actionpack) = 5.2.4.4
Requires:      gem(rake) >= 0.8.7
Requires:      gem(thor) >= 0.19.0
Requires:      gem(thor) < 2.0
Requires:      gem(method_source) >= 0
Requires:      gem(actionview) = 5.2.4.4

%description   -n gem-railties-devel
Development files for railties gem.

%description   -n gem-railties-devel -l ru_RU.UTF8
Файлы заголовков для самоцвета railties.


%package       -n gem-rails
Version:       5.2.4.4
Summary:       Full-stack web application framework.
Group:         Development/Ruby

%description   -n gem-rails
Ruby on Rails is a full-stack web framework optimized for programmer happiness
and sustainable productivity. It encourages beautiful code by favoring
convention over configuration.


%package       -n gem-rails-doc
Summary:       Documentation files for rails gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета rails
Group:         Development/Documentation
BuildArch:     noarch

%description   -n gem-rails-doc
Documentation files for rails gem.

%description   -n gem-rails-doc -l ru_RU.UTF8
Файлы сведений для самоцвета rails.


%package       -n gem-rails-devel
Summary:       Development files for rails gem
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(activesupport) = 5.2.4.4
Requires:      gem(actionpack) = 5.2.4.4
Requires:      gem(actionview) = 5.2.4.4
Requires:      gem(activemodel) = 5.2.4.4
Requires:      gem(activerecord) = 5.2.4.4
Requires:      gem(actionmailer) = 5.2.4.4
Requires:      gem(activejob) = 5.2.4.4
Requires:      gem(actioncable) = 5.2.4.4
Requires:      gem(activestorage) = 5.2.4.4
Requires:      gem(railties) = 5.2.4.4
Requires:      gem(bundler) >= 1.3.0
Requires:      gem(sprockets-rails) >= 2.0.0

%description   -n gem-rails-devel
Development files for rails gem.

%description   -n gem-rails-devel -l ru_RU.UTF8
Файлы заголовков для самоцвета rails.


%package       -n gem-activesupport
Version:       5.2.4.4
Summary:       A toolkit of support libraries and Ruby core extensions extracted from the Rails framework.
Group:         Development/Ruby

%description   -n gem-activesupport
A toolkit of support libraries and Ruby core extensions extracted from the Rails
framework. Rich support for multibyte strings, internationalization, time zones,
and testing.


%package       -n gem-activesupport-doc
Summary:       Documentation files for activesupport gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета activesupport
Group:         Development/Documentation
BuildArch:     noarch

%description   -n gem-activesupport-doc
Documentation files for activesupport gem.

%description   -n gem-activesupport-doc -l ru_RU.UTF8
Файлы сведений для самоцвета activesupport.


%package       -n gem-activesupport-devel
Summary:       Development files for activesupport gem
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(i18n) >= 0.7
Requires:      gem(i18n) < 2
Requires:      gem(tzinfo) >= 1.1
Requires:      gem(tzinfo) < 2
Requires:      gem(minitest) >= 5.1
Requires:      gem(minitest) < 6
Requires:      gem(concurrent-ruby) >= 1.0.2
Requires:      gem(concurrent-ruby) < 2

%description   -n gem-activesupport-devel
Development files for activesupport gem.

%description   -n gem-activesupport-devel -l ru_RU.UTF8
Файлы заголовков для самоцвета activesupport.


%package       -n gem-activestorage
Version:       5.2.4.4
Summary:       Local and cloud file storage framework.
Group:         Development/Ruby

%description   -n gem-activestorage
Attach cloud and local files in Rails applications.


%package       -n gem-activestorage-doc
Summary:       Documentation files for activestorage gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета activestorage
Group:         Development/Documentation
BuildArch:     noarch

%description   -n gem-activestorage-doc
Documentation files for activestorage gem.

%description   -n gem-activestorage-doc -l ru_RU.UTF8
Файлы сведений для самоцвета activestorage.


%package       -n gem-activestorage-devel
Summary:       Development files for activestorage gem
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(actionpack) = 5.2.4.4
Requires:      gem(activerecord) = 5.2.4.4
Requires:      gem(marcel) >= 0.3.1
Requires:      gem(marcel) < 0.4

%description   -n gem-activestorage-devel
Development files for activestorage gem.

%description   -n gem-activestorage-devel -l ru_RU.UTF8
Файлы заголовков для самоцвета activestorage.


%package       -n gem-activerecord
Version:       5.2.4.4
Summary:       Object-relational mapper framework (part of Rails).
Group:         Development/Ruby

%description   -n gem-activerecord
Databases on Rails. Build a persistent domain model by mapping database tables
to Ruby classes. Strong conventions for associations, validations, aggregations,
migrations, and testing come baked-in.


%package       -n gem-activerecord-doc
Summary:       Documentation files for activerecord gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета activerecord
Group:         Development/Documentation
BuildArch:     noarch

%description   -n gem-activerecord-doc
Documentation files for activerecord gem.

%description   -n gem-activerecord-doc -l ru_RU.UTF8
Файлы сведений для самоцвета activerecord.


%package       -n gem-activerecord-devel
Summary:       Development files for activerecord gem
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(activesupport) = 5.2.4.4
Requires:      gem(activemodel) = 5.2.4.4
Requires:      gem(arel) >= 9.0

%description   -n gem-activerecord-devel
Development files for activerecord gem.

%description   -n gem-activerecord-devel -l ru_RU.UTF8
Файлы заголовков для самоцвета activerecord.


%package       -n gem-activemodel
Version:       5.2.4.4
Summary:       A toolkit for building modeling frameworks (part of Rails).
Group:         Development/Ruby

%description   -n gem-activemodel
A toolkit for building modeling frameworks like Active Record. Rich support for
attributes, callbacks, validations, serialization, internationalization, and
testing.


%package       -n gem-activemodel-doc
Summary:       Documentation files for activemodel gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета activemodel
Group:         Development/Documentation
BuildArch:     noarch

%description   -n gem-activemodel-doc
Documentation files for activemodel gem.

%description   -n gem-activemodel-doc -l ru_RU.UTF8
Файлы сведений для самоцвета activemodel.


%package       -n gem-activemodel-devel
Summary:       Development files for activemodel gem
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(activesupport) = 5.2.4.4

%description   -n gem-activemodel-devel
Development files for activemodel gem.

%description   -n gem-activemodel-devel -l ru_RU.UTF8
Файлы заголовков для самоцвета activemodel.


%package       -n gem-activejob
Version:       5.2.4.4
Summary:       Job framework with pluggable queues.
Group:         Development/Ruby

%description   -n gem-activejob
Declare job classes that can be run by a variety of queueing backends.


%package       -n gem-activejob-doc
Summary:       Documentation files for activejob gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета activejob
Group:         Development/Documentation
BuildArch:     noarch

%description   -n gem-activejob-doc
Documentation files for activejob gem.

%description   -n gem-activejob-doc -l ru_RU.UTF8
Файлы сведений для самоцвета activejob.


%package       -n gem-activejob-devel
Summary:       Development files for activejob gem
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(activesupport) = 5.2.4.4
Requires:      gem(globalid) >= 0.3.6

%description   -n gem-activejob-devel
Development files for activejob gem.

%description   -n gem-activejob-devel -l ru_RU.UTF8
Файлы заголовков для самоцвета activejob.


%package       -n gem-actionview
Version:       5.2.4.4
Summary:       Rendering framework putting the V in MVC (part of Rails).
Group:         Development/Ruby

%description   -n gem-actionview
Simple, battle-tested conventions and helpers for building web pages.


%package       -n gem-actionview-doc
Summary:       Documentation files for actionview gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета actionview
Group:         Development/Documentation
BuildArch:     noarch

%description   -n gem-actionview-doc
Documentation files for actionview gem.

%description   -n gem-actionview-doc -l ru_RU.UTF8
Файлы сведений для самоцвета actionview.


%package       -n gem-actionview-devel
Summary:       Development files for actionview gem
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(activesupport) = 5.2.4.4
Requires:      gem(builder) >= 3.1
Requires:      gem(builder) < 4
Requires:      gem(erubi) >= 1.4
Requires:      gem(erubi) < 2
Requires:      gem(rails-html-sanitizer) >= 1.0.3
Requires:      gem(rails-html-sanitizer) < 2
Requires:      gem(rails-dom-testing) >= 2.0
Requires:      gem(rails-dom-testing) < 3
Requires:      gem(actionpack) = 5.2.4.4
Requires:      gem(activemodel) = 5.2.4.4

%description   -n gem-actionview-devel
Development files for actionview gem.

%description   -n gem-actionview-devel -l ru_RU.UTF8
Файлы заголовков для самоцвета actionview.


%package       -n gem-actionpack
Version:       5.2.4.4
Summary:       Web-flow and rendering framework putting the VC in MVC (part of Rails).
Group:         Development/Ruby

%description   -n gem-actionpack
Web apps on Rails. Simple, battle-tested conventions for building and testing
MVC web applications. Works with any Rack-compatible server.


%package       -n gem-actionpack-doc
Summary:       Documentation files for actionpack gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета actionpack
Group:         Development/Documentation
BuildArch:     noarch

%description   -n gem-actionpack-doc
Documentation files for actionpack gem.

%description   -n gem-actionpack-doc -l ru_RU.UTF8
Файлы сведений для самоцвета actionpack.


%package       -n gem-actionpack-devel
Summary:       Development files for actionpack gem
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(activesupport) = 5.2.4.4
Requires:      gem(rack) >= 2.0.8
Requires:      gem(rack) < 3
Requires:      gem(rack-test) >= 0.6.3
Requires:      gem(rails-html-sanitizer) >= 1.0.2
Requires:      gem(rails-html-sanitizer) < 2
Requires:      gem(rails-dom-testing) >= 2.0
Requires:      gem(rails-dom-testing) < 3
Requires:      gem(actionview) = 5.2.4.4
Requires:      gem(activemodel) = 5.2.4.4

%description   -n gem-actionpack-devel
Development files for actionpack gem.

%description   -n gem-actionpack-devel -l ru_RU.UTF8
Файлы заголовков для самоцвета actionpack.


%package       -n gem-actionmailer
Version:       5.2.4.4
Summary:       Email composition, delivery, and receiving framework (part of Rails).
Group:         Development/Ruby

%description   -n gem-actionmailer
Email on Rails. Compose, deliver, receive, and test emails using the familiar
controller/view pattern. First-class support for multipart email and
attachments.


%package       -n gem-actionmailer-doc
Summary:       Documentation files for actionmailer gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета actionmailer
Group:         Development/Documentation
BuildArch:     noarch

%description   -n gem-actionmailer-doc
Documentation files for actionmailer gem.

%description   -n gem-actionmailer-doc -l ru_RU.UTF8
Файлы сведений для самоцвета actionmailer.


%package       -n gem-actionmailer-devel
Summary:       Development files for actionmailer gem
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(actionpack) = 5.2.4.4
Requires:      gem(actionview) = 5.2.4.4
Requires:      gem(activejob) = 5.2.4.4
Requires:      gem(mail) >= 2.5.4
Requires:      gem(mail) < 3
Requires:      gem(rails-dom-testing) >= 2.0
Requires:      gem(rails-dom-testing) < 3

%description   -n gem-actionmailer-devel
Development files for actionmailer gem.

%description   -n gem-actionmailer-devel -l ru_RU.UTF8
Файлы заголовков для самоцвета actionmailer.


%package       -n gem-actioncable
Version:       5.2.4.4
Summary:       WebSocket framework for Rails.
Group:         Development/Ruby

%description   -n gem-actioncable
Structure many real-time application concerns into channels over a single
WebSocket connection.


%package       -n gem-actioncable-doc
Summary:       Documentation files for actioncable gem
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета actioncable
Group:         Development/Documentation
BuildArch:     noarch

%description   -n gem-actioncable-doc
Documentation files for actioncable gem.

%description   -n gem-actioncable-doc -l ru_RU.UTF8
Файлы сведений для самоцвета actioncable.


%package       -n gem-actioncable-devel
Summary:       Development files for actioncable gem
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(actionpack) = 5.2.4.4
Requires:      gem(nio4r) >= 2.0
Requires:      gem(nio4r) < 3
Requires:      gem(websocket-driver) >= 0.6.1

%description   -n gem-actioncable-devel
Development files for actioncable gem.

%description   -n gem-actioncable-devel -l ru_RU.UTF8
Файлы заголовков для самоцвета actioncable.


%prep
%setup

%build
%ruby_build

%install
%ruby_install

%check
%ruby_test

%files
%ruby_gemspec
%ruby_gemlibdir

%doc 
%ruby_gemspecdir/sub-20210413.gemspec
%ruby_gemslibdir/sub-20210413
%files         -n sub-doc
%ruby_gemsdocdir/sub-20210413


%files         -n gem-foo-boo
%doc readme.md
%ruby_gemspecdir/foo_boo-5.2.gemspec
%ruby_gemslibdir/foo_boo-5.2
%files         -n foo
%_bindir/foo

%files         -n gem-foo-boo-doc
%ruby_gemsdocdir/foo_boo-5.2

%files         -n gem-foo-boo-devel

%files         -n gem-foo-boo-ext
%doc README.md
%ruby_gemspecdir/foo_boo_ext-1.1.7.gemspec
%ruby_gemslibdir/foo_boo_ext-1.1.7
%ruby_gemsextdir/foo_boo_ext-1.1.7

%files         -n gem-foo-boo-ext-doc
%ruby_gemsdocdir/foo_boo_ext-1.1.7

%files         -n gem-foo-boo-ext-devel
%ruby_includedir/*

%files         -n gem-railties
%doc README.rdoc lib/rails/generators/rails/app/templates/README.md.tt lib/rails/generators/rails/plugin/templates/README.md.tt
%ruby_gemspecdir/railties-5.2.4.4.gemspec
%ruby_gemslibdir/railties-5.2.4.4
%files         -n rails
%_bindir/rails

%files         -n gem-railties-doc
%ruby_gemsdocdir/railties-5.2.4.4

%files         -n gem-railties-devel
%ruby_includedir/*

%files         -n gem-rails
%doc README.md
%ruby_gemspecdir/rails-5.2.4.4.gemspec
%ruby_gemslibdir/rails-5.2.4.4
%files         -n gem-rails-doc
%ruby_gemsdocdir/rails-5.2.4.4

%files         -n gem-rails-devel

%files         -n gem-activesupport
%doc README.rdoc
%ruby_gemspecdir/activesupport-5.2.4.4.gemspec
%ruby_gemslibdir/activesupport-5.2.4.4
%files         -n gem-activesupport-doc
%ruby_gemsdocdir/activesupport-5.2.4.4

%files         -n gem-activesupport-devel

%files         -n gem-activestorage
%doc README.md
%ruby_gemspecdir/activestorage-5.2.4.4.gemspec
%ruby_gemslibdir/activestorage-5.2.4.4
%files         -n gem-activestorage-doc
%ruby_gemsdocdir/activestorage-5.2.4.4

%files         -n gem-activestorage-devel

%files         -n gem-activerecord
%doc README.rdoc
%ruby_gemspecdir/activerecord-5.2.4.4.gemspec
%ruby_gemslibdir/activerecord-5.2.4.4
%files         -n gem-activerecord-doc
%ruby_gemsdocdir/activerecord-5.2.4.4

%files         -n gem-activerecord-devel

%files         -n gem-activemodel
%doc README.rdoc
%ruby_gemspecdir/activemodel-5.2.4.4.gemspec
%ruby_gemslibdir/activemodel-5.2.4.4
%files         -n gem-activemodel-doc
%ruby_gemsdocdir/activemodel-5.2.4.4

%files         -n gem-activemodel-devel

%files         -n gem-activejob
%doc README.md
%ruby_gemspecdir/activejob-5.2.4.4.gemspec
%ruby_gemslibdir/activejob-5.2.4.4
%files         -n gem-activejob-doc
%ruby_gemsdocdir/activejob-5.2.4.4

%files         -n gem-activejob-devel

%files         -n gem-actionview
%doc README.rdoc
%ruby_gemspecdir/actionview-5.2.4.4.gemspec
%ruby_gemslibdir/actionview-5.2.4.4
%files         -n gem-actionview-doc
%ruby_gemsdocdir/actionview-5.2.4.4

%files         -n gem-actionview-devel

%files         -n gem-actionpack
%doc README.rdoc
%ruby_gemspecdir/actionpack-5.2.4.4.gemspec
%ruby_gemslibdir/actionpack-5.2.4.4
%files         -n gem-actionpack-doc
%ruby_gemsdocdir/actionpack-5.2.4.4

%files         -n gem-actionpack-devel
%ruby_includedir/*

%files         -n gem-actionmailer
%doc README.rdoc
%ruby_gemspecdir/actionmailer-5.2.4.4.gemspec
%ruby_gemslibdir/actionmailer-5.2.4.4
%files         -n gem-actionmailer-doc
%ruby_gemsdocdir/actionmailer-5.2.4.4

%files         -n gem-actionmailer-devel

%files         -n gem-actioncable
%doc README.md
%ruby_gemspecdir/actioncable-5.2.4.4.gemspec
%ruby_gemslibdir/actioncable-5.2.4.4
%files         -n gem-actioncable-doc
%ruby_gemsdocdir/actioncable-5.2.4.4

%files         -n gem-actioncable-devel


%changelog
