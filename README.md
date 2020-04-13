# pushover
Pushover Notification Client

Requirements:

libconfig-general-perl
libwww-perl

You can add a config file with many default, and tokens.

pushover.conf

token=yourtoken
secret=yoursecret

Example

./pushover.pl -m 'hello pushover!' --prio 1 --sound bike
