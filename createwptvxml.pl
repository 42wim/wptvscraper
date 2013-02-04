#!/usr/bin/perl
# Copyright (C) 2013 <wim at 42 dot be>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use File::Temp qw/ tempfile tempdir /;
use JSON;

## change these variables
my $ACCOUNT="uxxxxx";
my $PASSWORD="secret";
my $CURL="/usr/bin/curl";
my $XMLFILE="wptv.xml";
my $MYTHTVFILE="mythtv_playlist.m3u";
#choose the channelnumber from which weepeetv will start
my $MYTHTVSTARTCHANNEL=1;

## here be dragons
##############################
my $fh;
my $filename;

my %channelsdyn=();

my $XMLTEMPLATE=qq~
<item>
<title>##zender##</title>
<thumb>##img##</thumb>
<h264>##url##</h264>
</item>
~;

my $MYTHTVTEMPLATE=qq~
##zender##
##url##
~;

MAIN: {
	my $zender;
	my $url;
	my $img;
	my $jsonstring;
	my $jsondecode;

	($fh,$filename)=tempfile();
	&login();

	$jsonstring=<$fh>;
	close($fh);
	$jsondecode = JSON->new->decode($jsonstring);
	foreach my $key (@{$jsondecode}) {
		my $channel=$key->{name};
		$channel =~ s/ /_/g;
		$channelsdyn{$key->{name}}{"img"}=$key->{logo_url};
		$channelsdyn{$key->{name}}{"url"}=$key->{m3u8};
	}
	&createxml();
	&createmythtv();

}

sub login {
	my ($lfh,$lfile);
	system($CURL." -o /dev/null -s -b ~/.wpcookie -c ~/.wpcookie https://weepeetv.my-stream.eu/");
	system($CURL." -o /dev/null -s -b ~/.wpcookie -c ~/.wpcookie https://weepeetv.my-stream.eu/login/");
	print "logging in..\n";
	($lfh,$lfile)=tempfile();
	system($CURL." -o ".$lfile." -s -b ~/.wpcookie -c ~/.wpcookie -d \"account=".$ACCOUNT."\" -d \"password=".$PASSWORD."\" https://weepeetv.my-stream.eu/login/do");
	my $input=<$lfh>;
	if ($input=~/Redirecting to \/login\/wait/i) { print "login ok\n"; } else { print "login failed\n";exit;}
	close($lfh);unlink($lfile);	
	system($CURL." -o /dev/null -s -b ~/.wpcookie -c ~/.wpcookie https://weepeetv.my-stream.eu/login/wait/");
	system($CURL." -o /dev/null -s -b ~/.wpcookie -c ~/.wpcookie https://weepeetv.my-stream.eu/login/wait/test/");
	system($CURL." -o /dev/null -s -b ~/.wpcookie -c ~/.wpcookie https://weepeetv.my-stream.eu/");
	system($CURL." -o /dev/null -s -b ~/.wpcookie -c ~/.wpcookie https://weepeetv.my-stream.eu/channels/");
	print "fetching channels\n";
	system($CURL." -o ".$filename." -s -b ~/.wpcookie -c ~/.wpcookie https://weepeetv.my-stream.eu/channels.json");
}

sub createxml {
	open(F,"> $XMLFILE");
	print F "<?xml version='1.0'?><items>";
	foreach my $zender (sort(keys %channelsdyn)) {
	#	print "generating xml file\n";
		my $t=$XMLTEMPLATE;
		$t=~s/##url##/$channelsdyn{$zender}{"url"}/g;
		$t=~s/##img##/$channelsdyn{$zender}{"img"}/g;
		$t=~s/##zender##/$zender/g;
		print F $t;
	}
	print F "</items>";
	close(F);
}

sub createmythtv {
	open(F,"> $MYTHTVFILE");
	print F "#EXTM3U\n";
	my $count=$MYTHTVSTARTCHANNEL;
	foreach my $zender (sort(keys %channelsdyn)) {
		$count ++;
		my $t=$MYTHTVTEMPLATE;
		print F "#EXTINF:0,$count - $zender \n";
		print F $channelsdyn{$zender}{"url"};
		print F "\n";
	}
	close(F);
}
