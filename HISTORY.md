# Release History

## 5.2.0 / 2012-12-20

This release makes a couple of important changes. First the `.ruby` file
is no longer the supported metadata file. While the format is basically
the same, the file is now called `.index`. See the (Indexer)[http://github.com/rubyworks/indexer]
project for more details. One can still use `.setup/name`, `.setup/version`
and `.setup/loadpath` files instead. In addition, `.setup/testrc.rb` has been
renamed to `.setup/test.rb`, and for shell-based command use `.setup/test.sh`.

Changes:

* Use .index instead of .ruby for metadata.
* Testing is handled by either .setup/test.rb or .setup/test.sh.
* Automatic RI documentation generation is deprecated for good.


## 5.1.0 / 2012-03-20

With this release `bin/setup.rb` is now the all-in-one bundled script.
This allows **rvm** to use setup.rb across multiple rubies without having
to install it anew for each case. This release also renames the `make`
phase (previously called the `setup` phase) to `compile`, which is much 
more descriptive of it's purpose for the general user.

Changes:

* Rename `make` phase to `compile`.
* So called "MetaConfig" is handled via `.setup/metaconfig.rb`.
* The `bin/setup.rb` script is now the full-on bundled script.
* The `--prefix` option works with `all` command.


## 5.0.1 / 2010-02-07

Version 5.0.1 fixes a bug reading configuration options,
and makes some minor adjusemnt to exit error messages.

Changes:

* Fixed parsing of ruby install parameters on systems with custom configurations.
* Use 'abort $!.message' instead of 'exit 1' when exiting on error.


## 5.0.0 / 2010-01-12

Version 5 represents a major milestone in Setup.rb's development.
While the 4.x series focused on improving on aspects of the
orginal 3.4.1 code base by Minero Aoki, this version takes the next step
and reworks the entire script into an truly object-oriented design.
In so doing, the system no longer traverses project directories
one-by-one installing or compiling files as they are come across,
but instead collects a list of files to handle up front, then iterates
through them performing the required action.

Changes:

* Split script into distinct classes, one for each setup phase.
* Testing is handled by optional script/test or .setup/testrc.rb file.
* Renamed 'setup' phase to 'make' phase.
* Deprecated MetaConfig API; support singleton extensions instead.
* Deprecated support for Ruby versions older than v1.6.2.
* Returned to using InstalledFiles for record installation and improved.
* Use SetupConfig instead of .cache/setup/config to store system configuration.
* Improved configuration options (eg. can use --type instead of --installdirs)


## 4.2.1 / 2009-08-26

This release add support for multiple loadpaths. Add a list of them
to meta/loadpath, and they will be installed. For example, the is used
in Facets to install both lib/more and lib/core.

Changes:

* meta/loadpath is now supported if you have multiple paths to install.


## 4.2.0 / 2009-08-26

This release finally gets rdoc generation and doc installation working.
Note that rdoc generation is shelled-out at the moment b/c of issues with
loading the new verison of RDoc vs. the old version included with Ruby
(which bombs). In the process of doding this, all configuration files
have now been located in meta/ and meta/setup (or .meta/). See the changes
below for more details.

Changes:

* relocated all user configuration files to meta/ and meta/setup
* meta/package must exist for doc to be installed.
* meta/setup/test.rb must be provided to run tests.
* meta/setup/doc.rb can be provided as alternate for generating docs.
* meta/setup/metaconfig.rb is now where meta-configuration goes.
* documentation is installed to <system-doc-dir>/ruby-<package>/.
* documentation generation shells out (for now, b/c of issues with using API)
* Notice the setup.rb file in the project repo. Guess what that is! ;)


## 4.1.0 / 2008-11-16

Ruby Setup is a fork or Minero Aokoi's setup.rb script. Whereas setup.rb
had to be copied into every project that used it, Ruby Setup is a stand
alone application.

The API is largely the same, with a only few distinctions. Most importantly,
multi-package support has been removed. Also the underlying system has been
made more object-oriented. For instance, what was ToplevelInstaller is now
Setup::Installer. Finally configuration files are saved to .cache/setup and
metaconfig should be placed in .config/setup, rather then directly into
the root project directory.

I still consider this and "early" release of Ruby Setup, that is until enough
people put it through it's paces. However, since it is predominantly
setup.rb 3.4.1 code, and since it works well enough to install itself ;)
it certainly is a usable product.

Please report any problems so I can fix them ASAP. Thanks.

Changes:

* Testing only runs if a test script if provided
* Cache files are now stored in .cache/setup/
* Renamed binary from rubysetup to setup.rb.
  * Hoping that the use of a dot in the name is not a problem on Windows.
  * By using setup.rb for the binary, it matches exactly the name of the old script.
  * Other developers could do likewise, eg. setup.py; akin to mkfs.ext3 and friends. 
* Added script/install as a bootstrap installer.
* Restored metaconfig
* Added test from original (needs work)
* Removed test/suite.rb option from testing


## 4.0.0 / 2008-08-15

This is the first whack at making setup.rb a stand-alone application.
Basically I have reverse engineered Aoki's 3.4.1 version of setup.rb,
and then reworked some of the code to make it more modern, including 
retro-fitting it to use OptionParser. Some features of the original
are no longer supported, such a metaconfig and multi-package installs.

Changes:

* Same basic code as 3.4.1, but many parts have been refit.
* Initial checkin to git repostitory.

