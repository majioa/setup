Feature: Install
  In order to install a Ruby project
  As a Ruby Developer
  I want to use the setup.rb install command

  Scenario: Install project to Ruby's site locations
    Given a setup.rb compliant Ruby project
    And 'setup.rb config --type=site' has been run
    And 'setup.rb make' has been run
    When I issue the command 'setup.rb install'
    Then the project's exectuables should be installed to the site_ruby bin location
    And the project's libraries should be installed to the site_ruby lib location
    And the project's extensions should be installed to the site_ruby arch location

  Scenario: Install project to standard ruby locations
    Given a setup.rb compliant Ruby project
    And 'setup.rb config --type=std' has been run
    And 'setup.rb make' has been run
    When I issue the command 'setup.rb install'
    Then the project's exectuables should be installed to the ruby bin location
    And the project's libraries should be installed to the ruby lib location
    And the project's extensions should be installed to the ruby arch location

  Scenario: Install project to XDG home locations
    Given a setup.rb compliant Ruby project
    And 'setup.rb config --type=home' has been run
    And 'setup.rb make' has been run
    When I issue the command 'setup.rb install'
    Then the project's exectuables should be installed to the home bin location
    And the project's libraries should be installed to the home lib location
    And the project's extensions should be installed to the home arch location


  Scenario: Install extensionless project to Ruby's site locations
    Given a setup.rb compliant Ruby project
    And the project does NOT have extensions
    And 'setup.rb config --type=site' has been run
    When I issue the command 'setup.rb install'
    Then the project's exectuables should be installed to the site_ruby bin location
    And the project's libraries should be installed to the site_ruby lib location

  Scenario: Install extensionless project to standard ruby locations
    Given a setup.rb compliant Ruby project
    And the project does NOT have extensions
    And 'setup.rb config --type=std' has been run
    When I issue the command 'setup.rb install'
    Then the project's exectuables should be installed to the ruby bin location
    And the project's libraries should be installed to the ruby lib location

  Scenario: Install extensionless project to XDG home locations
    Given a setup.rb compliant Ruby project
    And the project does NOT have extensions
    And 'setup.rb config --type=home' has been run
    When I issue the command 'setup.rb install'
    Then the project's exectuables should be installed to the home bin location
    And the project's libraries should be installed to the home lib location


  Scenario: Fail to install project without first running config
    Given a setup.rb compliant Ruby project
    And 'setup.rb config' has NOT been run
    When I issue the command 'setup.rb install' unprepared
    Then I will be told that I must first run 'setup.rb config'

  Scenario: Fail to install project with extensions without first running setup
    Given a setup.rb compliant Ruby project
    And 'setup.rb config' has been run
    But 'setup.rb compile' has NOT been run
    When I issue the command 'setup.rb install' unprepared
    Then I will be told that I must first run 'setup.rb compile'

