@actor @spec
Feature: RPM Name module for Spec actor testing

   Scenario: PRM Name for library package validation
      Given an full name:
         """
         ruby-foo_bar.baz
         """
      When developer applies to parse the names with Name class
      Then he get name parsed as:
         | kind      | lib                            |
         | name      | foo_bar.baz                    |
         | aliases   | [ruby-foo_bar.baz,foo-bar-baz] |
         | suffix    |                                |
         | prefix    | ruby                           |

   Scenario: PRM Name for doc package validation
      Given an full name:
         """
         ruby-foo_bar.baz-doc
         """
      When developer applies to parse the names with Name class
      Then he get name parsed as:
         | kind      | doc                            |
         | name      | foo_bar.baz                    |
         | aliases   | [ruby-foo_bar.baz,foo-bar-baz] |
         | suffix    | doc                            |
         | prefix    | ruby                           |

   Scenario: PRM Name for devel package validation
      Given an full name:
         """
         gem-foo_bar.baz-devel
         """
      When developer applies to parse the names with Name class
      Then he get name parsed as:
         | kind      | devel                          |
         | name      | foo_bar.baz                    |
         | aliases   | [gem-foo_bar.baz,foo-bar-baz]  |
         | suffix    | devel                          |
         | prefix    | gem                            |

   Scenario: PRM Name for executable package validation
      Given an full name:
         """
         foo_bar.baz
         """
      When developer applies to parse the names with Name class
      And the name has support name object:
         | name      | foo_bar.baz  |
         | suffix    |              |
         | prefix    | gem          |
      Then he get name parsed as:
         | kind      | exec                        |
         | name      | foo_bar.baz                 |
         | aliases   | [foo_bar.baz,foo-bar-baz]   |
         | suffix    |                             |
         | prefix    |                             |

   Scenario: PRM Name for application package validation
      Given an full name:
         """
         foo_bar.baz
         """
      When developer applies to parse the names with Name class
      Then he get name parsed as:
         | kind      | app                         |
         | name      | foo_bar.baz                 |
         | aliases   | [foo_bar.baz,foo-bar-baz]   |
         | suffix    |                             |
         | prefix    |                             |

   Scenario: PRM Name object succeed match validation
      Given an full name:
         """
         gem-foo_bar.baz
         """
      And an full name:
         """
         ruby-foo-bar_baz
         """
      When developer applies to parse the names with Name class
      Then the names are fully matched:

   Scenario: PRM Name object partly succeed match validation
      Given an full name:
         """
         gem-foo_bar.baz-doc
         """
      And an full name:
         """
         ruby-foo-bar_baz
         """
      When developer applies to parse the names with Name class
      Then the names are matched in part of "name"
      And the names are not matched in part of "kind"

   Scenario: PRM Name object failed match validation
      Given an full name:
         """
         gem-foo_bar.baz-doc
         """
      And an full name:
         """
         ruby-foo-bar_baz
         """
      When developer applies to parse the names with Name class
      Then the names are fully not matched

   Scenario: PRM Name for validation
      Given an full name:
         """
         ruby-foo_bar.baz
         """
      When developer applies to parse the names with Name class
      Then the name's full name is :
         """
         gem-foo-bar-baz
         """
