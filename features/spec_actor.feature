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
          - name: subname
            rootdir: /path/to/dot/space/rootname/sub
          - name: rootname
            rootdir: /path/to/dot/space/rootname
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
