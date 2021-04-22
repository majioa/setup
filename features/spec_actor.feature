@actor @spec
Feature: Spec actor

   Scenario: Apply the Spec actor to setup
      Given blank setup CLI
      And default setup
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
         Name:          root-name
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
         Name:          <%= name %>
         Version:       <%= version %>
         <% secondaries.each do |secondary| -%>
         %package       -n <%= secondary.name %>
         Version:       <%= secondary.version %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:          gem-foo-boo
         Version:       5.2
         %package       -n gem-foo-boo-ext
         Version:       1.1.7
         %package       -n gem-foo-boo-ext-doc
         Version:       1.1.7
         %package       -n gem-foo-boo-ext-devel
         Version:       1.1.7
         %package       -n foo
         Version:       5.2
         %package       -n gem-foo-boo-doc
         Version:       5.2
         %package       -n gem-foo-boo-devel
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
         sources: []
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               epoch: 1
         """
      When developer loads the space
      And he draws the template:
         """
         Epoch:       <%= epoch %>
         """

      Then he gets the RPM spec
         """
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
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               version: !ruby/object:Gem::Version
                  version: "1.1"
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               release: rc1
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               summaries: !ruby/object:OpenStruct
                  table:
                     !ruby/symbol '': RPM Summary
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
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
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               licenses:
                - MIT
                - GPLv2
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               group: Group
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               uri: https://path/to/soft/rpm
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               vcs: https://path/to/vcs/rpm
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               uri: https://github.com/mygrid/ruby-ucf/
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               uri: https://mygrid.github.io/ruby-ucf/
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               packager: !ruby/object:OpenStruct
                  table:
                     :name: Packer FIO
                     :email: fio@example.com
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
         Packager:            <%= packager.name %> <<%= packager.email %>>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               build_arch: arch64
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
         <% unless is_lib? and has_compilables? -%>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               source_files: !ruby/object:OpenStruct
                  table:
                     :0: source_file.tar
                     :1: source_file1.tar
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
         <% source_files.each_pair do |i, source_file| -%>
         Source<%= i == :"0" && (i = "") || i %>:<%= " " * [ 14 - "#{i}".size, 1 ].max %><%= source_file %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Source:              %name-%version.tar
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
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               patches: !ruby/object:OpenStruct
                  table:
                     :0: patch.patch
                     :1: patch1.patch
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
         <% patches.each_pair do |i, patch| -%>
         Patch<%= i == :"0" && (i = "") || i %>:<%= " " * [ 15 - "#{i}".size, 1 ].max %><%= patch %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               requires:
                - req >= 1
                - req_new < 0.1
                - req_newline >= 2
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
         <% requires.each do |dep| -%>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               build_requires:
                - req >= 1
                - req_new < 0.1
                - req_newline >= 2
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
         <% build_requires.each do |dep| -%>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               build_pre_requires:
                - req >= 1
                - req_new < 0.1
                - req_newline >= 2

         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
         <% build_pre_requires.each do |dep| -%>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               obsoletes:
                - req >= 1
                - req_new < 0.1
                - req_newline >= 2

         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
         <% obsoletes.each do |dep| -%>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               provides:
                - req >= 1
                - req_new < 0.1
                - req_newline >= 2

         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
         <% provides.each do |dep| -%>
         Provides:            <%= dep %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:                rpm
         Provides:            req >= 1
         Provides:            req_new < 0.1
         Provides:            req_newline >= 2
         Provides:            ruby-rpm

         """

   Scenario: Space conflicts validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources: []
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               conflicts:
                - req >= 1
                - req_new < 0.1
                - req_newline >= 2
         """
      When developer loads the space
      And he draws the template:
         """
         Name:                <%= name %>
         <% conflicts.each do |dep| -%>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               descriptions: !ruby/object:OpenStruct
                  table:
                     :'': Description Defaults
                     :'ru_RU.UTF-8': Заметка
         """
      When developer loads the space
      And he draws the template:
         """
         Name:        <%= name %>
         <% descriptions.each_pair do |cp, description| -%>
         %description<%= !cp.blank? && "         -l #{cp}" || nil %>
         <%= description %>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:        rpm
         %description
         Description Defaults
         %description         -l ru_RU.UTF-8
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               descriptions: !ruby/object:OpenStruct
                  table:
                     :'': |
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
         Name:        <%= name %>
         <% descriptions.each_pair do |cp, description| -%>
         %description<%= !cp.blank? && "         -l #{cp}" || nil %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               secondaries: !ruby/object:OpenStruct
                - !ruby/object:Setup::Spec::Rpm::Secondary
                  name: !ruby/object:Setup::Spec::Rpm::Name
                     name: rpm
                     kind: doc
                  group: Group1
                  build_arch: arch64
                  summaries: !ruby/object:OpenStruct
                     table:
                        :'': Summary Defaults
                        :'ru_RU.UTF-8': Итого
                  descriptions: !ruby/object:OpenStruct
                     table:
                        :'': Description Defaults
                        :'ru_RU.UTF-8': Заметка
         """
      When developer loads the space
      And he draws the template:
         """
         Name:          <%= name %>
         <% secondaries.each do |secondary| -%>
         %package       -n <%= secondary.name %>
         <% secondary.summaries.each_pair do |cp, summary| -%>
         Summary<%= !cp.blank? && "(#{cp})" || nil %>:<%= " " * (cp.blank? && 7 || 1 ) %><%= summary %>
         <% end -%>
         Group:         <%= secondary.group %>
         <% unless secondary.is_lib? and secondary.has_compilables? -%>
         BuildArch:     <%= secondary.build_arch %>
         <% end -%>

         <% secondary.descriptions.each_pair do |arg, description| -%>
         %description   -n <%= secondary.name %><%= !arg.blank? && " -l #{arg}" || nil %>
         <%= description %>
         <% end -%>
         <% end -%>
         """

      Then he gets the RPM spec
         """
         Name:          rpm
         %package       -n rpm-doc
         Summary:       Summary Defaults
         Summary(ru_RU.UTF-8): Итого
         Group:         Group1
         BuildArch:     arch64

         %description   -n rpm-doc
         Description Defaults
         %description   -n rpm-doc -l ru_RU.UTF-8
         Заметка

         """

   Scenario: Space stages validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         sources: []
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
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
         Name:        <%= name %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
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
         Name:        <%= name %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: rpm
                  kind: app
               file_list: |-
                  file1
                  file2
               secondaries:
                - !ruby/object:Setup::Spec::Rpm::Secondary
                     state:
                        name: !ruby/object:Setup::Spec::Rpm::Name
                           name: rpm
                           kind: doc
                        file_list: |-
                           file3
                           file4
         """
      When developer loads the space
      And he draws the template:
         """
         Name:          <%= name %>
         %files
         <%= file_list %>

         <% secondaries.each do |secondary| -%>
         %files         -n <%= secondary.name %>
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
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: "%{var}%var1"
                  kind: app
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

         Name:          <%= name %>
         """

      Then he gets the RPM spec
         """
         %define var rpm
         %define var1 2

         Name:          %{var}%var1
         """
      And stringified property "name" of space is "%{var}%var1"

   Scenario: Space macros validation for loaded spec
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  name: "%{var}%var1"
                  kind: app
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
         Name:          <%= name %>
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
         Name:          <%= name %>
         <% if has_epoch? -%>
         Epoch:         <%= epoch %>
         <% end -%>
         Version:       <%= version %>
         Release:       <%= release %>
         <% summaries.each_pair do |cp, summary| -%>
         Summary<%= !cp.blank? && "(#{cp})" || nil %>:<%= " " * (cp.blank? && 7 || 1 ) %><%= summary %>
         <% end -%>
         License:       <%= licenses.join(" or ") %>
         Group:         <%= group %>
         Url:           <%= uri %>
         Vcs:           <%= vcs %>
         Packager:      <%= packager.name %> <<%= packager.email %>>
         <% unless is_lib? and has_compilables? -%>
         BuildArch:     noarch
         <% end -%>

         <% source_files.each_pair do |i, source_file| -%>
         Source<%= i == :"0" && (i = "") || i %>:<%= " " * [ 8 - "#{i}".size, 1 ].max %><%= source_file %>
         <% end -%>
         <% patches.each_pair do |i, patch| -%>
         Patch<%= i == :"0" && (i = "") || i %>:<%= " " * [ 9 - "#{i}".size, 1 ].max %><%= patch %>
         <% end -%>
         <% build_pre_requires.each do |dep| -%>
         BuildRequires(pre): <%= dep %>
         <% end -%>
         <% build_requires.each do |dep| -%>
         BuildRequires: <%= dep %>
         <% end -%>

         %add_findreq_skiplist %ruby_gemslibdir/**/*
         %add_findprov_skiplist %ruby_gemslibdir/**/*
         <% requires.each do |dep| -%>
         Requires:      <%= dep %>
         <% end -%>
         <% obsoletes.each do |dep| -%>
         Obsoletes:     <%= dep %>
         <% end -%>
         <% provides.each do |dep| -%>
         Provides:      <%= dep %>
         <% end -%>
         <% conflicts.each do |dep| -%>
         Conflicts:     <%= dep %>
         <% end -%>

         <% descriptions.each_pair do |arg, description| -%>
         %description<%= !arg.blank? && "         -l #{arg}" || nil %>
         <%= description %>

         <% end -%>

         <% secondaries.each do |secondary| -%>
         %package       -n <%= secondary.name %>
         Version:       <%= secondary.version %>
         <% secondary.summaries.each_pair do |cp, summary| -%>
         Summary<%= !cp.blank? && "(#{cp})" || nil %>:<%= " " * (cp.blank? && 7 || 1 ) %><%= summary %>
         <% end -%>
         Group:         <%= secondary.group %>
         <% unless secondary.is_lib? and secondary.has_compilables? -%>
         BuildArch:     noarch
         <% end -%>

         <% secondary.descriptions.each_pair do |arg, description| -%>
         %description   -n <%= secondary.name %><%= !arg.blank? && " -l #{arg}" || nil %>
         <%= description %>

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
         <% if has_readme? %>
         %doc <%= readme %>
         <% end -%>
         %ruby_gemspec
         %ruby_gemlibdir
         <% if has_compilables? -%>
         %ruby_gemextdir
         <% end -%>

         <% secondaries.each do |secondary| -%>
         %files         -n <%= secondary.name %>
         <% if secondary.has_readme? -%>
         %doc <%= secondary.readme %>
         <% end -%>
         <% if secondary.is_lib? -%>
         %ruby_gemspecdir/<%= secondary.name %>-<%= secondary.version %>.gemspec
         %ruby_gemslibdir/<%= secondary.name %>-<%= secondary.version %>
         <% if secondary.has_compilables? -%>
         %ruby_gemsextdir/<%= secondary.name %>-<%= secondary.version %>
         <% end -%>
         <% end -%>
         <% if secondary.is_exec? -%>
         <% secondary.executables.each do |e| -%>
         %_bindir/<%= e %>
         <% end -%>
         <% end -%>
         <% if secondary.is_doc? -%>
         <% if secondary.spec.is_same_source?(secondary.source) -%>
         %ruby_gemdocdir
         <% else -%>
         %ruby_gemsdocdir/<%= secondary.source&.name %>-<%= secondary.version %>
         <% end -%>
         <% end -%>
         <% if secondary.is_devel? -%>
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
         BuildArch:     noarch

         Source:        %name-%version.tar
         BuildRequires(pre): rpm-build-ruby

         %add_findreq_skiplist %ruby_gemslibdir/**/*
         %add_findprov_skiplist %ruby_gemslibdir/**/*
         Provides:      gem(foo_boo) = 5.2

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
         - + packaged gem with Ruby Policy 2.0


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
                - foo.barke
                - foo_bazeeq
                - foo-barzerq
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
         Name:          <%= name %>
         <% if has_epoch? -%>
         Epoch:         <%= epoch %>
         <% end -%>
         Version:       <%= version %>
         Release:       <%= release %>
         <% summaries.each_pair do |cp, summary| -%>
         Summary<%= !cp.blank? && "(#{cp})" || nil %>:<%= " " * (cp.blank? && 7 || 1 ) %><%= summary %>
         <% end -%>
         License:       <%= licenses.join(" or ") %>
         Group:         <%= group %>
         Url:           <%= uri %>
         Vcs:           <%= vcs %>
         Packager:      <%= packager.name %> <<%= packager.email %>>
         <% unless is_lib? and has_compilables? -%>
         BuildArch:     noarch
         <% end -%>

         <% source_files.each_pair do |i, source_file| -%>
         Source<%= i == :"0" && (i = "") || i %>:<%= " " * [ 8 - "#{i}".size, 1 ].max %><%= source_file %>
         <% end -%>
         <% patches.each_pair do |i, patch| -%>
         Patch<%= i == :"0" && (i = "") || i %>:<%= " " * [ 9 - "#{i}".size, 1 ].max %><%= patch %>
         <% end -%>
         <% build_pre_requires.each do |dep| -%>
         BuildRequires(pre): <%= dep %>
         <% end -%>
         <% build_requires.each do |dep| -%>
         BuildRequires: <%= dep %>
         <% end -%>

         %add_findreq_skiplist %ruby_gemslibdir/**/*
         %add_findprov_skiplist %ruby_gemslibdir/**/*
         <% requires.each do |dep| -%>
         Requires:      <%= dep %>
         <% end -%>
         <% obsoletes.each do |dep| -%>
         Obsoletes:     <%= dep %>
         <% end -%>
         <% provides.each do |dep| -%>
         Provides:      <%= dep %>
         <% end -%>
         <% conflicts.each do |dep| -%>
         Conflicts:     <%= dep %>
         <% end -%>

         <% descriptions.each_pair do |arg, description| -%>
         %description<%= !arg.blank? && "         -l #{arg}" || nil %>
         <%= description %>
         <% end -%>


         <% secondaries.each do |secondary| -%>
         %package       -n <%= secondary.name %>
         Version:       <%= secondary.version %>
         <% secondary.summaries.each_pair do |cp, summary| -%>
         Summary<%= !cp.blank? && "(#{cp})" || nil %>:<%= " " * (cp.blank? && 7 || 1 ) %><%= summary %>
         <% end -%>
         Group:         <%= secondary.group %>
         <% unless secondary.is_lib? and secondary.has_compilables? -%>
         BuildArch:     noarch
         <% end -%>

         <% secondary.descriptions.each_pair do |arg, description| -%>
         %description   -n <%= secondary.name %><%= !arg.blank? && " -l #{arg}" || nil %>
         <%= description %>

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
         <% if has_compilables? -%>
         %ruby_gemextdir
         <% end -%>

         <% secondaries.each do |secondary| -%>
         %files         -n <%= secondary.name %>
         <% if secondary.has_readme? -%>
         %doc <%= secondary.readme %>
         <% end -%>
         <% if secondary.is_lib? -%>
         %ruby_gemspecdir/<%= secondary.name %>-<%= secondary.version %>.gemspec
         %ruby_gemslibdir/<%= secondary.name %>-<%= secondary.version %>
         <% if secondary.has_compilables? -%>
         %ruby_gemsextdir/<%= secondary.name %>-<%= secondary.version %>
         <% end -%>
         <% end -%>
         <% if secondary.is_exec? -%>
         <% secondary.executables.each do |e| -%>
         %_bindir/<%= e %>
         <% end -%>
         <% end -%>
         <% if secondary.is_doc? -%>
         <% if secondary.spec.is_same_source?(secondary.source) -%>
         %ruby_gemdocdir
         <% else -%>
         %ruby_gemsdocdir/<%= secondary.source&.name %>-<%= secondary.version %>
         <% end -%>
         <% end -%>
         <% if secondary.is_devel? -%>
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

         %add_findreq_skiplist %ruby_gemslibdir/**/*
         %add_findprov_skiplist %ruby_gemslibdir/**/*
         Requires:      gem(b_oofoo) = 5.2.4.4
         Provides:      gem(foo_boo) = 5.2

         %description
         Foo Boo gem


         %package       -n foo-ba
         Version:       5.2
         Summary:       Foo Boo gem summary executable(s)
         Summary(ru_RU.UTF-8): Исполнямка для самоцвета foo_boo
         Group:         Development
         BuildArch:     noarch

         %description   -n foo-ba
         Foo Boo gem summary executable(s).

         Foo Boo gem

         %description   -n foo-ba -l ru_RU.UTF-8
         Исполнямка для самоцвета foo_boo.


         %package       -n gem-foo-boo-doc
         Version:       5.2
         Summary:       Foo Boo gem summary documentation files
         Summary(ru_RU.UTF-8): Файлы сведений для самоцвета foo_boo
         Group:         Development/Documentation
         BuildArch:     noarch

         %description   -n gem-foo-boo-doc
         Foo Boo gem summary documentation files.

         Foo Boo gem

         %description   -n gem-foo-boo-doc -l ru_RU.UTF-8
         Файлы сведений для самоцвета foo_boo.


         %package       -n gem-foo-boo-devel
         Version:       5.2
         Summary:       Foo Boo gem summary development package
         Summary(ru_RU.UTF-8): Файлы для разработки самоцвета foo_boo
         Group:         Development/Ruby
         BuildArch:     noarch

         %description   -n gem-foo-boo-devel
         Foo Boo gem summary development package.

         Foo Boo gem

         %description   -n gem-foo-boo-devel -l ru_RU.UTF-8
         Файлы для разработки самоцвета foo_boo.


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

         %files         -n foo-ba
         %doc readme.md
         %_bindir/foo.barke
         %_bindir/foo_bazeeq
         %_bindir/foo-barzerq

         %files         -n gem-foo-boo-doc
         %doc readme.md
         %ruby_gemdocdir

         %files         -n gem-foo-boo-devel
         %doc readme.md


         %changelog
         * Mon Jan 01 2001 Spec Author <author@example.org> 5.2-alt1
         - + packaged gem with Ruby Policy 2.0


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
                - README.md
                - LICENSE.txt
                - CHANGELOG.md
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
               summary: Foo boo Ext gem
               test_files: []
         """
      When developer loads the space
      And developer locks the time to "01.01.2001"
      And developer draws the template:
         """
         <% if has_comment? -%>
         <%= comment -%>

         <% end -%>
         Name:          <%= name %>
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
         Packager:      <%= packager.name %> <<%= packager.email %>>
         <% unless is_lib? and has_compilables? -%>
         BuildArch:     noarch
         <% end -%>

         <% source_files.each_pair do |i, source_file| -%>
         Source<%= i == :"0" && (i = "") || i %>:<%= " " * [ 8 - "#{i}".size, 1 ].max %><%= source_file %>
         <% end -%>
         <% patches.each_pair do |i, patch| -%>
         Patch<%= i == :"0" && (i = "") || i %>:<%= " " * [ 9 - "#{i}".size, 1 ].max %><%= patch %>
         <% end -%>
         <% build_pre_requires.each do |dep| -%>
         BuildRequires(pre): <%= dep %>
         <% end -%>
         <% build_requires.each do |dep| -%>
         BuildRequires: <%= dep %>
         <% end -%>

         %add_findreq_skiplist %ruby_gemslibdir/**/*
         %add_findprov_skiplist %ruby_gemslibdir/**/*
         <% requires.each do |dep| -%>
         Requires:      <%= dep %>
         <% end -%>
         <% obsoletes.each do |dep| -%>
         Obsoletes:     <%= dep %>
         <% end -%>
         <% provides.each do |dep| -%>
         Provides:      <%= dep %>
         <% end -%>
         <% conflicts.each do |dep| -%>
         Conflicts:     <%= dep %>
         <% end -%>

         <% descriptions.each_pair do |arg, description| -%>
         %description<%= !arg.blank? && "         -l #{arg}" || nil %>
         <%= description %>
         <% end -%>

         <% secondaries.each do |secondary| -%>
         %package       -n <%= secondary.name %>
         Version:       <%= secondary.version %>
         <% secondary.summaries.each_pair do |cp, summary| -%>
         Summary<%= !cp.blank? && "(#{cp})" || nil %>:<%= " " * (cp.blank? && 7 || 1 ) %><%= summary %>
         <% end -%>
         Group:         <%= secondary.group %>
         <% unless secondary.is_lib? and secondary.has_compilables? -%>
         BuildArch:     noarch
         <% end -%>

         <% secondary.requires.each do |dep| -%>
         Requires:      <%= dep %>
         <% end -%>
         <% secondary.obsoletes.each do |dep| -%>
         Obsoletes:     <%= dep %>
         <% end -%>
         <% secondary.provides.each do |dep| -%>
         Provides:      <%= dep %>
         <% end -%>
         <% secondary.conflicts.each do |dep| -%>
         Conflicts:     <%= dep %>
         <% end -%>

         <% secondary.descriptions.each_pair do |arg, description| -%>
         %description   -n <%= secondary.name %><%= !arg.blank? && " -l #{arg}" || nil %>
         <%= description %>

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
         <% if has_compilables? -%>
         %ruby_gemextdir
         <% end -%>

         <% secondaries.each do |secondary| -%>
         %files         -n <%= secondary.name %>
         <% if secondary.has_readme? -%>
         %doc <%= secondary.readme %>
         <% end -%>
         <% if secondary.is_lib? -%>
         %ruby_gemspecdir/<%= secondary.of_source(:name) %>-<%= secondary.version %>.gemspec
         %ruby_gemslibdir/<%= secondary.of_source(:name) %>-<%= secondary.version %>
         <% if secondary.has_compilables? -%>
         %ruby_gemsextdir/<%= secondary.of_source(:name) %>-<%= secondary.version %>
         <% end -%>
         <% end -%>
         <% if secondary.is_exec? -%>
         <% secondary.executables.each do |e| -%>
         %_bindir/<%= e %>
         <% end -%>
         <% end -%>
         <% if secondary.is_doc? -%>
         <% if secondary.spec.is_same_source?(secondary.source) -%>
         %ruby_gemdocdir
         <% else -%>
         %ruby_gemsdocdir/<%= secondary.of_source(:name) %>-<%= secondary.version %>
         <% end -%>
         <% end -%>
         <% if secondary.is_devel? -%>
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
         BuildArch:     noarch

         Source:        %name-%version.tar
         BuildRequires(pre): rpm-build-ruby
         BuildRequires: gem(b_oofoo) = 5.2.4.4
         BuildRequires: gem(b_oofoo_dev) >= 5.2.4

         %add_findreq_skiplist %ruby_gemslibdir/**/*
         %add_findprov_skiplist %ruby_gemslibdir/**/*
         Requires:      gem(b_oofoo) = 5.2.4.4
         Provides:      gem(foo_boo) = 5.2

         %description
         Foo Boo gem

         %package       -n gem-foo-boo-ext
         Version:       1.1.7
         Summary:       Foo boo Ext gem
         Group:         Development/Ruby

         Requires:      gem(foo_boo) = 5.2
         Provides:      gem(foo_boo_ext) = 1.1.7

         %description   -n gem-foo-boo-ext
         Foo boo Ext gem desc


         %package       -n foo-boo-ext
         Version:       1.1.7
         Summary:       Foo boo Ext gem executable(s)
         Summary(ru_RU.UTF-8): Исполнямка для самоцвета foo_boo_ext
         Group:         Development
         BuildArch:     noarch

         Requires:      gem(foo_boo_ext) = 1.1.7

         %description   -n foo-boo-ext
         Foo boo Ext gem executable(s).

         Foo boo Ext gem desc

         %description   -n foo-boo-ext -l ru_RU.UTF-8
         Исполнямка для самоцвета foo_boo_ext.


         %package       -n gem-foo-boo-ext-doc
         Version:       1.1.7
         Summary:       Foo boo Ext gem documentation files
         Summary(ru_RU.UTF-8): Файлы сведений для самоцвета foo_boo_ext
         Group:         Development/Documentation
         BuildArch:     noarch

         Requires:      gem(foo_boo_ext) = 1.1.7

         %description   -n gem-foo-boo-ext-doc
         Foo boo Ext gem documentation files.

         Foo boo Ext gem desc

         %description   -n gem-foo-boo-ext-doc -l ru_RU.UTF-8
         Файлы сведений для самоцвета foo_boo_ext.


         %package       -n gem-foo-boo-ext-devel
         Version:       1.1.7
         Summary:       Foo boo Ext gem development package
         Summary(ru_RU.UTF-8): Файлы для разработки самоцвета foo_boo_ext
         Group:         Development/Ruby
         BuildArch:     noarch

         Requires:      gem(foo_boo_ext) = 1.1.7
         Requires:      gem(b_oofoo_dev) >= 5.2.4

         %description   -n gem-foo-boo-ext-devel
         Foo boo Ext gem development package.

         Foo boo Ext gem desc

         %description   -n gem-foo-boo-ext-devel -l ru_RU.UTF-8
         Файлы для разработки самоцвета foo_boo_ext.


         %package       -n foo
         Version:       5.2
         Summary:       Foo Boo gem summary executable(s)
         Summary(ru_RU.UTF-8): Исполнямка для самоцвета foo_boo
         Group:         Development
         BuildArch:     noarch

         Requires:      gem(foo_boo) = 5.2

         %description   -n foo
         Foo Boo gem summary executable(s).

         Foo Boo gem

         %description   -n foo -l ru_RU.UTF-8
         Исполнямка для самоцвета foo_boo.


         %package       -n gem-foo-boo-doc
         Version:       5.2
         Summary:       Foo Boo gem summary documentation files
         Summary(ru_RU.UTF-8): Файлы сведений для самоцвета foo_boo
         Group:         Development/Documentation
         BuildArch:     noarch

         Requires:      gem(foo_boo) = 5.2

         %description   -n gem-foo-boo-doc
         Foo Boo gem summary documentation files.

         Foo Boo gem

         %description   -n gem-foo-boo-doc -l ru_RU.UTF-8
         Файлы сведений для самоцвета foo_boo.


         %package       -n gem-foo-boo-devel
         Version:       5.2
         Summary:       Foo Boo gem summary development package
         Summary(ru_RU.UTF-8): Файлы для разработки самоцвета foo_boo
         Group:         Development/Ruby
         BuildArch:     noarch

         Requires:      gem(foo_boo) = 5.2

         %description   -n gem-foo-boo-devel
         Foo Boo gem summary development package.

         Foo Boo gem

         %description   -n gem-foo-boo-devel -l ru_RU.UTF-8
         Файлы для разработки самоцвета foo_boo.


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
         %doc README.md
         %_bindir/foo_boo_ext

         %files         -n gem-foo-boo-ext-doc
         %doc README.md
         %ruby_gemsdocdir/foo_boo_ext-1.1.7

         %files         -n gem-foo-boo-ext-devel
         %doc README.md
         %ruby_includedir/*

         %files         -n foo
         %doc readme.md
         %_bindir/foo

         %files         -n gem-foo-boo-doc
         %doc readme.md
         %ruby_gemdocdir

         %files         -n gem-foo-boo-devel
         %doc readme.md


         %changelog
         * Mon Jan 01 2001 Spec Author <author@example.org> 5.2-alt1
         - + packaged gem with Ruby Policy 2.0


         """

   Scenario: Space gem pure source render validation with predefined spec to
         a few gems with renaming
      Given space file:
         """
         ---
         spec_type: rpm
         rootdir: /path/to/dot/space/rootname
         spec: |
            --- !ruby/object:Setup::Spec::Rpm
            state:
               name: !ruby/object:Setup::Spec::Rpm::Name
                  aliases: foo-boo
                  prefix: ruby
                  name: foo_boo
                  kind: lib
               version: !ruby/object:Gem::Version
                  version: "1.1"
               summaries: !ruby/object:OpenStruct
                  table:
                     :'': RPM Actual Summary
               licenses:
                - MIT
                - Ruby
               group: Group
               uri: https://path/to/soft/rpm
               packager: !ruby/object:OpenStruct
                  table:
                     :name: Spec Author
                     :email: author@example.org
               build_arch: arch64
               source_files: !ruby/object:OpenStruct
                  table:
                     :0: source_file.tar
                     :1: source_file1.tar
               patches: !ruby/object:OpenStruct
                  table:
                     :0: patch.patch
                     :1: patch1.patch
               requires:
                - req >= 1
                - gem(d) < 0.1
                - gem(e) >= 2
               build_requires:
                - gem-a >= 1
                - gem(b) < 0.1
                - gem(c) >= 2
               build_pre_requires:
                - rpm-build-nonruby
                - rpm-build-python
               obsoletes:
                - req >= 1
                - gem(p) < 0.1
               provides:
                - req >= 1
                - gem(p) < 0.1
               conflicts:
                - gem(g) >= 1
               descriptions: !ruby/object:OpenStruct
                  table:
                     :'': Description Defaults
                     :'ru_RU.UTF-8': Заметка
               prep: |-
                  setup
                  patch
               build: build
               install: install
               check: check
               secondaries:
                - !ruby/object:Setup::Spec::Rpm::Secondary
                  name: !ruby/object:Setup::Spec::Rpm::Name
                     aliases: foo-boo
                     prefix: ruby
                     suffix: doc
                     name: foo_boo
                     kind: doc
                  group: Group1
                  build_arch: noarch
                  summaries: !ruby/object:OpenStruct
                     table:
                        :'': Summary Defaults
                        :'ru_RU.UTF-8': Итого
                  descriptions: !ruby/object:OpenStruct
                     table:
                        :'': Description Defaults
                        :'ru_RU.UTF-8': Заметка
               changes:
                - !ruby/object:OpenStruct
                  table:
                     :date: "Mon Jan 01 2001"
                     :author: "FIO Packer"
                     :email: fio@example.com
                     :version: 1.0
                     :release: rc1
                     :description: "- ! of important bug"
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
                  name: c
                  requirement: !ruby/object:Gem::Requirement
                     requirements:
                      - - '>='
                        - !ruby/object:Gem::Version
                           version: "2"
                  type: :runtime
                  prerelease: false
                  version_requirements: !ruby/object:Gem::Requirement
                     requirements:
                      - - '>='
                        - !ruby/object:Gem::Version
                           version: "2"
               description: 'Foo Boo gem'
               email: boo@example.com
               extensions:
                - ext/foo-boo-ext/extconf.rb
               extra_rdoc_files: []
               files:
                - CHANGELOG.md
                - MIT-LICENSE
                - exe/foo
                - lib/foo.rb
                - ext/foo-boo-ext/foo.c
                - ext/foo-boo-ext/foo.h
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
      And developer locks the time to "02.01.2001"
      And developer draws the template:
         """
         <% if source.is_a?(Setup::Source::Gem) -%>
         %define        gemname <%= source.name %>

         <% end -%>
         <% if has_comment? -%>
         <%= comment -%>

         <% end -%>
         Name:          <%= name %>
         <% if has_epoch? -%>
         Epoch:         <%= epoch %>
         <% end -%>
         Version:       <%= version %>
         Release:       <%= release %>
         <% summaries.each_pair do |cp, summary| -%>
         Summary<%= !cp.blank? && "(#{cp})" || nil %>:<%= " " * (cp.blank? && 7 || 1 ) %><%= summary %>
         <% end -%>
         License:       <%= licenses.join(" or ") %>
         Group:         <%= group %>
         Url:           <%= uri %>
         <% if has_vcs? -%>
         Vcs:           <%= vcs %>
         <% end -%>
         Packager:      <%= packager.name %> <<%= packager.email %>>
         <% unless is_lib? and has_compilables? -%>
         BuildArch:     <%= build_arch %>
         <% end -%>

         <% source_files.each_pair do |i, source_file| -%>
         Source<%= i == :"0" && (i = "") || i %>:<%= " " * [ 8 - "#{i}".size, 1 ].max %><%= source_file %>
         <% end -%>
         <% patches.each_pair do |i, patch| -%>
         Patch<%= i == :"0" && (i = "") || i %>:<%= " " * [ 9 - "#{i}".size, 1 ].max %><%= patch %>
         <% end -%>
         <% build_pre_requires.each do |dep| -%>
         BuildRequires(pre): <%= dep %>
         <% end -%>
         <% build_requires.each do |dep| -%>
         BuildRequires: <%= dep %>
         <% end -%>

         %add_findreq_skiplist %ruby_gemslibdir/**/*
         %add_findprov_skiplist %ruby_gemslibdir/**/*
         <% requires.each do |dep| -%>
         Requires:      <%= dep %>
         <% end -%>
         <% obsoletes.each do |dep| -%>
         Obsoletes:     <%= dep %>
         <% end -%>
         <% provides.each do |dep| -%>
         Provides:      <%= dep %>
         <% end -%>
         <% conflicts.each do |dep| -%>
         Conflicts:     <%= dep %>
         <% end -%>

         <% descriptions.each_pair do |cp, description| -%>
         %description<%= !cp.blank? && "         -l #{cp}" || nil %>
         <%= description %>

         <% end -%>

         <% secondaries.each do |secondary| -%>
         %package       -n <%= secondary.name %>
         Version:       <%= secondary.version %>
         <% secondary.summaries.each_pair do |cp, summary| -%>
         Summary<%= !cp.blank? && "(#{cp})" || nil %>:<%= " " * (cp.blank? && 7 || 1 ) %><%= summary %>
         <% end -%>
         Group:         <%= secondary.group %>
         <% unless secondary.is_lib? and secondary.has_compilables? -%>
         BuildArch:     <%= secondary.build_arch %>
         <% end -%>

         <% descriptions.each_pair do |arg, description| -%>
         %description   -n <%= secondary.name %><%= !arg.blank? && " -l #{arg}" || nil %>
         <%= description %>

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
         <% if has_compilables? -%>
         %ruby_gemextdir
         <% end -%>

         <% secondaries.each do |secondary| -%>
         %files         -n <%= secondary.name %>
         <% if secondary.has_readme? -%>
         %doc <%= secondary.readme %>
         <% end -%>
         <% if secondary.is_lib? -%>
         %ruby_gemspecdir/<%= secondary.name %>-<%= secondary.version %>.gemspec
         %ruby_gemslibdir/<%= secondary.name %>-<%= secondary.version %>
         <% if secondary.has_compilables? -%>
         %ruby_gemsextdir/<%= secondary.name %>-<%= secondary.version %>
         <% end -%>
         <% end -%>
         <% if secondary.is_exec? -%>
         <% secondary.executables.each do |e| -%>
         %_bindir/<%= e %>
         <% end -%>
         <% end -%>
         <% if secondary.is_doc? -%>
         <% if secondary.spec.is_same_source?(secondary.source) -%>
         %ruby_gemdocdir
         <% else -%>
         %ruby_gemsdocdir/<%= secondary.source&.name %>-<%= secondary.version %>
         <% end -%>
         <% end -%>
         <% if secondary.is_devel? -%>
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
         %define        gemname foo_boo

         Name:          gem-foo-boo
         Version:       5.2
         Release:       alt1
         Summary:       RPM Actual Summary
         License:       MIT or GPLv2
         Group:         Group
         Url:           https://path/to/soft/rpm
         Vcs:           https://github.com/foo/fooboo/tree/v5.2.4.4/fooboo.git
         Packager:      Spec Author <author@example.org>

         Source:        %name-%version.tar
         Source1:       source_file1.tar
         Patch:         patch.patch
         Patch1:        patch1.patch
         BuildRequires(pre): rpm-build-ruby
         BuildRequires(pre): rpm-build-nonruby
         BuildRequires(pre): rpm-build-python
         BuildRequires: gem-a >= 1
         BuildRequires: gem(c) >= 2

         %add_findreq_skiplist %ruby_gemslibdir/**/*
         %add_findprov_skiplist %ruby_gemslibdir/**/*
         Requires:      gem(c) >= 2
         Requires:      req >= 1
         Obsoletes:     ruby-foo_boo < %EVR
         Obsoletes:     req >= 1
         Obsoletes:     gem(p) < 0.1
         Provides:      ruby-foo_boo = %EVR
         Provides:      req >= 1
         Provides:      gem(p) < 0.1
         Provides:      gem(foo_boo) = 5.2
         Conflicts:     gem(g) >= 1

         %description
         Description Defaults

         %description         -l ru_RU.UTF-8
         Заметка


         %package       -n gem-foo-boo-doc
         Version:       5.2
         Summary:       Summary Defaults
         Summary(ru_RU.UTF-8): Итого
         Group:         Group1
         BuildArch:     noarch

         %description   -n gem-foo-boo-doc
         Description Defaults

         %description   -n gem-foo-boo-doc -l ru_RU.UTF-8
         Заметка


         %package       -n gem-foo-boo-devel
         Version:       5.2
         Summary:       Foo Boo gem summary development package
         Summary(ru_RU.UTF-8): Файлы для разработки самоцвета foo_boo
         Group:         Development/Ruby
         BuildArch:     noarch

         %description   -n gem-foo-boo-devel
         Description Defaults

         %description   -n gem-foo-boo-devel -l ru_RU.UTF-8
         Заметка


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
         %ruby_gemextdir

         %files         -n gem-foo-boo-doc
         %ruby_gemdocdir

         %files         -n gem-foo-boo-devel
         %ruby_includedir/*


         %changelog
         * Tue Jan 02 2001 Spec Author <author@example.org> 5.2-alt1
         - ^ 1.1 -> 5.2

         * Mon Jan 01 2001 FIO Packer <fio@example.com> 1.0-rc1
         - ! of important bug


         """


