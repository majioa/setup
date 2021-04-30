@rpm @spec
Feature: RPM Spec

   Scenario: Parse RPM Spec for Name
      Given blank space with empty sources
      And RPM spec file:
         """
         Name:                rpm
         """
      When developer loads the spec into the space
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then stringified property "name" of space is "rpm"

   Scenario: Parse RPM Spec for Version
      Given blank space with empty sources
      And RPM spec file:
         """
         Name:                rpm
         Version:             1.1
         """
      When developer loads the spec into the space
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then stringified property "version" of space is "1.1"

   Scenario: Parse RPM Spec for epoch
      Given RPM spec file:
         """
         Name:                rpm
         Epoch:               1
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "epoch" of space is "1"

   Scenario: Parse RPM Spec for summary
      Given RPM spec file:
         """
         Name:                rpm
         Summary:             RPM Summary
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "summaries" of space with no argument is "RPM Summary"

   Scenario: Parse RPM Spec for release
      Given RPM spec file:
         """
         Name:                rpm
         Release:             rc1
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "release" of space is "rc1"

   Scenario: Parse RPM Spec for a license
      Given blank space with empty sources
      And RPM spec file:
         """
         Name:                rpm
         License:             MIT or GPLv2 / Ruby
         """
      When developer loads the spec into the space
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "licenses" of space has "MIT"
      And property "licenses" of space has "GPLv2"
      And property "licenses" of space has "Ruby"

   Scenario: Parse RPM Spec for a group
      Given RPM spec file:
         """
         Name:                rpm
         Group:               Group
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "group" of space is "Group"

   Scenario: Parse RPM Spec for an URL
      Given RPM spec file:
         """
         Name:                rpm
         Url:                 https://path/to/soft/rpm
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "uri" of space is "https://path/to/soft/rpm"

   Scenario: Parse RPM Spec for a VCS
      Given RPM spec file:
         """
         Name:                rpm
         Vcs:                 https://path/to/vcs/rpm
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "vcs" of space is "https://path/to/vcs/rpm.git"

   Scenario: Parse RPM Spec for a packager
      Given RPM spec file:
         """
         Name:                rpm
         Packager:            Packer FIO <fio@example.com>
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then space's property "packager" with argument "name" has text:
         """
         Packer FIO
         """
      And space's property "packager" with argument "email" has text:
         """
         fio@example.com
         """

   Scenario: Parse RPM Spec for a build architecture
      Given RPM spec file:
         """
         Name:                rpm
         BuildArch:           arch64
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "build_arch" of space is "arch64"

   Scenario: Parse RPM Spec for Source
      Given RPM spec file:
         """
         Name:                rpm
         Source:              source_file.tar
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "source_files" of space has "%name-%version.tar"

   Scenario: Parse RPM Spec for many sources
      Given RPM spec file:
         """
         Name:                rpm
         Source0:             source_file.tar
         Source1:             source_file1.tar
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "source_files" of space has "%name-%version.tar" at position "0"
      And property "source_files" of space has "source_file1.tar" at position "1"

   Scenario: Parse RPM Spec for patch
      Given RPM spec file:
         """
         Name:                rpm
         Patch:               patch.patch
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "patches" of space has "patch.patch"

   Scenario: Parse RPM Spec for many patches
      Given RPM spec file:
         """
         Name:                rpm
         Patch:               patch.patch
         Patch1:              patch1.patch
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "patches" of space has "patch.patch" at position "0"
      And property "patches" of space has "patch1.patch" at position "1"

   Scenario: Parse RPM Spec for requires
      Given RPM spec file:
         """
         Name:                rpm
         Requires:            req >= 1 req_new < 0.1
         Requires:            req_newline >= 2
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "requires" of space has "req >= 1" at position "0"
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
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "build_requires" of space has "req >= 1" at position "0"
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
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "build_pre_requires" of space has "req >= 1" at position "0"
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
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "obsoletes" of space has "req >= 1" at position "0"
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
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "provides" of space has "req >= 1" at position "0"
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
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "conflicts" of space has "req >= 1" at position "0"
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
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "descriptions" of space with no argument is:
         """
         Multiline Description

         Of

         The

         RPM

         Spec
         """

   Scenario: Parse RPM Spec for description with a code page
      Given RPM spec file:
         """
         Name:                rpm
         %description         -l ru_RU.UTF-8
         Многострочная
         Заметка
         РПМ

         Спека
         * текст1
         - текст2
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then space's property "descriptions" with argument "ru_RU.UTF-8" has text:
         """
         Многострочная Заметка РПМ

         Спека
         * текст1
         - текст2
         """

   Scenario: Parse RPM Spec for an additional package with a code page
      Given RPM spec file:
         """
         Name:                rpm
         Summary:             RPM Summary

         %package             doc
         Summary:             Doc Summary
         Summary(ru_RU.UTF-8): Итого Доки
         Group:               Group1
         BuildArch:           arch64

         %description         doc
         Doc Desc.

         %description         doc -l ru_RU.UTF-8
         Описание Доков
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then secondary spec with full name "rpm-doc" has fields:
         | name         | rpm-doc   |
         | group        | Group1    |
         | build_arch   | arch64    |
      And the subfield "descriptions" with argument "ru_RU.UTF-8" of secondary spec with full name "rpm-doc" has data:
         """
         Описание Доков
         """
      And the subfield "descriptions" with no argument of secondary spec with full name "rpm-doc" has data:
         """
         Doc Desc.
         """
      And the subfield "summaries" with argument "ru_RU.UTF-8" of secondary spec with full name "rpm-doc" has data:
         """
         Итого Доки
         """
      And the subfield "summaries" with no argument of secondary spec with full name "rpm-doc" has data:
         """
         Doc Summary
         """

   Scenario: Parse RPM Spec for stages
      Given RPM spec file:
         """
         Name:                rpm
         %prep
         setup
         patch

         %build
         build

         %install
         install

         %check
         check
         """
      When developer loads the spec
      Then space's property "prep" has data:
         """
         setup
         patch
         """
      And space's property "build" has data:
         """
         build
         """
      And space's property "install" has data:
         """
         install
         """
      And space's property "check" has data:
         """
         check
         """

   Scenario: Parse RPM Spec for files sections
      Given RPM spec file:
         """
         Name:                rpm
         %package             doc
         %files
         file1
         %files               doc
         file2
         """
      When developer loads the spec
      And developer sets the space option "rootdir" to "features/fixtures/blank"
      Then property "file_list" of space has text:
         """
         file1
         """
      And the subfield "file_list" of secondary spec with full name "rpm-doc" has data:
         """
         file2
         """

   Scenario: Parse RPM Spec for changelog section
      Given RPM spec file:
         """
         Name:                rpm
         %changelog
         * Tue Jan 02 2001 FIO Packer <fio@example.com> 2.0
         - ^ new version
         * Mon Jan 01 2001 FIO Packer <fio@example.com> 1.0-rc1
         - ! of important bug
         """
      When developer loads the spec
      Then space's property "changes" at position "0" has fields:
         | date         | Mon Jan 01 2001       |
         | author       | FIO Packer            |
         | email        | fio@example.com       |
         | version      | 1.0                   |
         | release      | rc1                   |
         | description  | - ! of important bug  |
      And space's property "changes" at position "1" has fields:
         | date         | Tue Jan 02 2001       |
         | author       | FIO Packer            |
         | email        | fio@example.com       |
         | version      | 2.0                   |
         | release      |                       |
         | description  | - ^ new version       |

   Scenario: Parse RPM Spec for variables support
      Given RPM spec file:
         """
         %define var          rpm
         %global var1         2
         Name:                %{var}%var1
         """
      When developer loads the spec
      Then space's property "context" with argument "var" has text:
         """
         rpm
         """
      Then space's property "context" with argument "var1" has text:
         """
         2
         """
      Then stringified property "name" of space's spec is "rpm2"

   Scenario: Parse RPM Spec for macros support
      Given RPM spec file:
         """
         Name:                rpm
         %macro               rpmn < 1
         %macro               rpmn1 2
         %macro1              rpmn < 11
         """
      When developer loads the spec
      Then the subfield "macro" at position "0" of space's property "context" with argument "__macros" has data:
         """
         rpmn < 1
         """
      And the subfield "macro" at position "1" of space's property "context" with argument "__macros" has data:
         """
         rpmn1 2
         """
      Then the subfield "macro1" of space's property "context" with argument "__macros" has data:
         """
         rpmn < 11
         """
