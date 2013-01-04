
createwptvxml.pl is a simple screenscaper perl script which logs in on the 
WeepeeTV site and creates an XML containing the necessary m3u8 stream URLS.

This XML can be used to feed other applications on your local network
e.g. for use with VLC (see my wptv_vlcplugin)

The xml file format is as follows:

<?xml version='1.0'?>
<items>
<item>
<title>channel</title>
<thumb>https://weepee.tv/img/channels/channel.jpg</thumb>
<h264>https://weepeetv.my-stream.eu/channel/uuid/channeluuid/stream.m3u8</h264>
</item>
</items>


To run the script change the variables on top of createwptvmxl.pl

## change these variables
my $ACCOUNT="uxxxxxx";
my $PASSWORD="secret";
my $CURL="/usr/bin/curl";
my $XMLFILE="wptv.xml";
my @sort=("een","canvas","bbc1","bbc2","acht","vtm","2be","vitaya","jim","ketnet","bbcentertainment","kanaalz","vtmKzoom","tvllogosmall","livetv");

Contact: @42wim
