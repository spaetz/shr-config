bin_PROGRAMS = settings

BUILT_SOURCES = .vala.stamp

NULL = 

settings_VALASOURCES = \
	abstract.vala \
	main.vala \
	power.vala \
	gps.vala \
	connectivity.vala \
	$(NULL)

settings_LDADD = \
	$(DEPS_LIBS) \
	$(THREAD_LIBS) \
	$(NULL)
#	-lutil

settings_SOURCES = \
	$(settings_VALASOURCES:.vala=.c) \
	$(settings_VALASOURCES:.vala=.h) \
	$(NULL)


.vala.stamp: $(settings_VALASOURCES)
	$(VALAC) -c --vapidir $(datadir)/vala/vapi \
	            --pkg dbus-glib-1 \
	            --pkg elm \
	            --pkg evas \
	            --pkg eina \
	            --save-temps \
                    --basedir $(top_srcdir) \
	            $^
	touch $@

CLEANFILES = \
	*.c \
	*.h \
	.vala.stamp \
	$(NULL)

MAINTAINERCLEANFILES = Makefile.in