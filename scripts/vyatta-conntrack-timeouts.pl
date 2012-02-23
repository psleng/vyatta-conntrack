#!/usr/bin/perl

use lib "/opt/vyatta/share/perl5";
use warnings;
use strict;

use Vyatta::Config;
use Vyatta::Conntrack::RuleCT;
use Vyatta::IpTables::AddressFilter;
use Getopt::Long;
use Vyatta::Zone;
use Sys::Syslog qw(:standard :macros);

#for future use when v6 timeouts need to be set
my %cmd_hash = ( 'ipv4'        => 'iptables',
		 'ipv6'   => 'ip6tables');

my ($create, $delete, $update);

GetOptions("create=s"        => \$create,
           "delete=s"        => \$delete,
           "update=s"        => \$update,
);

update_config();

sub update_config {
  my $config = new Vyatta::Config;
  my %rules = (); #hash of timeout config rules  
  my $iptables_cmd = $cmd_hash{'ipv4'};

  $config->setLevel("system conntrack timeout custom rule");
  %rules = $config->listNodeStatus();
  foreach my $rule (sort keys %rules) { 
    if ("$rules{$rule}" eq 'static') {
    } elsif ("$rules{$rule}" eq 'added') {      
      print $rules{$rule};
      my $node = new Vyatta::Conntrack::RuleCT;
      $node->setup("system conntrack timeout custom rule $rule");
      $node->print();
#      $node->rule();
      $node->get_policy_command(); #nfct-tiemout command string
    } elsif ("$rules{$rule}" eq 'changed') {
      print $rules{$rule};
      my $node = new Vyatta::Conntrack::RuleCT;
      $node->setup("system conntrack timeout custom rule $rule");
      $node->print();
    } elsif ("$rules{$rule}" eq 'deleted') {
      print $rules{$rule};
    }  
  }
}
