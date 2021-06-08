use strict;
use warnings;

do 'php-pear-lib.pl';

sub cgi_args
{
my ($cgi) = @_;
if ($cgi eq 'view.cgi') {
	my @mods = &list_installed_pear_modules();
	return @mods ? 'name='.&urlize($mods[0]->{'name'}).
		       '&version='.$mods[0]->{'pear'} : 'none';
	}
return undef;
}
