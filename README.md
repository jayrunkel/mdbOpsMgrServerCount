# mdbOpsMgrServerCount

## Overview
The serverCount.pl script uses MongoDB Ops Manager API to generate a CSV file listing all the servers currently being managed by Ops Manager. The script identifies the set of Ops Manager groups and lists the servers for each group.

## Usage

The script is executed as follows:

    perl serverCount.pl <host>:<port> <opsMgrUser> <apiKey>
    
where:

    host - hostname of the Ops Manager server
    port - port for the Ops Manager server
    opsMgrUser - Ops Manager user that has the ability to read all groups
    apiKey - Ops Manager API key
    
Here is an example:
    
    perl serverCount.pl 192.168.14.100:8080 admin@vagrant.dev 7b357e1a-d6f8-4901-8215-c97459cd1f65

## Installation

This script requires the following perl modules:

    LWP::UserAgent;
    HTTP::Request::Common;
    JSON
