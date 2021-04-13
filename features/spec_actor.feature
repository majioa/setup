@actor @spec
Feature: Spec actor

   Scenario: Apply the Spec actor to setup
      Given default setup
      When developer applies "spec" actor to the setup
      Then he acquires a present spec for the setup

   Scenario: Space name and sub name validation
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/root_name
         sources:
          - !ruby/object:Setup::Source::Fake
            rootdir: /path/to/dot/space/root_name/sub
          - !ruby/object:Setup::Source::Fake
            rootdir: /path/to/dot/space/root_name
         """
      When developer loads the space
      And developer draws the template:
         """
         Name:          <%= name %>
         <% secondaries.each do |secondary| -%>
         %package       -n <%= secondary.name %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:          root_name
         %package       -n sub

         """

   Scenario: Space default version and part version validation
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/root_name
         sources:
          - !ruby/object:Setup::Source::Fake
            rootdir: /path/to/dot/space/root_name/sub
          - !ruby/object:Setup::Source::Fake
            rootdir: /path/to/dot/space/root_name
         """
      When developer loads the space
      And developer locks the time to "01.01.2001"
      And developer draws the template:
         """
         Version:       <%= version %>
         <% secondaries.each do |secondary| -%>
         %package       -n <%= secondary.name %>
         Version:       <%= secondary.version %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Version:       20010101
         %package       -n sub
         Version:       20010101

         """

   Scenario: Space version and part version validation of two gems
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources:
          - !ruby/object:Setup::Source::Gem
            rootdir: /path/to/dot/space/rootname
            spec: !ruby/object:Gem::Specification
               name: foo_boo
               version: !ruby/object:Gem::Version
                  version: "5.2"
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
                           version: "5.2.4.4"
                  type: :runtime
                  prerelease: false
                  version_requirements: !ruby/object:Gem::Requirement
                     requirements:
                      - - '='
                        - !ruby/object:Gem::Version
                           version: "5.2.4.4"
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
          - !ruby/object:Setup::Source::Gem
            rootdir: /path/to/dot/space/rootname
            spec: !ruby/object:Gem::Specification
               name: foo_boo_ext
               version: !ruby/object:Gem::Version
                  version: 1.1.7
               platform: ruby
               authors:
                - Foo Boo Team
               autorequire:
               bindir: bin
               cert_chain: []
               date: 2021-04-02 00:00:00.000000000 Z
               dependencies:
                - !ruby/object:Gem::Dependency
                  name: foo_boo
                  requirement: !ruby/object:Gem::Requirement
                     requirements:
                      - - '='
                        - !ruby/object:Gem::Version
                         version: "5.2"
                  type: :runtime
                  prerelease: false
                  version_requirements: !ruby/object:Gem::Requirement
                     requirements:
                      - - '='
                        - !ruby/object:Gem::Version
                          version: "5.2"
                - !ruby/object:Gem::Dependency
                  name: b_oofoo_dev
                  requirement: !ruby/object:Gem::Requirement
                     requirements:
                      - - '>='
                        - !ruby/object:Gem::Version
                           version: "5.2.4"
                  type: :development
                  prerelease: false
                  version_requirements: !ruby/object:Gem::Requirement
                     requirements:
                      - - '>='
                        - !ruby/object:Gem::Version
                           version: "5.2.4"
               description: |2
                  Foo boo Ext gem desc
               email: e@example.com
               executables: []
               extensions:
                - ext/foo-boo-ext/extconf.rb
               extra_rdoc_files:
                - README.md
                - LICENSE.txt
                - CHANGELOG.md
               files:
                - ext/foo-boo-ext/foo.c
                - ext/foo-boo-ext/foo.h
               homepage: foo-boo-ext.com
               licenses:
                - MIT
               metadata: {}
               post_install_message:
               rdoc_options: []
               require_paths:
                - lib
               required_ruby_version: !ruby/object:Gem::Requirement
                  requirements:
                   - - ">="
                     - !ruby/object:Gem::Version
                       version: 1.9.3
               required_rubygems_version: !ruby/object:Gem::Requirement
                 requirements:
                   - - ">="
                     - !ruby/object:Gem::Version
                       version: '0'
               requirements: []
               rubygems_version: 3.1.4
               signing_key:
               specification_version: 4
               summary: Foo boo Ext gem.
               test_files: []
         """
      When developer loads the space
      And developer draws the template:
         """
         Name:          <%= adopted_name %>
         Version:       <%= version %>
         <% secondaries.each do |secondary| -%>
         %package       -n <%= secondary.adopted_name %>
         Version:       <%= secondary.version %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:          gem-foo-boo
         Version:       5.2
         %package       -n gem-foo-boo-ext
         Version:       1.1.7

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
         sources: []
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            epoch: 1
         """
      When developer loads the space
      And he draws the template:
         """
         Name:        <%= adopted_name %>
         Epoch:       <%= epoch %>
         """

      Then he gets the RPM spec
         """
         Name:        rootname
         Epoch:       1
         """

   Scenario: Space version validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            version: 1.1
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            release: rc1
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            summaries: !ruby/object:OpenStruct
               table:
                  !ruby/symbol '': RPM Summary
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         sources: []
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            licenses:
             - MIT
             - GPLv2
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            group: Group
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            uri: https://path/to/soft/rpm
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            vcs: https://path/to/vcs/rpm
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
         Vcs:                 <%= vcs %>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Vcs:                 https://path/to/vcs/rpm.git
         """

   Scenario: Space no VCS validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
         <% if has_vcs? -%>
         Vcs:                 <%= vcs %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm

         """

   Scenario: Space URL to VCS trial github conversion validation
         for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            uri: https://github.com/mygrid/ruby-ucf/
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
         <% if has_vcs? -%>
         Vcs:                 <%= vcs %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Vcs:                 https://github.com/mygrid/ruby-ucf.git

         """

   Scenario: Space URL to VCS github io trial conversion validation
         for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            uri: https://mygrid.github.io/ruby-ucf/
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
         <% if has_vcs? -%>
         Vcs:                 <%= vcs %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Vcs:                 https://github.com/mygrid/ruby-ucf.git

         """

   Scenario: Space packager validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            packager: Packer FIO <fio@example.com>
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            build_arch: arch64
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            source_files: !ruby/object:OpenStruct
               table:
                  :0: source_file.tar
                  :1: source_file1.tar
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
         <% source_files.each_pair do |index, source_file| -%>
         <% i = index != :"0" && index || nil -%>
         Source<%= i %>:<%= " " * [ 14 - "#{i}".size, 1 ].max %><%= source_file %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Source:              source_file.tar
         Source1:             source_file1.tar

         """

   Scenario: Space patches validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         sources: []
         rootdir: /path/to/dot/space/rootname
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            patches: !ruby/object:OpenStruct
               table:
                  :0: patch.patch
                  :1: patch1.patch
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
         <% patches.each_pair do |index, patch| -%>
         <% i = index != :"0" && index || nil -%>
         Patch<%= i %>:<%= " " * [ 15 - "#{i}".size, 1 ].max %><%= patch %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Patch:               patch.patch
         Patch1:              patch1.patch

         """

   Scenario: Space requires validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         sources: []
         rootdir: /path/to/dot/space/rootname
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            requires: !ruby/object:OpenStruct
               table:
                  :0: req >= 1
                  :1: req_new < 0.1
                  :2: req_newline >= 2
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            build_requires: !ruby/object:OpenStruct
               table:
                  :0: req >= 1
                  :1: req_new < 0.1
                  :2: req_newline >= 2
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            build_pre_requires: !ruby/object:OpenStruct
               table:
                  :0: req >= 1
                  :1: req_new < 0.1
                  :2: req_newline >= 2

         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            obsoletes: !ruby/object:OpenStruct
               table:
                  :0: req >= 1
                  :1: req_new < 0.1
                  :2: req_newline >= 2

         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            provides: !ruby/object:OpenStruct
               table:
                  :0: req >= 1
                  :1: req_new < 0.1
                  :2: req_newline >= 2

         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            conflicts: !ruby/object:OpenStruct
               table:
                  :0: req >= 1
                  :1: req_new < 0.1
                  :2: req_newline >= 2
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= adopted_name %>
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
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            descriptions: !ruby/object:OpenStruct
               table:
                  ! '': Description Defaults
                  'ru_RU.UTF8': Заметка
         """
      When developer loads the space
      And he draws the template:
         """
         Name:        <%= adopted_name %>
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

   Scenario: Space multiline description with more than 80 chars in line
         validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            descriptions: !ruby/object:OpenStruct
               table:
                  ! '': |
                     Description Defaults with text Lorem Satem with more than 80 chars because
                     it is just set the line defining it, see it below: aaaaaaaaaa aaaaaaaaaa
                     aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa

                     So, it should be arranged as having near to 80 char per (see loop to fill it) line.
                     * list1
                     - list2

                     Ok
         """
      When developer loads the space
      And he draws the template:
         """
         Name:        <%= adopted_name %>
         <% descriptions.each_pair do |arg, description| -%>
         %description<%= !arg.blank? && "         -l #{arg}" || nil %>
         <%= description %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:        rpm
         %description
         Description Defaults with text Lorem Satem with more than 80 chars because it is
         just set the line defining it, see it below: aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa
         aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa aaaaaaaaaa
         aaaaaaaaaa aaaaaaaaaa

         So, it should be arranged as having near to 80 char per (see loop to fill it)
         line.
         * list1
         - list2

         Ok

         """

   Scenario: Space additional package validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            secondaries: !ruby/object:OpenStruct
               table:
                  :rpm-doc: !ruby/object:Setup::Spec::Rpm::Secondary
                     adopted_name: rpm-doc
                     group: Group1
                     build_arch: arch64
                     summaries: !ruby/object:OpenStruct
                        table:
                           :'': Summary Defaults
                           :'ru_RU.UTF8': Итого
                     descriptions: !ruby/object:OpenStruct
                        table:
                           :'': Description Defaults
                           :'ru_RU.UTF8': Заметка
         """
      When developer loads the space
      And he draws the template:
         """
         Name:          <%= adopted_name %>
         <% secondaries.each do |_name, sec| -%>
         %package       -n <%= sec.adopted_name %>
         <% sec.summaries.each do |cp, summary| -%>
         Summary<%= !cp.blank? && "(#{cp})" || nil %>:       <%= summary %>
         <% end -%>
         Group:         <%= sec.group %>
         BuildArch:     <%= sec.build_arch %>

         <% sec.descriptions.each do |cp, description| -%>
         %description   -n <%= sec.adopted_name %><%= !cp.blank? && " -l #{cp}" || nil %>
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
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
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
         Name:        <%= adopted_name %>
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
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            changes:
             - !ruby/object:OpenStruct
               table:
                  :date: "Mon Jan 01 2001"
                  :author: "FIO Packer"
                  :email: fio@example.com
                  :version: 1.0
                  :release: rc1
                  :description: "- ! of important bug"
             - !ruby/object:OpenStruct
               table:
                  :date: "Mon Jan 02 2001"
                  :author: "FIO Packer"
                  :email: fio@example.com
                  :version: 2.0
                  :description: "- ^ new version"
         """
      When developer loads the space
      And he draws the template:
         """
         Name:        <%= adopted_name %>
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
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            adopted_name: rpm
            file_list: |-
               file1
               file2
            secondaries: !ruby/object:OpenStruct
               table:
                  :rpm-doc: !ruby/object:Setup::Spec::Rpm::Secondary
                     adopted_name: rpm-doc
                     file_list: |-
                        file3
                        file4
         """
      When developer loads the space
      And he draws the template:
         """
         Name:          <%= adopted_name %>
         %files
         <%= file_list %>

         <% secondaries.each do |_name, secondary| -%>
         %files         -n <%= secondary.adopted_name %>
         <%= secondary.file_list %>
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
         sources: []
         spec: !ruby/object:Setup::Spec::Rpm
            name: "%{var}%var1"
            context: !ruby/object:OpenStruct
               table:
                  :var: rpm
                  :var1: '2'
         """
      When developer loads the space
      And he draws the template:
         """
         <% variables.each do |name, value| -%>
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
         spec: !ruby/object:Setup::Spec::Rpm
            name: "%{var}%var1"
            context: !ruby/object:OpenStruct
               table:
                  :__macros:
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

   Scenario: Space gem pure source render validation
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources:
          - !ruby/object:Setup::Source::Gem
            rootdir: /path/to/dot/space/rootname
            spec: !ruby/object:Gem::Specification
               name: foo_boo
               version: !ruby/object:Gem::Version
                  version: "5.2"
               platform: ruby
               authors:
                - Gem Author
               autorequire:
               bindir: exe
               cert_chain: []
               date:
               dependencies: []
               description: 'Foo Boo gem'
               email: boo@example.com
               extensions: []
               extra_rdoc_files: []
               files:
                - CHANGELOG.md
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
         Name:          <%= adopted_name %>
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

         <% if has_executable? -%>
         %package       -n <%= executable_name %>
         Summary:       Executable file for %gemname gem
         Summary(ru_RU.UTF-8): Исполнямка для самоцвета %gemname
         Group:         Development/Ruby
         BuildArch:     noarch

         %description   -n %pkgname
         Executable file for %gemname gem.

         %description   -n %pkgname -l ru_RU.UTF8
         Исполнямка для %gemname самоцвета.


         <% end -%>
         <% if has_doc? -%>
         %package       doc
         Summary:       Documentation files for %gemname gem
         Summary(ru_RU.UTF-8): Файлы сведений для самоцвета %gemname
         Group:         Development/Documentation
         BuildArch:     noarch

         %description   doc
         Documentation files for %gemname gem.

         %description   doc -l ru_RU.UTF8
         Файлы сведений для самоцвета %gemname.


         <% end -%>
         <% if has_devel? -%>
         %package       devel
         Summary:       Development files for %gemname gem
         Group:         Development/Ruby
         BuildArch:     noarch

         <% devel_deps.each_pair do |_, dep| -%>
         Requires:      <%= dep %>
         <% end -%>

         %description   devel
         Development files for %gemname gem.

         %description   devel -l ru_RU.UTF8
         Файлы заголовков для самоцвета %gemname.


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
         <% if has_readme? %>
         %doc <%= readme %>
         <% end -%>
         %ruby_gemspec
         %ruby_gemlibdir
         <% if has_compilable? -%>
         %ruby_gemextdir
         <% end -%>

         <% if has_executable? -%>
         %files         -n <%= executable_name %>
         <% executables.each do |e| -%>
         %_bindir/<%= e %>
         <% end -%>

         <% end -%>
         <% if has_doc? -%>
         %files         doc
         %ruby_gemdocdir

         <% end -%>
         <% if has_devel? -%>
         %files         devel
         %ruby_includedir

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
         Vcs:           https://github.com/foo/fooboo/tree/v5.2.4.4/fooboo.git
         Packager:      Spec Author <author@example.org>
         BuildArch:     noarch

         Source:        %name-%version.tar
         BuildRequires(pre): rpm-build-ruby

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
         %ruby_gemspec
         %ruby_gemlibdir


         %changelog
         * Mon Jan 01 2001 Spec Author <author@example.org> 5.2-alt1
         - + packaged gem


         """

   Scenario: Space gem source with executable, docs, and devel rendering validation
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources:
          - !ruby/object:Setup::Source::Gem
            rootdir: /path/to/dot/space/rootname
            spec: !ruby/object:Gem::Specification
               name: foo_boo
               version: !ruby/object:Gem::Version
                  version: "5.2"
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
                           version: "5.2.4.4"
                  type: :runtime
                  prerelease: false
                  version_requirements: !ruby/object:Gem::Requirement
                     requirements:
                      - - '='
                        - !ruby/object:Gem::Version
                           version: "5.2.4.4"
               description: 'Foo Boo gem'
               email: boo@example.com
               executables:
                - foo
               extensions:
                - ext/foo-boo-ext/extconf.rb
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
         Name:          <%= adopted_name %>
         <% if has_epoch? -%>
         Epoch:         <%= epoch %>
         <% end -%>
         Version:       <%= version %>
         Release:       <%= release %>
         <% summaries.each_pair do |cp, summary| -%>
         Summary<%= !cp.blank? && "(#{cp})" || nil %>:       <%= summary %>
         <% end -%>
         License:       <%= licenses.join(" or ") %>
         Group:         <%= group %>
         Url:           <%= uri %>
         Vcs:           <%= vcs %>
         Packager:      <%= packager %>
         <% if !has_any_compilable? -%>
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


         <% if has_executable? -%>
         %package       -n <%= executable_name %>
         Summary:       Executable file for %gemname gem
         Summary(ru_RU.UTF-8): Исполнямка для самоцвета %gemname
         Group:         Development/Ruby
         BuildArch:     noarch

         %description   -n <%= executable_name %>
         Executable file for %gemname gem.

         %description   -n <%= executable_name %> -l ru_RU.UTF8
         Исполнямка для %gemname самоцвета.


         <% end -%>
         <% if has_doc? -%>
         %package       doc
         Summary:       Documentation files for %gemname gem
         Summary(ru_RU.UTF-8): Файлы сведений для самоцвета %gemname
         Group:         Development/Documentation
         BuildArch:     noarch

         %description   doc
         Documentation files for %gemname gem.

         %description   doc -l ru_RU.UTF8
         Файлы сведений для самоцвета %gemname.


         <% end -%>
         <% if has_devel? -%>
         %package       devel
         Summary:       Development files for %gemname gem
         Group:         Development/Ruby
         BuildArch:     noarch

         <% if devel_deps.empty? -%>
         <% devel_deps.each do |dep| -%>
         Requires:      <%= dep %>
         <% end -%>

         <% end -%>
         %description   devel
         Development files for %gemname gem.

         %description   devel -l ru_RU.UTF8
         Файлы заголовков для самоцвета %gemname.


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
         <% if has_readme? -%>
         %doc <%= readme %>
         <% end -%>
         %ruby_gemspec
         %ruby_gemlibdir
         <% if has_compilable? -%>
         %ruby_gemextdir

         <% end -%>
         <% if has_executable? -%>
         %files         -n <%= executable_name %>
         <% executables.each do |e| -%>
         %_bindir/<%= e %>
         <% end -%>

         <% end -%>
         <% if has_doc? -%>
         %files         doc
         %ruby_gemdocdir

         <% end -%>
         <% if has_devel? -%>
         %files         devel
         %ruby_includedir

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
         Vcs:           https://github.com/foo/fooboo/tree/v5.2.4.4/fooboo.git
         Packager:      Spec Author <author@example.org>

         Source:        %name-%version.tar
         BuildRequires(pre): rpm-build-ruby
         BuildRequires: gem(b_oofoo) = 5.2.4.4

         %add_findreq_skiplist %ruby_gemslibdir/**/*
         %add_findprov_skiplist %ruby_gemslibdir/**/*

         %description
         Foo Boo gem


         %package       -n foo
         Summary:       Executable file for %gemname gem
         Summary(ru_RU.UTF-8): Исполнямка для самоцвета %gemname
         Group:         Development/Ruby
         BuildArch:     noarch

         %description   -n foo
         Executable file for %gemname gem.

         %description   -n foo -l ru_RU.UTF8
         Исполнямка для %gemname самоцвета.


         %package       doc
         Summary:       Documentation files for %gemname gem
         Summary(ru_RU.UTF-8): Файлы сведений для самоцвета %gemname
         Group:         Development/Documentation
         BuildArch:     noarch

         %description   doc
         Documentation files for %gemname gem.

         %description   doc -l ru_RU.UTF8
         Файлы сведений для самоцвета %gemname.


         %package       devel
         Summary:       Development files for %gemname gem
         Group:         Development/Ruby
         BuildArch:     noarch

         %description   devel
         Development files for %gemname gem.

         %description   devel -l ru_RU.UTF8
         Файлы заголовков для самоцвета %gemname.


         %prep
         %setup

         %build
         %ruby_build

         %install
         %ruby_install

         %check
         %ruby_test

         %files
         %doc readme.md
         %ruby_gemspec
         %ruby_gemlibdir
         %ruby_gemextdir

         %files         -n foo
         %_bindir/foo

         %files         doc
         %ruby_gemdocdir

         %files         devel
         %ruby_includedir


         %changelog
         * Mon Jan 01 2001 Spec Author <author@example.org> 5.2-alt1
         - + packaged gem


         """

   Scenario: Space many gem sources render validation
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources:
          - !ruby/object:Setup::Source::Gem
            rootdir: /path/to/dot/space/rootname
            spec: !ruby/object:Gem::Specification
               name: foo_boo
               version: !ruby/object:Gem::Version
                  version: "5.2"
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
                           version: "5.2.4.4"
                  type: :runtime
                  prerelease: false
                  version_requirements: !ruby/object:Gem::Requirement
                     requirements:
                      - - '='
                        - !ruby/object:Gem::Version
                           version: "5.2.4.4"
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
          - !ruby/object:Setup::Source::Gem
            rootdir: /path/to/dot/space/rootname
            spec: !ruby/object:Gem::Specification
               name: foo_boo_ext
               version: !ruby/object:Gem::Version
                  version: 1.1.7
               platform: ruby
               authors:
                - Foo Boo Team
               autorequire:
               bindir: exe
               cert_chain: []
               date: 2021-04-02 00:00:00.000000000 Z
               dependencies:
                - !ruby/object:Gem::Dependency
                  name: foo_boo
                  requirement: !ruby/object:Gem::Requirement
                     requirements:
                      - - '='
                        - !ruby/object:Gem::Version
                         version: "5.2"
                  type: :runtime
                  prerelease: false
                  version_requirements: !ruby/object:Gem::Requirement
                     requirements:
                      - - '='
                        - !ruby/object:Gem::Version
                          version: "5.2"
                - !ruby/object:Gem::Dependency
                  name: b_oofoo_dev
                  requirement: !ruby/object:Gem::Requirement
                     requirements:
                      - - '>='
                        - !ruby/object:Gem::Version
                           version: "5.2.4"
                  type: :development
                  prerelease: false
                  version_requirements: !ruby/object:Gem::Requirement
                     requirements:
                      - - '>='
                        - !ruby/object:Gem::Version
                           version: "5.2.4"
               description: |2
                  Foo boo Ext gem desc
               email: e@example.com
               executables:
                - foo_boo_ext
               extensions:
                - ext/foo-boo-ext/extconf.rb
               extra_rdoc_files:
                - README.md
                - LICENSE.txt
                - CHANGELOG.md
               files:
                - ext/foo-boo-ext/foo.c
                - ext/foo-boo-ext/foo.h
                - exe/foo_boo_ext
               homepage: foo-boo-ext.com
               licenses:
                - MIT
               metadata: {}
               post_install_message:
               rdoc_options: []
               require_paths:
                - lib
               required_ruby_version: !ruby/object:Gem::Requirement
                  requirements:
                   - - ">="
                     - !ruby/object:Gem::Version
                       version: 1.9.3
               required_rubygems_version: !ruby/object:Gem::Requirement
                 requirements:
                   - - ">="
                     - !ruby/object:Gem::Version
                       version: '0'
               requirements: []
               rubygems_version: 3.1.4
               signing_key:
               specification_version: 4
               summary: Foo boo Ext gem.
               test_files: []
         """
      When developer loads the space
      And developer locks the time to "01.01.2001"
      And developer draws the template:
         """
         <% if has_comment? -%>
         <%= comment -%>

         <% end -%>
         Name:          <%= adopted_name %>
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
         <% if !has_any_compilable? -%>
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

         <% secondaries.each do |secondary| -%>
         %package       -n <%= secondary.adopted_name %>
         Version:       <%= secondary.version %>
         <% secondary.summaries.each_pair do |cp, summary| -%>
         Summary<%= !cp.blank? && "(#{cp})" || nil %>:       <%= summary %>
         <% end -%>
         Group:         Development/Ruby

         <% descriptions.each_pair do |arg, description| -%>
         %description   -n <%= secondary.adopted_name %><%= !arg.blank? && " -l #{arg}" || nil %>
         <%= description %>

         <% end -%>

         <% if secondary.has_executable? -%>
         %package       -n <%= secondary.executable_name %>
         Summary:       Executable file for %gemname gem
         Summary(ru_RU.UTF-8): Исполнямка для самоцвета %gemname
         Group:         Development/Ruby
         BuildArch:     noarch

         %description   -n <%= secondary.executable_name %>
         Executable file for %gemname gem.

         %description   -n <%= secondary.executable_name %> -l ru_RU.UTF8
         Исполнямка для %gemname самоцвета.


         <% end -%>
         <% if secondary.has_doc? -%>
         %package       -n <%= secondary.adopted_name %>-doc
         Summary:       Documentation files for %gemname gem
         Summary(ru_RU.UTF-8): Файлы сведений для самоцвета %gemname
         Group:         Development/Documentation
         BuildArch:     noarch

         %description   -n <%= secondary.adopted_name %>-doc
         Documentation files for %gemname gem.

         %description   -n <%= secondary.adopted_name %>-doc -l ru_RU.UTF8
         Файлы сведений для самоцвета %gemname.


         <% end -%>
         <% if secondary.has_devel? -%>
         %package       -n <%= secondary.adopted_name %>-devel
         Summary:       Development files for %gemname gem
         Group:         Development/Ruby
         BuildArch:     noarch

         <% if !secondary.devel_deps.empty? -%>
         <% secondary.devel_deps.each_pair do |_, dep| -%>
         Requires:      <%= dep %>
         <% end -%>

         <% end -%>
         %description   -n <%= secondary.adopted_name %>-devel
         Development files for %gemname gem.

         %description   -n <%= secondary.adopted_name %>-devel -l ru_RU.UTF8
         Файлы заголовков для самоцвета %gemname.


         <% end -%>
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
         <% if has_readme? -%>
         %doc <%= readme %>
         <% end -%>
         %ruby_gemspec
         %ruby_gemlibdir
         <% if has_compilable? -%>
         %ruby_gemextdir
         <% end -%>

         <% secondaries.each do |secondary| -%>
         <% if secondary.has_readme? -%>
         %files         -n <%= secondary.adopted_name %>
         <% end -%>
         %doc <%= secondary.readme %>
         %ruby_gemspecdir/<%= secondary.name %>-<%= secondary.version %>.gemspec
         %ruby_gemslibdir/<%= secondary.name %>-<%= secondary.version %>
         <% if secondary.has_compilable? -%>
         %ruby_gemsextdir/<%= secondary.name %>-<%= secondary.version %>

         <% end -%>
         <% if secondary.has_executable? -%>
         %files         -n <%= secondary.executable_name %>
         <% secondary.executables.each do |e| -%>
         %_bindir/<%= e %>
         <% end -%>

         <% end -%>
         <% if secondary.has_doc? -%>
         %files         -n <%= secondary.adopted_name %>-doc
         %ruby_gemsdocdir/<%= secondary.name %>-<%= secondary.version %>

         <% end -%>
         <% if secondary.has_devel? -%>
         %files         -n <%= secondary.adopted_name %>-devel
         <% if secondary.has_devel_sources? -%>
         %ruby_includedir/*
         <% end -%>
         <% end -%>

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
         Vcs:           https://github.com/foo/fooboo/tree/v5.2.4.4/fooboo.git
         Packager:      Spec Author <author@example.org>

         Source:        %name-%version.tar
         BuildRequires(pre): rpm-build-ruby
         BuildRequires: gem(b_oofoo) = 5.2.4.4
         BuildRequires: gem(b_oofoo_dev) >= 5.2.4

         %add_findreq_skiplist %ruby_gemslibdir/**/*
         %add_findprov_skiplist %ruby_gemslibdir/**/*

         %description
         Foo Boo gem

         %package       -n gem-foo-boo-ext
         Version:       1.1.7
         Summary:       Foo boo Ext gem.
         Group:         Development/Ruby

         %description   -n gem-foo-boo-ext
         Foo Boo gem


         %package       -n foo-boo-ext
         Summary:       Executable file for %gemname gem
         Summary(ru_RU.UTF-8): Исполнямка для самоцвета %gemname
         Group:         Development/Ruby
         BuildArch:     noarch

         %description   -n foo-boo-ext
         Executable file for %gemname gem.

         %description   -n foo-boo-ext -l ru_RU.UTF8
         Исполнямка для %gemname самоцвета.


         %package       -n gem-foo-boo-ext-doc
         Summary:       Documentation files for %gemname gem
         Summary(ru_RU.UTF-8): Файлы сведений для самоцвета %gemname
         Group:         Development/Documentation
         BuildArch:     noarch

         %description   -n gem-foo-boo-ext-doc
         Documentation files for %gemname gem.

         %description   -n gem-foo-boo-ext-doc -l ru_RU.UTF8
         Файлы сведений для самоцвета %gemname.


         %package       -n gem-foo-boo-ext-devel
         Summary:       Development files for %gemname gem
         Group:         Development/Ruby
         BuildArch:     noarch

         Requires:      gem(foo_boo) = 5.2
         Requires:      gem(b_oofoo_dev) >= 5.2.4

         %description   -n gem-foo-boo-ext-devel
         Development files for %gemname gem.

         %description   -n gem-foo-boo-ext-devel -l ru_RU.UTF8
         Файлы заголовков для самоцвета %gemname.


         %prep
         %setup

         %build
         %ruby_build

         %install
         %ruby_install

         %check
         %ruby_test

         %files
         %doc readme.md
         %ruby_gemspec
         %ruby_gemlibdir

         %files         -n gem-foo-boo-ext
         %doc README.md
         %ruby_gemspecdir/foo_boo_ext-1.1.7.gemspec
         %ruby_gemslibdir/foo_boo_ext-1.1.7
         %ruby_gemsextdir/foo_boo_ext-1.1.7

         %files         -n foo-boo-ext
         %_bindir/foo_boo_ext

         %files         -n gem-foo-boo-ext-doc
         %ruby_gemsdocdir/foo_boo_ext-1.1.7

         %files         -n gem-foo-boo-ext-devel
         %ruby_includedir/*


         %changelog
         * Mon Jan 01 2001 Spec Author <author@example.org> 5.2-alt1
         - + packaged gem


         """

