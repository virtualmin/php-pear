#!/usr/local/bin/perl
# Show info on a Pear module

require './php-pear-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'view_title'}, "");

@info = &get_pear_module_info($in{'name'}, $in{'version'});
print &ui_table_start(&text('view_header', "<tt>$in{'name'}</tt>"), undef, 2);
foreach $i (@info) {
	$esc = &html_escape($i->[1]);
	$esc =~ s/\n/<br>/g;
	print &ui_table_row($i->[0], $esc);
	}
print &ui_table_end();

&ui_print_footer("", $text{'index_return'});

