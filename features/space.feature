@actor @spec
Feature: Space

   Scenario: Space root validation
      Given space file:
         """
         ---
         rootdir: "/path/to/dot/space"
         """

      When developer loads the space
      Then he sees that space's "rootdir" is a "/path/to/dot/space"

   Scenario: Space name validation
      #  When draw the template:
      #  """
      #   Name:          <%= pkgname %>
      #   """


