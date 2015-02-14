# Alcove [![Gem Version](https://badge.fury.io/rb/alcove.svg)](http://badge.fury.io/rb/alcove) [![Build Status](https://travis-ci.org/ioveracker/Alcove.svg?branch=master)](https://travis-ci.org/ioveracker/Alcove)
Painless code coverage reporting for Objective-C projects.   Most of the heavy lifting is done by the venerable lcov.  Alcove simply searches the nooks and crannies to collect the data needed to generate the report and ties everything together for you.  Best of all, it's a gem with minimal depedencies, so installation is quick and painless.

## Installation

    $ gem install alcove
    
If you don't have it already, you'll also need to install lcov.

*Homebrew*

    $ brew install lcov

*MacPorts*

    $ sudo port install lcov

## Xcode Project Configuration
If you haven't already, open your project in Xcode and update your non-test targets to Generate Test Coverage Files and Instrument Program Flow *for Debug configuration only*).
![Xcode](http://i.imgur.com/xdcg4er.png?1)

## Generating Reports
Now that you have the prerequisites out of the way, you can generate a report.  Make sure you've recently executed your tests, then:

    alcove --product-name <your-product-name>

Be sure to check out the --help for additional options for fine-tuning your report.

## Options

### --output-directory
Specify this option to change the output directory for the report.  Any intermediate paths will be created.

### --product-name
The product name specified in your Xcode project.

### --remove-filter
A list of filters to use when gathering files for the report.  Use this if you want to exclude certain files from the report.  For example: `alcove --product-name SampleProduct --remove-filter *.h,main.m` will exclude header files and the main.m file from the report.

### --search-directory
Use this option to specify the directory to be searched for your product.  Alcove plays nicely with the the structure on your development machine, as well as on an Xcode Server, but if you have some funky output directory for your build, you can specify its parent here.

## Attribution
Shoutout to [@NateBank](https://github.com/NateBank) for the [name suggestion](https://www.youtube.com/watch?v=j1Q-a5zCmhc).
