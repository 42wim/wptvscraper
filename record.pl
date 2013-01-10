#!/usr/bin/perl

use XML::Simple;
use strict;
use Getopt::Long;
use warnings;
use File::Temp qw/ tempfile tempdir /;


my ($now,$duration,$channel,$channels,$start,$desc);
#make sure your ffmpeg supports https
my $FFMPEG="/usr/bin/ffmpeg-weepeetv";
my $ATCMD="/usr/bin/at";
#locations of xml source file
my $XMLFILE="wptv.xml";
#where to write the recordings
my $OUTPUTDIR="/opt/recordings";
#installation directory 
my $PATH="/home/wim/wptvscraper";

my $help;

&usage() if (@ARGV < 1);

GetOptions( "now"=>\$now,
	    "description=s"=>\$desc,
	    "start=s"=>\$start,
	    "duration=s"=>\$duration,
	    "channel=s"=>\$channel,
	    "channels"=>\$channels,
            "h"=>\$help) or usage();

&usage() if $help;


my $ref=XMLin($XMLFILE,forcearray => [qw(item)],keyattr => {item => 'title'});

if ($channels) {
	&listchannels();
}

if ($now && $duration && $channel) {
	&recordnow();
}

if ($start && $duration && $channel) {
	&queuerecord();

}

sub usage {
	print "\nrecord.pl --start=<time date> --duration <hh:mm:ss> --desc <description> --channel <name>\n\n";
	print "e.g.  perl record.pl --start=15:00 tomorrow --duration 00:30:00 --desc \"crappy show\" --channel een\n";
	print "records 30 minutes starting tomorrow at 15h on channel 'een'\n\n";
	print "<time date> can be anything 'at' supports, see 'man at'\n\n";
	print "Other options:\n\t--channels (shows available channels)\n\n";
}

sub listchannels {
	my $channels=$ref->{item};
	print "\nAvailable channels:\n";
	print "-------------------\n";
	foreach $channel (sort(keys %{$channels})) {
		print $channel."\n";
	}
	print "\n";
}


sub queuerecord {
	my ($fh,$filename)=tempfile();	
	open(F,">$filename");

	my $cmd=$PATH."/record.pl --now --duration ".$duration." --channel ".$channel;
	if ($desc) {
		$desc=~s/\s+/_/g;
		$cmd.=" --desc \"".$desc."\"";
	} 
	print F $cmd;
	system($ATCMD." -f $filename $start");
	unlink($filename);
	close(F);
}	

sub recordnow {
	my $cmd=$FFMPEG." -i ".$ref->{item}->{$channel}->{h264}. " -t ".$duration;
	$desc=~s/\s+/_/g;
	if ($desc) {
		$cmd.=" -metadata title=\"".$desc."\" -c copy ".$OUTPUTDIR."/".$channel."-".$desc."-\$(date +%Y%m%d%H%M).mkv";
	} else {
		$cmd.=" -c copy ".$OUTPUTDIR."/".$channel."-\$(date +%Y%m%d%H%M).mkv";
	}
	$cmd.=" > /dev/null 2>&1";
	system($cmd);
}
