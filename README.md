# Pushover Notification Client

Client to facilitate sending push notifications via the pushover.net API.  An existing
account is required.  

Setup your account on pushover.net, then add token and secret in the config file, or
give as input option.

Perl Requirements:
-------------------

* libconfig-general-perl
* libwww-perl

pushover.conf
````
 token=yourtoken
 secret=yoursecret
````

Example
````
$ ./pushover.pl -m 'hello pushover!' --prio normal --sound bike
````
