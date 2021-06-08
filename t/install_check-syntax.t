use Test::Strict tests => 3;                      # last test to print

syntax_ok( 'install_check.pl' );
strict_ok( 'install_check.pl' );
warnings_ok( 'install_check.pl' );
