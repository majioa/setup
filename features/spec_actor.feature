@actor @spec
Feature: Spec actor

   Scenario: Apply the Spec actor to setup
      Given default setup
      When developer applies "spec" actor to the setup
      Then he acquires a present spec for the setup

   Scenario: Space name validation
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources:
          - rootdir: /path/to/dot/space/rootname/sub
          - rootdir: /path/to/dot/space/rootname
         """
      When developer loads the space
      And developer draws the template:
         """
         Name:          <%= name %>
         """

      Then he gets the RPM spec
         """
         Name:          rootname
         """

   Scenario: Space default version validation
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         """
      When developer loads the space
      And developer locks the time to "01.01.2001"
      And developer draws the template:
         """
         Version:       <%= version %>
         """

      Then he gets the RPM spec
         """
         Version:       20010101
         """

   Scenario: Space version validation
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources:
          - rootdir: /path/to/dot/space/rootname
            type: gem
            spec: |
               --- !ruby/object:Gem::Specification
               name: fooboo
               version: !ruby/object:Gem::Version
                  version: 5.2
               platform: ruby
               authors:
                - Gem Author
               autorequire:
               bindir: exe
               cert_chain: []
               date:
               dependencies:
                - !ruby/object:Gem::Dependency
                  name: boofoo
                  requirement: !ruby/object:Gem::Requirement
                     requirements:
                      - - '='
                        - !ruby/object:Gem::Version
                           version: 5.2.4.4
                  type: :runtime
                  prerelease: false
                  version_requirements: !ruby/object:Gem::Requirement
                     requirements:
                      - - '='
                        - !ruby/object:Gem::Version
                           version: 5.2.4.4
               description: 'Foo Boo gem'
               email: boo@example.com
               executables:
                - foo
               extensions: []
               extra_rdoc_files: []
               files:
                - CHANGELOG.md
                - readme.md
                - MIT-LICENSE
                - exe/foo
                - lib/foo.rb
               homepage: http://fooboo.org
               licenses:
                - MIT
               metadata:
                  source_code_uri: https://github.com/foo/fooboo/tree/v5.2.4.4/fooboo
                  changelog_uri: https://github.com/foo/fooboo/blob/v5.2.4.4/fooboo/CHANGELOG.md
               post_install_message:
               rdoc_options:
                - "--exclude"
                - "."
               require_paths:
                - lib
               required_ruby_version: !ruby/object:Gem::Requirement
                  requirements:
                   - - ">="
                     - !ruby/object:Gem::Version
                       version: 2.2.2
               required_rubygems_version: !ruby/object:Gem::Requirement
                  requirements:
                   - - ">="
                     - !ruby/object:Gem::Version
                        version: '0'
               requirements: []
               rubygems_version: 3.1.4
               signing_key:
               specification_version: 4
               summary: Foo Boo gem summary
               test_files: []
         """
      When developer loads the space
      And developer draws the template:
         """
         Name:          <%= name %>
         Version:       <%= version %>
         """

      Then he gets the RPM spec
         """
         Name:          gem-fooboo
         Version:       5.2
         """

   Scenario: Validation to no spec epoch with default value
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         """
      When developer loads the space
      And developer draws the template:
         """
         <% if has_epoch? -%>
         Epoch:       <%= epoch %>
         <% end -%>
         """

      Then he gets blank RPM spec

   Scenario: Space epoch validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            epoch: 1
         """
      When developer loads the space
      And he draws the template:
         """
         Name:        <%= _name %>
         Epoch:       <%= epoch %>
         """

      Then he gets the RPM spec
         """
         Name:        rpm
         Epoch:       1
         """

   Scenario: Space version validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            version: 1.1
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         Version:             <%= version %>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Version:             1.1
         """

   Scenario: Space release validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            release: rc1
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         Release:             <%= release %>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Release:             rc1
         """

   Scenario: Space summary validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            summaries:
               ! '': RPM Summary
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         Summary:             <%= summary %>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Summary:             RPM Summary
         """

   Scenario: Space license validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            licenses:
             - MIT
             - GPLv2
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         License:             <%= licenses.join(" or ") %>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         License:             MIT or GPLv2
         """

   Scenario: Space group validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            group: Group
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         Group:               <%= group %>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Group:               Group
         """

   Scenario: Space URI validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            uri: https://path/to/soft/rpm
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         Url:                 <%= uri %>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Url:                 https://path/to/soft/rpm
         """

   Scenario: Space VCS validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            vcs: https://path/to/vcs/rpm
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         Vcs:                 <%= vcs %>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Vcs:                 https://path/to/vcs/rpm
         """

   Scenario: Space packager validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            packager: Packer FIO <fio@example.com>
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         Packager:            <%= packager %>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Packager:            Packer FIO <fio@example.com>
         """

   Scenario: Space build architecture validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            build_arch: arch64
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         <% if has_build_arch? -%>
         BuildArch:           <%= build_arch %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         BuildArch:           arch64

         """

   Scenario: Space sources validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            source_files:
               0: source_file.tar
               1: source_file1.tar
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         <% source_files.each_pair do |index, source_file| -%>
         Source<%= index != :"0" && index || nil %>:              <%= source_file %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Source:              source_file.tar
         Source1:              source_file1.tar

         """

   Scenario: Space patches validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            patches:
               0: patch.patch
               1: patch1.patch
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         <% patches.each_pair do |index, patch| -%>
         Patch<%= index != :"0" && index || nil %>:               <%= patch %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Patch:               patch.patch
         Patch1:               patch1.patch

         """

   Scenario: Space requires validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            requires:
               0: req >= 1
               1: req_new < 0.1
               2: req_newline >= 2
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         <% requires.each_pair do |_, dep| -%>
         Requires:            <%= dep %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Requires:            req >= 1
         Requires:            req_new < 0.1
         Requires:            req_newline >= 2

         """

   Scenario: Space build requires validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            build_requires:
               0: req >= 1
               1: req_new < 0.1
               2: req_newline >= 2
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         <% build_requires.each_pair do |_, dep| -%>
         BuildRequires:       <%= dep %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         BuildRequires:       req >= 1
         BuildRequires:       req_new < 0.1
         BuildRequires:       req_newline >= 2

         """

   Scenario: Space build pre requires validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            build_pre_requires:
               0: req >= 1
               1: req_new < 0.1
               2: req_newline >= 2

         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         <% build_pre_requires.each_pair do |_, dep| -%>
         BuildRequires(pre):  <%= dep %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         BuildRequires(pre):  req >= 1
         BuildRequires(pre):  req_new < 0.1
         BuildRequires(pre):  req_newline >= 2

         """

   Scenario: Space obsoletes validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            obsoletes:
               0: req >= 1
               1: req_new < 0.1
               2: req_newline >= 2

         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         <% obsoletes.each_pair do |_, dep| -%>
         Obsoletes:           <%= dep %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Obsoletes:           req >= 1
         Obsoletes:           req_new < 0.1
         Obsoletes:           req_newline >= 2

         """

   Scenario: Space provides validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            provides:
               0: req >= 1
               1: req_new < 0.1
               2: req_newline >= 2

         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         <% provides.each_pair do |_, dep| -%>
         Provides:            <%= dep %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Provides:            req >= 1
         Provides:            req_new < 0.1
         Provides:            req_newline >= 2

         """

   Scenario: Space conflicts validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            conflicts:
               0: req >= 1
               1: req_new < 0.1
               2: req_newline >= 2
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= _name %>
         <% conflicts.each_pair do |_, dep| -%>
         Conflicts:           <%= dep %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Conflicts:           req >= 1
         Conflicts:           req_new < 0.1
         Conflicts:           req_newline >= 2

         """

   Scenario: Space description validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            descriptions:
               ! '': Description Defaults
               'ru_RU.UTF8': Заметка
         """
      When developer loads the space
      And he draws the template:
         """
         Name:        <%= _name %>
         <% descriptions.each_pair do |arg, description| -%>
         %description<%= !arg.blank? && "         -l #{arg}" || nil %>
         <%= description %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:        rpm
         %description
         Description Defaults
         %description         -l ru_RU.UTF8
         Заметка

         """

   Scenario: Space additional package validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            secondaries:
               rpm-doc:
                  name: rpm-doc
                  group: Group1
                  build_arch: arch64
                  summaries:
                     ! '': Summary Defaults
                     'ru_RU.UTF8': Итого
                  descriptions:
                     ! '': Description Defaults
                     'ru_RU.UTF8': Заметка
         """
      When developer loads the space
      And he draws the template:
         """
         Name:          <%= _name %>
         <% secondaries.each_pair do |name, sec| -%>
         %package       -n <%= name %>
         <% sec.summaries.to_h.each do |cp, summary| -%>
         Summary<%= "#{cp}" != "" && "(#{cp})" || nil %>:       <%= summary %>
         <% end -%>
         Group:         <%= sec.group %>
         BuildArch:     <%= sec.build_arch %>

         <% sec.descriptions.each_pair do |cp, description| -%>
         %description   -n <%= sec.name %><%= "#{cp}" != "" && " -l #{cp}" || nil %>
         <%= description %>
         <% end -%>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:          rpm
         %package       -n rpm-doc
         Summary:       Summary Defaults
         Summary(ru_RU.UTF8):       Итого
         Group:         Group1
         BuildArch:     arch64

         %description   -n rpm-doc
         Description Defaults
         %description   -n rpm-doc -l ru_RU.UTF8
         Заметка

         """

   Scenario: Space stages validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            prep: |-
               setup
               patch
            build: build
            install: install
            check: check
         """
      When developer loads the space
      And he draws the template:
         """
         Name:        <%= _name %>
         %prep
         <%= prep %>

         %build
         <%= build %>

         %install
         <%= install %>

         %check
         <%= check %>
         """

      Then he gets the RPM spec
         """
         Name:        rpm
         %prep
         setup
         patch

         %build
         build

         %install
         install

         %check
         check
         """

   Scenario: Space changes validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            changes:
             - date: "Mon Jan 01 2001"
               author: "FIO Packer"
               email: fio@example.com
               version: 1.0
               release: rc1
               description: "- ! of important bug"
             - date: "Mon Jan 02 2001"
               author: "FIO Packer"
               email: fio@example.com
               version: 2.0
               description: "- ^ new version"
         """
      When developer loads the space
      And he draws the template:
         """
         Name:        <%= _name %>
         %changelog
         <% changes.reverse.each do |c| -%>
         * <%= c.date %> <%= c.author %> <%= c.email && "<#{c.email}>" || "" %> <%= [ c.version, c.release ].compact.join("-") %>
         <%= c.description %>

         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:        rpm
         %changelog
         * Mon Jan 02 2001 FIO Packer <fio@example.com> 2.0
         - ^ new version

         * Mon Jan 01 2001 FIO Packer <fio@example.com> 1.0-rc1
         - ! of important bug


         """

   Scenario: Space files validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: rpm
            file_list: |-
               file1
               file2
            secondaries:
               rpm-doc:
                  name: rpm-doc
                  file_list: |-
                     file3
                     file4
         """
      When developer loads the space
      And he draws the template:
         """
         Name:          <%= _name %>
         %files
         <%= file_list %>

         <% secondaries.each_pair do |name, sec| -%>
         %files         -n <%= name %>
         <%= sec.file_list %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:          rpm
         %files
         file1
         file2

         %files         -n rpm-doc
         file3
         file4

         """

   Scenario: Space variables validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: "%{var}%var1"
            context:
               var: rpm
               var1: 2
         """
      When developer loads the space
      And he draws the template:
         """
         <% variables.each_pair do |name, value| -%>
         %define <%= name %> <%= value %>
         <% end -%>

         Name:          <%= _name %>
         """

      Then he gets the RPM spec
         """
         %define var rpm
         %define var1 2

         Name:          %{var}%var1
         """
      And property "name" of space is "rpm2"

   Scenario: Space macros validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec:
            name: "%{var}%var1"
            context:
               __macros:
                  macro:
                     - "rpmn < 1"
                     - "rpmn1 < 2"
                  macro1: "rpmn < 11"
         """
      When developer loads the space
      And he draws the template:
         """
         Name:          <%= _name %>
         <%= macros("macro") %>
         <%= macros("macro1") %>
         """

      Then he gets the RPM spec
         """
         Name:          %{var}%var1
         %macro rpmn < 1
         %macro rpmn1 < 2
         %macro1 rpmn < 11
         """

   Scenario: Space gem source render validation
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources:
          - rootdir: /path/to/dot/space/rootname
            type: gem
            spec: |
               --- !ruby/object:Gem::Specification
               name: foo_boo
               version: !ruby/object:Gem::Version
                  version: 5.2
               platform: ruby
               authors:
                - Gem Author
               autorequire:
               bindir: exe
               cert_chain: []
               date:
               dependencies:
                - !ruby/object:Gem::Dependency
                  name: b_oofoo
                  requirement: !ruby/object:Gem::Requirement
                     requirements:
                      - - '='
                        - !ruby/object:Gem::Version
                           version: 5.2.4.4
                  type: :runtime
                  prerelease: false
                  version_requirements: !ruby/object:Gem::Requirement
                     requirements:
                      - - '='
                        - !ruby/object:Gem::Version
                           version: 5.2.4.4
               description: 'Foo Boo gem'
               email: boo@example.com
               executables:
                - foo
               extensions: []
               extra_rdoc_files: []
               files:
                - CHANGELOG.md
                - readme.md
                - MIT-LICENSE
                - exe/foo
                - lib/foo.rb
               homepage: http://fooboo.org
               licenses:
                - MIT
                - GPLv2
               metadata:
                  source_code_uri: https://github.com/foo/fooboo/tree/v5.2.4.4/fooboo
                  changelog_uri: https://github.com/foo/fooboo/blob/v5.2.4.4/fooboo/CHANGELOG.md
               post_install_message:
               rdoc_options:
                - "--exclude"
                - "."
               require_paths:
                - lib
               required_ruby_version: !ruby/object:Gem::Requirement
                  requirements:
                   - - ">="
                     - !ruby/object:Gem::Version
                       version: 2.2.2
               required_rubygems_version: !ruby/object:Gem::Requirement
                  requirements:
                   - - ">="
                     - !ruby/object:Gem::Version
                        version: '0'
               requirements: []
               rubygems_version: 3.1.4
               signing_key:
               specification_version: 4
               summary: Foo Boo gem summary
               test_files: []
         """
      When developer loads the space
      And developer locks the time to "01.01.2001"
      And developer draws the template:
         """
         <% if has_comment? -%>
         <%= comment -%>

         <% end -%>
         Name:          <%= name.gsub(/[_\.]/, '-') %>
         <% if has_epoch? -%>
         Epoch:         <%= epoch %>
         <% end -%>
         Version:       <%= version %>
         Release:       <%= release %>
         Summary:       <%= summary %>
         License:       <%= licenses.join(" or ") %>
         Group:         <%= group %>
         Url:           <%= uri %>
         Vcs:           <%= vcs %>
         Packager:      <%= packager %>
         <% if !has_compilable? -%>
         BuildArch:     noarch
         <% end -%>

         <% source_files.each_pair do |index, source_file| -%>
         Source<%= index != :"0" && index || nil %>:        <%= source_file %>
         <% end -%>
         <% patches.each_pair do |index, patch| -%>
         Patch<%= index != :"0" && index || nil %>:         <%= patch %>
         <% end -%>
         <% build_pre_requires.each_pair do |_, dep| -%>
         BuildRequires(pre): <%= dep %>
         <% end -%>
         <% build_requires.each_pair do |_, dep| -%>
         BuildRequires: <%= dep %>
         <% end -%>

         %add_findreq_skiplist %ruby_gemslibdir/**/*
         %add_findprov_skiplist %ruby_gemslibdir/**/*
         <% requires.each_pair do |_, dep| -%>
         Requires:      <%= dep %>
         <% end -%>
         <% obsoletes.each_pair do |_, dep| -%>
         Obsoletes:     <%= dep %>
         <% end -%>
         <% provides.each_pair do |_, dep| -%>
         Provides:      <%= dep %>
         <% end -%>
         <% conflicts.each_pair do |_, dep| -%>
         Conflicts:     <%= dep %>
         <% end -%>

         <% descriptions.each_pair do |arg, description| -%>
         %description<%= !arg.blank? && "         -l #{arg}" || nil %>
         <%= description %>
         <% end -%>

         %prep
         %setup

         %build
         %ruby_build

         %install
         %ruby_install

         %check
         %ruby_test

         %files
         %doc <%= readme %>*
         %ruby_gemspec
         %ruby_gemlibdir
         <% if has_compilable? -%>
         %ruby_gemextdir

         <% end -%>

         %changelog
         <% changes.reverse.each do |c| -%>
         * <%= c.date %> <%= c.author %> <%= c.email && "<#{c.email}>" || "" %> <%= [ c.version, c.release ].compact.join("-") %>
         <%= c.description %>

         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:          gem-foo-boo
         Version:       5.2
         Release:       alt1
         Summary:       Foo Boo gem summary
         License:       MIT or GPLv2
         Group:         Development/Ruby
         Url:           http://fooboo.org
         Vcs:           https://github.com/foo/fooboo/tree/v5.2.4.4/fooboo
         Packager:      Spec Author <author@example.org>
         BuildArch:     noarch

         Source:        %name-%version.tar
         BuildRequires(pre): rpm-build-ruby
         BuildRequires: gem(b_oofoo) = 5.2.4.4

         %add_findreq_skiplist %ruby_gemslibdir/**/*
         %add_findprov_skiplist %ruby_gemslibdir/**/*

         %description
         Foo Boo gem

         %prep
         %setup

         %build
         %ruby_build

         %install
         %ruby_install

         %check
         %ruby_test

         %files
         %doc README*
         %ruby_gemspec
         %ruby_gemlibdir

         %changelog
         * Mon Jan 01 2001 Spec Author <author@example.org> 5.2-alt1
         - + packaged gem


         """

