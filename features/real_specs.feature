@actor @spec @gem
Feature: Spec actor

   @policy1_0
   Scenario: Apply the Spec actor to setup for ucf gem and old Ruby Policy 1.0 setup
      Given blank space
      And a spec from fixture "ucf"
      When developer locks the time to "21.04.2021"
      And he sets the space option "rootdir" to fixture "ucf"
      And he sets the space option "maintainer_name" to "Pavel Skrylev"
      And he sets the space option "maintainer_email" to "majioa@altlinux.org"
      And he loads the spec into the space
      And he applies "spec" actor to the setup
      Then he acquires an "ucf" fixture spec for the setup

   @policy1_0
   Scenario: Apply the Spec actor to setup for zip-container gem and old Ruby Policy 1.0 setup
      Given blank space
      And a spec from fixture "zip-container"
      When developer locks the time to "21.04.2021"
      And he sets the space option "rootdir" to fixture "zip-container"
      And he sets the space option "maintainer_name" to "Pavel Skrylev"
      And he sets the space option "maintainer_email" to "majioa@altlinux.org"
      And he loads the spec into the space
      And he applies "spec" actor to the setup
      Then he acquires an "zip-container" fixture spec for the setup

   @policy2_0
   Scenario: Apply the Spec actor to setup for rbvmomi gem and manual Ruby Policy 2.0 setup
      Given blank space
      And a spec from fixture "rbvmomi"
      When developer locks the time to "21.04.2021"
      And he sets the space options as:
         | options            | value                       |
         | rootdir            | features/fixtures/rbvmomi   |
         | maintainer_name    | Pavel Skrylev               |
         | maintainer_email   | majioa@altlinux.org         |
      And he loads the spec into the space
      And he applies "spec" actor to the setup
      Then he acquires an "rbvmomi" fixture spec for the setup

