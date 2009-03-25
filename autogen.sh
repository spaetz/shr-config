
#!/bin/sh

#aclocal
#autoconf
#automake --add-missing

autoreconf -v --install || exit 1

#$srcdir/configure "$@"
