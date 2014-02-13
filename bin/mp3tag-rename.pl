#!/usr/bin/perl

# mp3tag-rename.pl v0.1 - an mp3 tagging and renaming script
# Copyright 2002 Juergen Heerdegen
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
# USA

use MP3::Info;
use MP3::Tag;
use POSIX;
use CDDB;
#use FreeDB;

my $login_id = "whoami";
my $cddbp = new CDDB( Host  => 'freedb.freedb.org', 
	Port  => 8880,
	Login => $login_id,
) or die $!;

opendir (PWD, ".") || die "Can't open directory.";
@files = sort readdir(PWD);
closedir(PWD);

my $aggregate_sec=0;
my @toc=();
my %cdtoc=();
my $t=0;

# assume first song starts 2 seconds into the CD
$cdtoc{min}=0;
$cdtoc{sec}=2;
$cdtoc{frames}=150;

push @toc,\%cdtoc;

foreach $filename (@files) {
	if ( $filename ne '.' && $filename ne '..' ) {
		chomp $filename;
		my $info = get_mp3info($filename);
		$aggregate_sec = $aggregate_sec + (($info->{MM}*60) + $info->{SS}) + 2;
		my %cdtoc=();
		$cdtoc{filename}=$filename;
		$cdtoc{min}=int($aggregate_sec/60);
		$cdtoc{sec}=int($aggregate_sec%60);
		$cdtoc{frames}=int($aggregate_sec*75);
		push @toc,\%cdtoc;
	}
}

my $total=$#toc;

$framelist="$#toc ";
for (my $i=0; $i<$#toc; $i++) {
	$track = $i+1;
	$frame_offset = $toc[$i]->{frames};
	$framelist = $framelist . "$frame_offset ";
}

my $cddbp_id=cddb_discid($total,\@toc);
my $total_seconds = $t;
my $track_offsets = $framelist;

# set a menu and allow user input in picking artist/album
system("clear");
print "Querying CDDB/freedb database...\n\n";

my $list_num = 1;
@discs = $cddbp->get_discs( $cddbp_id, $track_offsets, $total_seconds );

# if no matches found print message then end

foreach my $disc (@discs) {
	my ($disc_genre, $disc_id, $disc_title) = @$disc;
	print ("match #$list_num:\n", 
		"   disc id = $disc_id\n", 
		"   disc genre = $disc_genre\n", 
		"   disc title = $disc_title\n",
	);
	$list_num++;
}

my $choices = $list_num - 1;

if ( $choices == 0 ) {
	print "No matches found.  Exiting...\n";
	exit 0;
}

print "Select a matching disc from the list above: ";
my $char = <STDIN>;
chomp($char);

while (( $char == 0 ) || ( $char > $choices )) {
	print "Invalid input: $char\n";
	print "Select a matching disc from the list above: ";
	$char = <STDIN>;
	chomp($char);
}

my $disc = $discs[$char - 1];
my ($disc_genre, $disc_id, $disc_title) = @$disc;

# once user picks an album, query cddb with genre discid
my $disc_details = $cddbp->get_disc_details( $disc_genre, $disc_id );

@fields = split /\//, $disc_details->{dtitle};

my $artist = convert_chars($fields[0]);
my $album = convert_chars($fields[1]);

print "Artist = $artist, Album = $album\n";

# print the title list, prompt for rename and tag confirmation

for (my $i=0; $i<$#toc; $i++) {
	$track = $i + 1;
	if ( $track < 10 ) {
		$track = "0" . $track;
	}
	$title = convert_chars($disc_details->{ttitles}[$i]);
	print "$track : $toc[$track]->{filename} =>\n",
		"   $artist - $album - $track - $title.mp3\n";

}

print "\nFiles will be renamed and tagged as above.  Please confirm action (y/n): ";

my $ans = <STDIN>;
chomp($ans);
$ans = lc($ans);

while (( $ans ne "y" ) && ( $ans ne "n" )) {
	print "Invalid input. Please confirm action (y/n): ";
	$ans = <STDIN>;
	chomp($ans);
	$ans = lc($ans);
}

if ( $ans eq "n" ) {
	exit 0;
}

# tag & rename files
for (my $i=0; $i<$#toc; $i++) {
	$track = $i + 1;
	if ( $track < 10 ) {
		$track = "0" . $track;
	}

	$title = convert_chars($disc_details->{ttitles}[$i]);

	$mp3 = MP3::Tag->new($toc[$track]->{filename});
	$mp3->get_tags;
	# if an id3v1 tag doesn't already exist, create it
	if (! exists $mp3->{ID3v1}) {
		$mp3->new_tag("ID3v1");
	}
	$id3v1 = $mp3->{ID3v1};
	$id3v1->all("$title","$artist","$album",0,"",$track,"");
	$id3v1->write_tag;
	$mp3->close();

	# 'rename' the files by moving them
	system("mv \"$toc[$track]->{filename}\" \"$artist - $album - $track - $title.mp3\"");
}

##############
# subroutines
##############

sub convert_chars() {
	$text = $_[0];
	# kill whitespace on the left then on the right
	$text =~ s/^\s+//;
	$text =~ s/\s+$//;
	# convert sketchy chars to an underscore
	$text =~ s/[:;*#?|><"\$!`]/_/g;
	# convert backslash and slashes to an underscore
	$text =~ s/\\/_/g;
	$text =~ s/\//_/g;
	return $text;   
}

sub cddb_sum {
	my $n=shift;
	my $ret=0;

	while ($n > 0) {
		$ret += ($n % 10);
		$n = int $n / 10;
	}

	return $ret;
}

sub cddb_discid {

	my $total_min=0;
	my $total_sec=0;
	my $total=shift;
	my $toc=shift;

	my $i=0;
	my $n=0;
  
	my $aggregate_sec=0;

	while ($i < $total) {
		$n = $n + cddb_sum(($toc->[$i]->{min} *60) + $toc->[$i]->{sec});
		$i++;
	}

	$t = (($toc->[$total]->{min} * 60) + ($toc->[$total]->{sec})) - (($toc->[0]->{min} * 60) + ($toc->[0]->{sec}));

	return (($n % 0xff) << 24 | $t << 8 | $total);
}
