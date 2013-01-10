createwptvxml.pl
================

createwptvxml.pl is a simple screenscaper perl script which logs in on the 
WeepeeTV site and creates an XML containing the necessary m3u8 stream URLS.

This XML can be used to feed other applications on your local network
e.g. for use with VLC (see weepeetv.lua)

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

record.pl
=========
with record.pl you can record weepeetv streams.

Requirements
------------
ffmpeg (a version compiled with --enable-gnu-tls for the https streams)
at (standard linux available)
XML::Simple
(and createwptvxml.pl for creating the needed xml input file)

how it works
------------
Basically it will create a small shell script in /tmp which will be queued as an at job
at the time you specified. This script will be executed at the specified time and
will be calling ffmpeg to save the stream to a .mkv file in the outputdirectory you've specified.

config
------
To run the script change the variables on top of record.pl

```perl
#make sure your ffmpeg supports https
my $FFMPEG="/usr/bin/ffmpeg-weepeetv";
my $ATCMD="/usr/bin/at";
#locations of xml source file
my $XMLFILE="wptv.xml";
#where to write the recordings
my $OUTPUTDIR="/opt/recordings";
#installation directory
my $PATH="/home/wim/wptvscraper";
```

usage
-----

```
record.pl --start=<time date> --duration <hh:mm:ss> --desc <description> --channel <name>

e.g.  perl record.pl --start=15:00 tomorrow --duration 00:30:00 --desc "crappy show" --channel een
records 30 minutes starting tomorrow at 15h on channel 'een'

<time date> can be anything 'at' supports, see 'man at'

Other options:
        --channels (shows available channels)
```

Contact: @42wim



