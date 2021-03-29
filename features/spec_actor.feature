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
         Name:          <%= pkgname %>
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
         Name:          <%= pkgname %>
         Version:       <%= version %>
         """

      Then he gets the RPM spec
         """
         Name:          fooboo
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
         Name:        <%= pkgname %>
         Epoch:       <%= epoch %>
         """

      Then he gets the RPM spec
         """
         Name:        rpm
         Epoch:       1
         """

