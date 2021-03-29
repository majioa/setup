@rpm @spec
Feature: RPM Spec 

   Scenario: Parse Epoch RPM Spec
      Given RPM spec file:
         """
         Name:        rpm
         Epoch:       1
         """
      When developer loads the spec
      And property "epoch" of space is "1"

