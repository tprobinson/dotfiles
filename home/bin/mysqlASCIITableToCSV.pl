#!/usr/bin/env perl
use strict;
use warnings;
use Text::CSV qw( csv );

open(my $fh, '<', $ARGV[0]) || die "Couldn't open $ARGV[0] for reading: $!";

my @lines = ();
while( my $line = <$fh> ) {
  if( $line =~ /^\+/ || $line =~ /^\s*$/ ) {
    next;
  }

  # Remove initial whitepace and borders
  chomp($line);
  $line =~ s/^\s*\|\s*|\s*\|\s*$//g;

  my @arr = split(/\s*\|\s*/, $line);

  push(@lines, \@arr);
}
close $fh;

csv(
  in => \@lines,
  out => scalar @ARGV == 2 ? $ARGV[1] : 'outfile.csv',
  sep_char => '|',
  binary => 1,
  always_quote => 1
);
