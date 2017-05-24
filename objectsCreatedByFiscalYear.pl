#! /usr/bin/perl
#
# items created by fiscal year -edf

use strict;
use warnings;
use URI::Escape;
use LWP::Simple;
use Config::Tiny

print "Content-Type: text/html\n\n";

my $config = Config::Tiny->new;
$config = Config::Tiny->read('settings.config');
my $serverName = $config->{settings}->{serverName};
my $serverPort = $config->{settings}->{serverPort};
my $fedoraContext = $config->{settings}->{fedoraContext};
my $username = $config->{settings}->{username};
my $password = $config->{settings}->{password};
my $realm = $config->{settings}->{realm}; 

my $fedoraURI = $serverName . ":" . $serverPort . "/" . $fedoraContext;

# Handle authentication
my $ua = LWP::UserAgent->new;
$ua->credentials( $fedoraURI . "/" . "describe", $realm, $username, $password );
print $ua;
my $resp = $ua->get($fedoraURI);

if ($resp->is_success) {
    print $resp->decoded_content;
} else {
    print $resp->status_line;
    print $resp->decoded_content;
}

my $file      = "header.html";
my $headerDoc = do {
    local $/ = undef;
    open my $fh, "<", $file or die "could not open $file: $!";
    <$fh>;
};
print $headerDoc;

print "<html> \n<head> \n<title>object created by FY</title> \n";
print "<style> \n   body { \n     background-color: lightgrey; \n    } \n";
print "td { background-color: lightgrey; text-align: right;  padding: 0 5px 0 5px; } \n";
print "td.column { background-color: lightgrey; text-align: right; } \n";
print "td.code { background-color: lightgrey; text-align: left;} \n";
print "th { background-color: lightgrey; text-align: left; padding: 5px 5px 5px 5px; } \n";
print "td:hover { color: yellow;  background-color: blue; } \n";
print ".column tr:hover { color: yellow;  background-color: blue; } \n";
print ".column td:hover { color: yellow;  background-color: blue; } \n";
print "a:hover { color: yellow;} \n";
print "</style> \n";

print "Records (Fedora Objects) created by Fiscal Year ( 1 July through 30 June )\n";
print "<p><table border=1>\n";
print "<thead>\n <tr> <th>Fiscal Year</th> <th>Records Created</th> </tr>\n<tbody>\n";

my $forCSV;
my $counter = 6;

while ( $counter++ < 16 ) {
    my ( $startYear, $endYear );
    my $counter2 = $counter + 1;

    if ( $counter < 10 ) {
        $startYear = "0$counter";
    }
    else {
        $startYear = "$counter";
    }
    if ( $counter2 < 10 ) {
        $endYear = "0$counter2";
    }
    else {
        $endYear = "$counter2";
    }
    #print "$counter --- ";
    my $query = q(select $modified $object from <#ri> where $object <fedora-model:createdDate> $modified and $object <fedora-model:hasModel> <info:fedora/fedora-system:FedoraObject-3.0> and $modified <mulgara:after> '20);
    $query .= $startYear;
    $query .= q(-06-30T05:59:59.999Z'^^<xml-schema:dateTime> in <#xsd> and $modified <mulgara:before> '20);
    $query .= $endYear;
    $query .= q(-06-30T05:59:59.999Z'^^<xml-schema:dateTime> in <#xsd> order by $modified  $object );
    #print "$query\n";
    my $queryStringEncode = uri_escape($query);
    my $countQueries = qq($fedoraURI/risearch?type=tuples&lang=itql&format=count&dt=on&query=$queryStringEncode);
    my $queryResult = get $countQueries;
    die "Couldn't get $countQueries" unless defined $queryResult;
    next if ( $queryResult eq 0 );
    $forCSV .= "20$endYear,$queryResult<BR>\n";
    print "<tr><td>20$endYear</td><td>$queryResult</td></tr>\n";
}
print "</table>\n";
print "<br><br>\n<HR>\n<br><br>\n";

## experiment to pre populate DATA to reduce processing time
#while ( <DATA> ) {
#print ;
#print "<BR>";
#}

print "\n";
print "Output for spreadsheet\n\n";
print $forCSV;   #  included for easy copy and paste into a spreadsheet

# experimental section to increase display response time 
__DATA__
2008,6180
2009,10060
2010,22655
2011,5789
2012,11909
2013,13459
