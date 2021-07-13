## Release summary

This is a minor release in the 0.1 series.

## Test environments
* local OS X install, R 3.6.0
* ubuntu 14.04 (on travis-ci), R 3.6.0
* win-builder (devel and release)
* R-hub windows-x86_64-devel (r-devel)
* R-hub ubuntu-gcc-release (r-release)
* R-hub fedora-clang-devel (r-devel)

## R CMD check results
There were no NOTEs, ERRORs or WARNINGs

## Downstream dependencies
There are currently no downstream dependencies for this package. 

## Resubmission
This is a resubmission. In this version I have:

* Turned sleeps below 0.7 intervals only into a warning as to give more choice to the user if they have a better API quota.

* Fixed a bug where it would sometimes not correctly match the `text_id` due to one being numeric. Now always outputs character


