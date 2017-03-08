use strict;
use warnings;
use v5.10;

use LWP::UserAgent;
use HTTP::Request::Common;
use JSON;
#use Data::Dumper;

# Run As:
# perl serverCount.pl 192.168.14.100:8080 admin@vagrant.dev 7b357e1a-d6f8-4901-8215-c97459cd1f65

my $opsMgrHost = shift or die "USAGE: perl serverCount.pl <host>:<port> <opsMgrUser> <apiKey>";
my $userName = shift or die "USAGE: perl serverCount.pl <host>:<port> <opsMgrUser> <apiKey>";
my $apiKey = shift or die "USAGE: perl serverCount.pl <host>:<port> <opsMgrUser> <apiKey>";

my $gURL = '/api/public/v1.0/groups';
my $groupsURL = "http://$opsMgrHost$gURL";
my $groupURL;

my @results;
 
my $ua = LWP::UserAgent->new();
#my $request = GET $groupsURL;
 
#$request->authorization_basic($userName, $apiKey);

$ua->credentials($opsMgrHost, "MMS Public API", $userName, $apiKey);


#say $request->as_string(); 
my $response = $ua->get($groupsURL);
#say $response->as_string();

if (!$response->is_success) {
    say $response->status_line;
    say $response->decoded_content;
    die "FAILURE: Get Groups";
}

my $json = JSON->new->allow_nonref;

#my $groups = $json->decode($response);

my $groupsDef = $json->decode($response->{'_content'})->{'results'};
my @groups = ();

foreach my $group (@$groupsDef) {
    push (@groups, {gId => $group->{'id'}, gName => $group->{'name'}});
}

foreach my $groupDef (@groups) {
    my $groupId = $groupDef->{'gId'};
    $groupURL = "$groupsURL/$groupId/hosts";
    $response = $ua->get($groupURL);

    if (!$response->is_success) {
	say $response->status_line;
	say $response->decoded_content;
	die "FAILURE: Get Servers";
    }
    
    my $groupServers = $json->decode($response->{'_content'})->{'results'};
    foreach my $serverDetails (@$groupServers) {
    
	my $server = {
	    replicaStateName => $serverDetails->{'replicaStateName'},
	    hostname => $serverDetails->{'hostname'},
	    replicaSetName => $serverDetails->{'replicaSetName'},
	    port => $serverDetails->{'port'},
	    groupName => $groupDef->{'gName'},
	    version => $serverDetails->{'version'}
	};
    
#	say Dumper($server);
	push (@results, $server);
    }
}

print "Group,Replica Set,Host Name,Port,Version,State\n";
foreach my $s (@results) {
    print "$s->{'groupName'},$s->{'replicaSetName'},$s->{'hostname'},$s->{'port'},$s->{'version'},$s->{'replicaStateName'}\n";

}
