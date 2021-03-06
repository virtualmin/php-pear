#!/usr/local/bin/perl
# Delete a bunch of Pear modules, after asking for confirmation
use strict;
use warnings;
our (%text, %in);

require './php-pear-lib.pl';
&ReadParse();
&error_setup($text{'delete_err'});
my @d = split(/\0/, $in{'d'});
@d || &error($text{'delete_enone'});
my @dinfo = map { [ split(/\//, $_) ] } @d;
&ui_print_header(undef, $text{'delete_title'}, "");

if ($in{'confirm'}) {
	# Work out what versions are involved
	my @vers = &unique(map { $_->[1] } @dinfo);
	foreach my $pver (@vers) {
		# Do it!
		print &text('delete_doing', $pver),"<br>\n";
		my @names = map { $_->[0] } grep { $_->[1] == $pver } @dinfo;
		my $err = &uninstall_pear_modules(\@names, $pver);
		if ($err) {
			print $err,"\n";
			print $text{'delete_failed'},"<br>\n";
			}
		else {
			print $text{'delete_done'},"<br>\n";
			}
		}
	&webmin_log("delete", undef, join(" ", @d));
	}
else {
	# Ask first
	print &ui_form_start("delete.cgi", "post");
	foreach my $d (@d) {
		print &ui_hidden("d", $d),"\n";
		}
	print "<center>\n";
	print &text('delete_rusure', scalar(@d)),"<p>\n";
	print &ui_submit($text{'delete_ok'}, "confirm"),"<p>\n";
	print &text('delete_mods',
		    join(" ", map { "<tt>$_->[0]</tt>" } @dinfo)),"\n";
	print "</center>\n";
	print &ui_form_end();
	}

&ui_print_footer("", $text{'index_return'});
