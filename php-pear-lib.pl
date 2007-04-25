# Functions for managing Pear
# XXX multi-version support not done yet

do '../web-lib.pl';
&init_config();
do '../ui-lib.pl';

# check_pear()
# Returns an error message if Pear is not installed, or undef
sub check_pear
{
if (!&has_command($config{'pear'})) {
	return &text('check_ecmd', "<tt>$config{'pear'}</tt>");
	}
return undef;
}

# get_pear_commands()
# Returns a list of installed pear commands and versions
sub get_pear_commands
{
local $pear4 = &has_command($config{'pear'}."4");
local $pear5 = &has_command($config{'pear'}."5");
local $pear = &has_command($config{'pear'});
if ($pear4 && $pear5) {
	# Two versions exist .. 
	return ( [ $pear4, 4 ], [ $pear5, 5 ] );
	}
elsif ($pear && $pear4 && !&same_file($pear, $pear4)) {
	# Both pear and pear4 exist .. assume that one is pear 5
	return ( [ $pear4, 4 ], [ $pear, 5 ] );
	}
elsif ($pear && $pear5 && !&same_file($pear, $pear5)) {
	# Both pear and pear4 exist .. assume that one is pear 4
	return ( [ $pear, 4 ], [ $pear5, 5 ] );
	}
elsif ($pear4) {
	# Only pear 4 exists
	return ( [ $pear4, 4 ] );
	}
elsif ($pear5) {
	# Only pear 5 exists
	return ( [ $pear5, 5 ] );
	}
else {
	return ( [ &has_command("pear"), int(&get_php_version()) || 4 ] );
	}
}

sub get_php_version
{
&clean_environment();
local $out = `php -v 2>&1`;
&reset_environment();
return $out =~ /php\s+(\S+)/i ? $1 : undef;
}

sub get_pear_versions
{
return map { $_->[1] } &get_pear_commands();
}

# list_installed_pear_modules()
# Returns a list of Pear modules that are currently installed, as a hash array
sub list_installed_pear_modules
{
local @rv;
foreach my $c (&get_pear_commands()) {
	&clean_environment();
	&open_execute_command(PEAR, "$c->[0] list", 1);
	&reset_environment();
	while(<PEAR>) {
		if (/^(\S+)\s+([0-9\.]+)\s+(\S+)/) {
			push(@rv, { 'name' => $1,
				    'version' => $2,
				    'state' => $3,
				    'pear' => $c->[1], });
			}
		}
	close(PEAR);
	}
return @rv;
}

# list_available_pear_modules()
# Returns a list of Pear modules that can be installed. May call &error if
# the list cannot be fetched
sub list_available_pear_modules
{
local @rv;
local $out;
foreach my $c (&get_pear_commands()) {
	&clean_environment();
	&open_execute_command(PEAR, "$c->[0] list-all", 1);
	&reset_environment();
	while(<PEAR>) {
		if (/^(\S+)\s+([0-9\.]+)(\s+([0-9\.]+))?/) {
			push(@rv, { 'name' => $1,
				    'version' => $2,
				    'got' => $4,
				    'pear' => $c->[1], });
			$rv[$#rv]->{'name'} =~ s/^pear\///;
			}
		$out .= $_;
		}
	close(PEAR);
	if ($?) {
		&error(&text('list_failed', "<pre>$out</pre>"));
		}
	}
return @rv;
}

# install_pear_module(name, php-version)
# Attempts to install the specified module, returning undef if OK or an
# error message on failure
sub install_pear_module
{
local ($name, $pver) = @_;
local ($c) = grep { $_->[1] eq $pver } &get_pear_commands();
&clean_environment();
local $out = &backquote_logged("$c->[0] install ".quotemeta($name));
&reset_environment();
return $? ? "<pre>$out</pre>" : undef;
}

# uninstall_pear_modules(&names, php-version)
# Removes the specified modules, returning undef if OK or an error message
sub uninstall_pear_modules
{
local ($names, $pver) = @_;
local ($c) = grep { $_->[1] eq $pver } &get_pear_commands();
&clean_environment();
local $out = &backquote_logged("$c->[0] uninstall ".
		join(" ", map { quotemeta($_) } @$names));
&reset_environment();
return $? ? "<pre>$out</pre>" : undef;
}

# get_pear_module_info(name, php-version)
# Returns a list of name-value tuples of info on a Pear module
sub get_pear_module_info
{
local ($names, $pver) = @_;
local ($c) = grep { $_->[1] eq $pver } &get_pear_commands();
local @rv;
&clean_environment();
&open_execute_command(PEAR, "$c->[0] info ".quotemeta($name), 1);
&reset_environment();
while(<PEAR>) {
	s/\r|\n//g;
	next if (/About\s+(\S+)\-/i && lc($1) eq lc($name) || /====/);
	if (/^(\S.{15})(\S.*)/) {
		# Start of an entry
		push(@rv, [ $1, $2 ]);
		}
	elsif (/^\s+(\S.*)/ && @rv) {
		# Continuation
		$rv[$#rv]->[1] .= "\n".$1;
		}
	}
close(PEAR);
return @rv;
}

1;

