#!/usr/bin/env perl
use strict;
use warnings;
use Socket;
my @newEtcHostLines = ();
my @etcHostLines = ();

# Read /etc/hosts in.
open(my $fh, '<', '/etc/hosts') || die $!;
while( my $line = <$fh> ) {
  push(@etcHostLines, $line);
}
close($fh) || warn $!;

# Loop through and create a new version of the file.
for( my $i = 0; $i < scalar @etcHostLines; $i++ ) {
  my $line = $etcHostLines[$i];
  print "Processing line:\n$line";
  # If we get a line that looks like # CNAME <name> <values>, make an entry
  if( $line =~ /^\s*\#\s*CNAME\s*(?<cname>\S+)\s+(?<values>.+)\s*$/ ) {
    print "Got CNAME for $+{'cname'}, looking up IPs...\n";
    my ($name,$aliases,$addrtype,$length,@addrs) = gethostbyname($+{'cname'});
    if( scalar @addrs == 0 ) {
      print "Couldn't lookup $+{'cname'}!\n";
    } else {
      # Put in a new line with the new value.
      my $ip = inet_ntoa((sort @addrs)[0]);
      print "Got value: $ip\n";
      push(@newEtcHostLines, $line);
      push(@newEtcHostLines, "$ip $+{'values'}\n");

      # Check the next line-- if it's an old entry of this one, omit it.
      if( $etcHostLines[$i+1] =~ /^[\d\.]+\s+$+{'values'}\s*$/ ) {
        print "Omitting old entry line.\n";
        shift(@etcHostLines);
      }
    }
  } else {
    print "No match.\n";
    push(@newEtcHostLines, $line);
  }
}

# Print out the new version.
open(my $wh, '>', '/etc/hosts') || die $!;
foreach my $line (@newEtcHostLines) {
  print $wh $line;
}
close($wh) || warn $!;
