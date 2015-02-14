# Alcove [![Gem Version](https://badge.fury.io/rb/alcove.svg)](http://badge.fury.io/rb/alcove) [![Build Status](https://travis-ci.org/ioveracker/Alcove.svg?branch=master)](https://travis-ci.org/ioveracker/Alcove)
Painless code coverage reporting for Objective-C projects.   Most of the heavy lifting is done by the venerable lcov.  Alcove simply searches the nooks and crannies to collect the data needed to generate the report and ties everything together for you.  Best of all, it's a gem with minimal depedencies, so installation is quick and painless.

## Installation

    $ sudo gem install alcove
    
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
