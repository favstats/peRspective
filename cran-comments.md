## Release summary

This is a patch release in the 0.1 series.

## Test environments
* GitHub Actions windows-latest, r: 'release'
* GitHub Actions macOS-latest, r: 'release'
* GitHub Actions ubuntu-20.04, r: 'release'
* GitHub Actions ubuntu-20.04, r: 'devel'
* win-builder (devel and release)
* R-hub Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* R-hub Ubuntu Linux 20.04.1 LTS, R-release, GCC
* R-hub Fedora Linux, R-devel, clang, gfortran

## R CMD check results
There were no NOTEs, ERRORs or WARNINGs

## Downstream dependencies
There are currently no downstream dependencies for this package. 

## Resubmission
This is a resubmission. In this version I have:

* Turned sleeps below 0.7 intervals into a warning (rather than error) as to give more choice to the user if they have a better API quota.

* Fixed bug where it would sometimes not correctly match the `text_id` due to one variable being numeric. Now always outputs character.


