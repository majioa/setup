@cli
Feature: Setup CLI

   Scenario: Setup CLI rootdir validation
      Given blank setup CLI
      And options for Setup CLI:
         """
         --rootdir=/var/tmp
         """
      When developer loads setup.rb
      Then property "rootdir" of space is "/var/tmp"


   Scenario: Setup CLI ignore names validation
      Given blank setup CLI
      And options for Setup CLI:
         """
         --ignore-names=psych
         """
      And the default option for "rootdir" is "features/fixtures/psych"
      When developer loads setup.rb
      Then property "ignored_names" of space has "psych"
      And space's property "sources.0.spec.name" is:
         """
         psych
         """
      And property "valid_sources" of space is blank


   Scenario: Setup CLI regard names validation
      Given blank setup CLI
      And options for Setup CLI:
         """
         --ignore-names=psych --regard-names=,psych,erubis
         """
      And the default option for "rootdir" is "features/fixtures/psych"
      When developer loads setup.rb
      Then property "ignored_names" of space is blank
      And property "regarded_names" of space matches to:
         """
         psych
         erubis
         """
      And space's property "sources.0.spec.name" is:
         """
         psych
         """
      And space's property "valid_sources.0.spec.name" is:
         """
         psych
         """


   Scenario: Setup CLI output path validation
      Given blank setup CLI
      And options for Setup CLI:
         """
         --output-file=/tmp/output
         """
      When developer loads setup.rb
      Then property "output_file" of options is "/tmp/output"

   Scenario: Setup CLI spec file argument validation
      Given blank setup CLI
      And options for Setup CLI:
         """
         --spec-file=features/fixtures/default.spec
         """
      When developer loads setup.rb
      Then space's options "spec_file" is "features/fixtures/default.spec"
      And property "spec" of space is of kind "Setup::Spec::Rpm"

   Scenario: Setup CLI maintainer metadata validation
      Given blank setup CLI
      And options for Setup CLI:
         """
         --maintainer-name="Pavel Skrylev" --maintainer-email=majioa@altlinux.org
         """
      When developer loads setup.rb
      Then space's options "maintainer_name" is "Pavel Skrylev"
      And space's options "maintainer_email" is "majioa@altlinux.org"
      And property "maintainer_name" of options is "Pavel Skrylev"
      And property "maintainer_email" of options is "majioa@altlinux.org"

   Scenario: Setup CLI maintainer metadata validation
      Given blank setup CLI
      And options for Setup CLI:
         """
         --available-gem-list="features/fixtures/sample.available-gem-list.yaml"
         """
      When developer loads setup.rb
      Then space's options "available_gem_list" is:
         """
         ---
         rake: 13.0.1
         json:
          - 2.3.0
          - 2.3.1
         """
      And property "available_gem_list" of options is:
         """
         ---
         rake: 13.0.1
         json:
          - 2.3.0
          - 2.3.1
         """
