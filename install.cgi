#!/usr/local/bin/perl
# Install one Pear module

require './php-pear-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'install_title'}, "");
($mod, $pver) = split(/\//, $in{'mod'});

print &text('install_doing', "<tt>$mod</tt>", $pver),"<br>\n";
$err = &install_pear_module($mod, $pver);
if ($err) {
	print $err,"\n";
	print $text{'install_failed'},"<br>\n";
	}
else {
	print $text{'install_done'},"<br>\n";
	&webmin_log("install", undef, $mod);
	}

&ui_print_footer("", $text{'index_return'});
