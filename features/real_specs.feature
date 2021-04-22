@actor @spec
Feature: Spec actor

   Scenario: Apply the Spec actor to setup
      Given a spec from fixture "ucf"
      When developer loads the spec
      And developer locks the time to "21.04.2021"
      And he sets the space option "rootdir" to fixture "ucf"
      And he sets the space option "maintainer_name" to "Pavel Skrylev"
      And he sets the space option "maintainer_email" to "majioa@altlinux.org"
      And he applies "spec" actor to the setup
      Then he acquires an "ucf" fixture spec for the setup

