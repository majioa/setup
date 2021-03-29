@rpm @spec
Feature: RPM Spec

   Scenario: Parse RPM Spec for Name
      Given RPM spec file:
         """
         Name:                rpm
         """
      When developer loads the spec
      And property "name" of space is "rpm"


   Scenario: Parse RPM Spec for Version
      Given RPM spec file:
         """
         Name:                rpm
         Version:             1.1
         """
      When developer loads the spec
      And property "version" of space is "1.1"

   Scenario: Parse RPM Spec for epoch
      Given RPM spec file:
         """
         Name:                rpm
         Epoch:               1
         """
      When developer loads the spec
      And property "epoch" of space is "1"

   Scenario: Parse RPM Spec for summary
      Given RPM spec file:
         """
         Name:                rpm
         Summary:             RPM Summary
         """
      When developer loads the spec
      And property "summary" of space is "RPM Summary"

   Scenario: Parse RPM Spec for release
      Given RPM spec file:
         """
         Name:                rpm
         Release:             rc1
         """
      When developer loads the spec
      And property "release" of space is "rc1"

   Scenario: Parse RPM Spec for a license
      Given RPM spec file:
         """
         Name:                rpm
         License:             MIT
         """
      When developer loads the spec
      And property "license" of space is "MIT"

   Scenario: Parse RPM Spec for a group
      Given RPM spec file:
         """
         Name:                rpm
         Group:               Group
         """
      When developer loads the spec
      And property "group" of space is "Group"

   Scenario: Parse RPM Spec for an URL
      Given RPM spec file:
         """
         Name:                rpm
         Url:                 https://path/to/soft/rpm
         """
      When developer loads the spec
      And property "url" of space is "https://path/to/soft/rpm"

   Scenario: Parse RPM Spec for a VCS
      Given RPM spec file:
         """
         Name:                rpm
         Vcs:                 https://path/to/vcs/rpm
         """
      When developer loads the spec
      And property "vcs" of space is "https://path/to/vcs/rpm"

   Scenario: Parse RPM Spec for a packager
      Given RPM spec file:
         """
         Name:                rpm
         Packager:            Packer FIO <fio@example.com>
         """
      When developer loads the spec
      And property "packager" of space is "Packer FIO <fio@example.com>"

   Scenario: Parse RPM Spec for a build architecture
      Given RPM spec file:
         """
         Name:                rpm
         BuildArch:           arch64
         """
      When developer loads the spec
      And property "build_arch" of space is "arch64"

   Scenario: Parse RPM Spec for Source
      Given RPM spec file:
         """
         Name:                rpm
         Source:              source_file.tar
         """
      When developer loads the spec
      And property "source_files" of space has "source_file.tar"

   Scenario: Parse RPM Spec for many sources
      Given RPM spec file:
         """
         Name:                rpm
         Source:              source_file.tar
         Source1:             source_file1.tar
         """
      When developer loads the spec
      And property "source_files" of space has "source_file.tar" at position "0"
      And property "source_files" of space has "source_file1.tar" at position "1"

   Scenario: Parse RPM Spec for patch
      Given RPM spec file:
         """
         Name:                rpm
         Patch:               patch.patch
         """
      When developer loads the spec
      And property "patches" of space has "patch.patch"

   Scenario: Parse RPM Spec for many patches
      Given RPM spec file:
         """
         Name:                rpm
         Patch:               patch.patch
         Patch1:              patch1.patch
         """
      When developer loads the spec
      And property "patches" of space has "patch.patch" at position "0"
      And property "patches" of space has "patch1.patch" at position "1"

   Scenario: Parse RPM Spec for requires
      Given RPM spec file:
         """
         Name:                rpm
         Requires:            req >= 1 req_new < 0.1
         Requires:            req_newline >= 2
         """
      When developer loads the spec
      And property "requires" of space has "req >= 1" at position "0"
      And property "requires" of space has "req_new < 0.1" at position "1"
      And property "requires" of space has "req_newline >= 2" at position "2"

   Scenario: Parse RPM Spec for build requires
      Given RPM spec file:
         """
         Name:                rpm
         BuildRequires:       req >= 1 req_new < 0.1
         BuildRequires:       req_newline >= 2
         """
      When developer loads the spec
      And property "build_requires" of space has "req >= 1" at position "0"
      And property "build_requires" of space has "req_new < 0.1" at position "1"
      And property "build_requires" of space has "req_newline >= 2" at position "2"

   Scenario: Parse RPM Spec for build pre-requires
      Given RPM spec file:
         """
         Name:                rpm
         BuildRequires(pre):  req >= 1 req_new < 0.1
         BuildRequires(pre):  req_newline >= 2
         """
      When developer loads the spec
      And property "build_pre_requires" of space has "req >= 1" at position "0"
      And property "build_pre_requires" of space has "req_new < 0.1" at position "1"
      And property "build_pre_requires" of space has "req_newline >= 2" at position "2"

   Scenario: Parse RPM Spec for obsoletes
      Given RPM spec file:
         """
         Name:                rpm
         Obsoletes:           req >= 1 req_new < 0.1
         Obsoletes:           req_newline >= 2
         """
      When developer loads the spec
      And property "obsoletes" of space has "req >= 1" at position "0"
      And property "obsoletes" of space has "req_new < 0.1" at position "1"
      And property "obsoletes" of space has "req_newline >= 2" at position "2"

   Scenario: Parse RPM Spec for provides
      Given RPM spec file:
         """
         Name:                rpm
         Provides:            req >= 1 req_new < 0.1
         Provides:            req_newline >= 2
         """
      When developer loads the spec
      And property "provides" of space has "req >= 1" at position "0"
      And property "provides" of space has "req_new < 0.1" at position "1"
      And property "provides" of space has "req_newline >= 2" at position "2"

   Scenario: Parse RPM Spec for conflicts
      Given RPM spec file:
         """
         Name:                rpm
         Conflicts:           req >= 1 req_new < 0.1
         Conflicts:           req_newline >= 2
         """
      When developer loads the spec
      And property "conflicts" of space has "req >= 1" at position "0"
      And property "conflicts" of space has "req_new < 0.1" at position "1"
      And property "conflicts" of space has "req_newline >= 2" at position "2"

   Scenario: Parse RPM Spec for description
      Given RPM spec file:
         """
         Name:                rpm
         %description
         Multiline
         Description
         Of
         The
         RPM
         Spec
         """
      When developer loads the spec
      And property "descriptions" of space has text:
         """
         Multiline
         Description
         Of
         The
         RPM
         Spec
         """

   Scenario: Parse RPM Spec for description with a code page
      Given RPM spec file:
         """
         Name:                rpm
         %description         -l ru_RU.UTF8
         Многострочная
         Заметка
         РПМ
         Спека
         """
      When developer loads the spec
      And space's property "descriptions" with argument "-l ru_RU.UTF8" has text:
         """
         Многострочная
         Заметка
         РПМ
         Спека
         """

