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

## change these variables
my $ACCOUNT="uxxxxx";
my $PASSWORD="secret";
my $CURL="/usr/bin/curl";
my $XMLFILE="wptv.xml";
my @sort=("een","canvas","bbc1","bbc2","acht","vtm","2be","vitaya","jim","ketnet","bbcentertainment","kanaalz","vtmkzoom","tvl","lifetv");

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

($fh,$filename)=tempfile();

&login();

my $zender;
my $url;
my $img;
my $globalcounter=0;
my $globaluuid;
while(<$fh>) {
	if (/.*?href=\"(https.*?)"/) {
		$url=$1;
	}
	if (/img src=\"(.*?)\"/) {
		$img=$1;
		if ($img=~/channellogos\/app\/(.*?)\./) {
			$zender=$1; 
			$channelsdyn{$zender}{"img"}=$img;
			&curldl($url,$zender);
			
		}
	}
}
close($fh);
unlink($filename);

sub curldl {
	my $url=shift;
	my $zender=shift;
	unless ($globalcounter) {
		#we need to fetch one channel, afterwards we can generate the URL ourselves.
		print "fetching $zender on $url to get the UUID\n";
		open(C,$CURL." -s -b ~/.wpcookie -c ~/.wpcookie ".$url."|");
		while(<C>) {
			if (/src: \"(https:.*?channel\/)(.*?)(\/.*?m3u8).*/) {
				$channelsdyn{$zender}{"url"}=$1."/".$2.$3;
				$globaluuid=$2;
			}
		}
		close(C);
		$globalcounter++;
	}
	if ($url=~/.*play\/(.*)/) {
		print "adding $zender to xml\n";
		$channelsdyn{$zender}{"url"}="https://weepeetv.my-stream.eu/channel/".$globaluuid."/".$1."/stream.m3u8";
	}
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
	system($CURL." -o ".$filename." -s -b ~/.wpcookie -c ~/.wpcookie https://weepeetv.my-stream.eu/channels.html");
}

open(F,"> $XMLFILE");
print F "<?xml version='1.0'?><items>";
foreach my $zender (@sort) {
#	print "generating xml file\n";
	my $t=$XMLTEMPLATE;
	$t=~s/##url##/$channelsdyn{$zender}{"url"}/g;
	$t=~s/##img##/$channelsdyn{$zender}{"img"}/g;
	$t=~s/##zender##/$zender/g;
	print F $t;
}
print F "</items>";
close(F);
