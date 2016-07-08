use Test::Strict tests => 3;                      # last test to print

syntax_ok( 'install.cgi' );
strict_ok( 'install.cgi' );
warnings_ok( 'install.cgi' );
