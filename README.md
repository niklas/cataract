== Welcome to Cataract

Cataract is a Rails based web-frontend to rtorrent, organizing your torrents.

Currently it is under heavy development.

[![Build Status (development)](https://travis-ci.org/niklas/cataract.png?branch=development)](https://travis-ci.org/niklas/cataract)

== Getting Started

This version is not ready for production yet.

== The Plan (TM)

 * automatically download subscribed TV shows
 * mobile-friendly interface
 * out-of-box working installation procedure

 == Installation Notes
 The following will be implemented as puppet manifests, but for now we just note the specialities here

 * uses ruby 1.9, preferrably 1.9.3
 * must apply patch to support 64 bit integers in XMLRPC (i8)
    rvm install -n xmlrpc64bit  ruby-1.9.3-p194 --patch config/deploy/patches/xmlrpclib-i8-support.patch

    this patch is planned for 2.0.0 http://bugs.ruby-lang.org/issues/3090
