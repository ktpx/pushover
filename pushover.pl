#!/usr/bin/perl
#
# Pushover.pl - Send notifications via Pushover API
# 
# Author  : kjelltp
# Date    : Nov 2019
# Version : 1.0 
# 
#         
# TODO : Implement file upload support
#    
# 
####

use utf8;
use Encode;
use LWP::UserAgent;
use strict;
use warnings;
use Getopt::Long;
use Config::General;

# Defines
my $cfgfile = "pushover.conf";
my @sounds = (
  "pushover", 
  "bike", 
  "bugle",
  "cashregister", 
  "classical", 
  "cosmic",
  "falling",
  "gamelan", 
  "incoming", 
  "intermission", 
  "magic",
  "mechanical",
  "pianobar",
  "siren",
  "spacealarm",
  "tugboat",
  "alien",
  "climb",
  "persistent",
  "echo",
  "updown",
  "none"
);

my %pri = (
             "lowest" => "-2", 
             "low" => "-1", 
             "normal" => "0",
             "high" => "1"
          );

my @msg = "";
my $token = "";  
my $secret = "";
my @devices = "";
my $sound = "pushover";
my $url = "";
my $message;
my $prio = "normal";
my $file = "";
my $title = "";
my $debug = 0;
my $quiet = "";

##
# SUBS
##
sub listsounds () {
  print "Message Sounds :\r\n";
  foreach (@sounds) {
     print " - $_\n";
  }
  print "\nDefault: $sound\n";
  exit;
}

sub listpri () {
   print "Priorities:\n";
   foreach ( sort keys %pri ) {
     printf " %8s (%2d)\n", $_, ($pri{$_});
   }
   print "\nDefault: $prio\n";
   exit;
}

sub check_pri () {
  if (not exists($pri{$prio})) {
     print "Warning: Prio '$prio' is invalid, using default (normal).\n" unless $quiet;
     $prio = "normal";
 }
}

sub send_message (@) {

  if ($debug == 1) {
     print " t=$token\n s=$secret\n m=$message\n p=$pri{$prio}\n s=$sound\n d=@devices\n";
  }
  else {
    my $res = LWP::UserAgent->new()->post(
      "https://api.pushover.net/1/messages.json", [
      "token" => $token,
      "user" => $secret,
      "message" => $message,
      "title" => $title,
      "priority" => $pri{$prio},
      "device" => "@devices",
      "sound" => $sound,
      "url" => $url
    ]);
    print $res->content unless ($quiet);
  }
}

sub help {
   print <<EOF;
"pushover.pl --message -m 'message'          defaults 
             --title   -t title              $title
             --prio    -p priority           $prio   
             --sound   -s sound              $sound   
             --url     -u url                $url
             --devices -d device [,device2]  @devices
             --file    -f imagefile
             --time    -t Unix timestamp
             --ls  show sounds
             --lp  show priority
             --help    -h show this
             --dryrun  -d dont actually send
EOF
   exit 0;
}

sub perror(@) {
   my @msg=@_;
   chomp(@msg);
   print STDERR "pushover: ERROR: @msg.\n";
   exit 1;
}

##
# MAIN
##

my $conf = Config::General->new("$cfgfile");
my %config = $conf->getall;

if (defined($config{'token'} )) {
   $token = $config{'token'};
}

if (defined($config{'secret'} )) {
   $secret = $config{'secret'};
}

if ($debug) {
  foreach (keys %config) { print "$_ = $config{$_}\n" };
}

GetOptions ( "priority|p=s" => \$prio,
             "token|o=s" => \$token,
             "title|t=s" => \$title,
             "user|u=s" => \$secret,
             "sound|s=s" => \$sound,
             "file|f=s" => \$file,
             "message|m=s" => \$message,
             "devices|d=s" => \@devices,
             "url|u=s" => \$url,
             "ls" => \&listsounds,
             "lp" => \&listpri,
             "help|h" => \&help ,
             "dryrun|d" => sub { $debug = 1; },
             "quiet|q"  => sub { $quiet = "yes" }
           ) or help;

# Check for required args
unless ($message && $token && $secret) { 
   perror "Missing one or more required argument(s)\n" 
}

if (@devices) {
  @devices = @devices = split(/ /,join(',',@devices));
}

if ($file) {
  perror "File upload is not implemented";
}

# just use default if invalid sound given
if ($sound) {
   if (not grep (/^$sound$/i, @sounds)) {
      print STDERR "Warning: invalid sound, using default.\n" unless $quiet;
      $sound = "pushover";
   }
}

check_pri;

# Send the word
send_message($message);
