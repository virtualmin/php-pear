#!/usr/local/bin/perl
# Show a list of installed Pear modules, and a form to add one
use strict;
use warnings;
our (%text);
our $module_name;

require './php-pear-lib.pl';
&ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1);

# Check for pear
my $err = &check_pear();
if ($err) {
	&ui_print_endpage(
		&text('index_epear', $err, "../config.cgi?$module_name"));
	}

# Show installed
print &ui_subheading($text{'index_mods'});
my @mods = &list_installed_pear_modules();
if (@mods) {
	print &ui_form_start("delete.cgi", "post");
	my @links = ( &select_all_link("d"),
		   &select_invert_link("d") );
	my @tds = ( "width=5" );
	print &ui_links_row(\@links);
	print &ui_columns_start([ "", $text{'index_name'},
				  $text{'index_version'},
				  $text{'index_pversion'},
				  $text{'index_state'} ]);
	foreach my $m (sort { $a->{'pear'} <=> $b->{'pear'} ||
			   lc($a->{'name'}) cmp lc($b->{'name'}) } @mods) {
		print &ui_checked_columns_row([
			"<a href='view.cgi?name=".&urlize($m->{'name'}).
			 "&version=".$m->{'pear'}."'>$m->{'name'}</a>",
			$m->{'version'},
			$m->{'pear'},
			$m->{'state'} ], \@tds, "d",
			$m->{'name'}."/".$m->{'pear'});
		}
	print &ui_columns_end();
	print &ui_links_row(\@links);
	print &ui_form_end([ [ "delete", $text{'index_delete'} ] ]);
	}
else {
	print "<b>$text{'index_none'}</b><p>\n";
	}

# Show install form
my @avail = &list_available_pear_modules();
print &ui_form_start("install.cgi", "post");
print &ui_table_start($text{'index_header'}, undef, 2);

print &ui_table_row($text{'index_mod'},
	&ui_select("mod", undef,
		[ map { [ "$_->{'name'}/$_->{'pear'}",
			  "$_->{'name'} $_->{'version'} (PHP $_->{'pear'})" ] }
		      sort { lc($a->{'name'}) cmp lc($b->{'name'}) } @avail ]));

print &ui_table_end();
print &ui_form_end([ [ "install", $text{'index_ok'} ] ]);

&ui_print_footer("/", $text{'index'});

