#!/usr/bin/env perl
use strict;
use warnings;
use Text::CSV qw( csv );

my $aoa = csv(
  in => $ARGV[0],
  sep_char => '|',
  binary => 1
) || die Text::CSV->error_diag;

my $headers = shift @$aoa;

# Define the defaults for each field so we can trim down to what's necessary.
# Paste a SHOW CREATE TABLE mysql_query_rules\G statement here! The part that actually has the rows, anyway. Spacing irrelevant.
my $default_string = <<EOSTRING;
rule_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
 active INT CHECK (active IN (0,1)) NOT NULL DEFAULT 0,
 username VARCHAR,
 schemaname VARCHAR,
 flagIN INT NOT NULL DEFAULT 0,
 client_addr VARCHAR,
 proxy_addr VARCHAR,
 proxy_port INT,
 digest VARCHAR,
 match_digest VARCHAR,
 match_pattern VARCHAR,
 negate_match_pattern INT CHECK (negate_match_pattern IN (0,1)) NOT NULL DEFAULT 0,
 re_modifiers VARCHAR DEFAULT 'CASELESS',
 flagOUT INT,
 replace_pattern VARCHAR,
 destination_hostgroup INT DEFAULT NULL,
 cache_ttl INT CHECK(cache_ttl > 0),
 reconnect INT CHECK (reconnect IN (0,1)) DEFAULT NULL,
 timeout INT UNSIGNED,
 retries INT CHECK (retries>=0 AND retries <=1000),
 delay INT UNSIGNED,
 next_query_flagIN INT UNSIGNED,
 mirror_flagOUT INT UNSIGNED,
 mirror_hostgroup INT UNSIGNED,
 error_msg VARCHAR,
 OK_msg VARCHAR,
 sticky_conn INT CHECK (sticky_conn IN (0,1)),
 multiplex INT CHECK (multiplex IN (0,1,2)),
 log INT CHECK (log IN (0,1)),
 apply INT CHECK(apply IN (0,1)) NOT NULL DEFAULT 0,
 comment VARCHAR)
EOSTRING

# Process the create table statement to get defaults automagically.
my @defaults = ();
foreach my $line ( split(/,\r?\n\s*/, $default_string) ) {
  if( $line =~ /^\s*$/ ) { next; }
  my $val = undef;
  if( $line =~ /DEFAULT\s+(.+)/i ) {
    $val = $1;

    # sanitize punctuation
    $val =~ s/[']//g;
    chomp($val);
  }

  push(@defaults, $val);
}

my @rule_strings = ();
foreach my $line ( @$aoa ) {
  my @attrs = ();
  my $i = 0;
  for( my $i = 0; $i < (scalar @$headers); $i++ ) {
    my $val = $line->[$i];

    # Skip this attribute if we have a default and it's the same.
    if( defined($defaults[$i]) && "$defaults[$i]" eq "$val" ) { next; }

    # Skip this attribute if the value is NULL and there's no default.
    if( $val eq 'NULL' ) {
      if( !defined($defaults[$i]) ) { next; }
      $val = $defaults[$i];
    }

    # Unfortunately this has a bug: if the default is not NULL,
    # but the value is NULL, even if that's valid, it will be overwritten.
    # This usually isn't a problem, but in the case of version 1.4.1 of proxysql
    # it imports rules wrongly, setting NULL even though CASELESS is the default.
    # This script accidentally fixes that.

    # Quote the attribute if it's not a number.
    if( $val !~ /^\d+$/ ) {
      $val = "\"$val\"";
    }

    push(@attrs, $headers->[$i] . '=' . $val);
  }

  if( scalar @attrs ) {
    push(@rule_strings, '  { ' . join(', ', @attrs) . ' }');
  }
}

if( scalar @ARGV == 2 ) {
  open(my $outh, '>',  $ARGV[1]) || die "Couldn't open $ARGV[1] for writing: $!";
  print $outh join(",\n", @rule_strings) . "\n";
} else {
  print join(",\n", @rule_strings) . "\n";
}
