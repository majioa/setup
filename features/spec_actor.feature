@actor @spec
Feature: Spec actor

   Scenario: Apply the Spec actor to setup
      Given default setup
      When developer applies "spec" actor to the setup
      Then he acquires a present spec for the setup
