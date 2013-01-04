createwptvxml.pl
================

createwptvxml.pl is a simple screenscaper perl script which logs in on the 
WeepeeTV site and creates an XML containing the necessary m3u8 stream URLS.

This XML can be used to feed other applications on your local network
e.g. for use with VLC (see my wptv_vlcplugin)

The xml file format is as follows:

```html
<?xml version='1.0'?>
<items>
<item>
<title>channel</title>
<thumb>https://weepee.tv/img/channels/channel.jpg</thumb>
<h264>https://weepeetv.my-stream.eu/channel/uuid/channeluuid/stream.m3u8</h264>
</item>
</items>
```

config
------
To run the script change the variables on top of createwptvmxl.pl
```perl
## change these variables
my $ACCOUNT="uxxxxxx";
my $PASSWORD="secret";
my $CURL="/usr/bin/curl";
my $XMLFILE="wptv.xml";
my @sort=("een","canvas","bbc1","bbc2","acht","vtm","2be","vitaya","jim","ketnet","bbcentertainment","kanaalz","vtmKzoom","tvllogosmall","livetv");
```

weepeetv.lua
============
weepeetv.lua is addon for VLC which uses the wptv.xml created by createwptvxml.pl

config
------
Change the url to your webserver containing wptv.xml

```lua
local tree = simplexml.parse_url("http://yourserver.url/wptv.xml")
```

Put the file in the lua/sd directory of your vlc install.
To access it go to View - Playlist - Internet - WeePee TV

See http://blog.42.be/2012/12/weepeetv-and-vlc.html for more info


Contact: @42wim



