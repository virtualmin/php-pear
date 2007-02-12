# log_parser.pl
# Functions for parsing this module's logs

do 'php-pear-lib.pl';

# parse_webmin_log(user, script, action, type, object, &params)
# Converts logged information from this module into human-readable form
sub parse_webmin_log
{
local ($user, $script, $action, $type, $object, $p) = @_;
if ($action eq "install") {
	return &text('log_install', "<tt>$object</tt>");
	}
elsif ($action eq "delete") {
	return &text('log_delete', "<tt>$object</tt>");
	}
else {
	return undef;
	}
}

