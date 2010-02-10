include $(top_srcdir)/Makefile.decl

NULL = 

AUTOMAKE_OPTIONS = subdir-objects

INCLUDES = \
	$(DEPS_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

BUILT_SOURCES = .vala.stamp

bin_PROGRAMS = settings

settings_VALASOURCES = \
	abstract.vala \
	main.vala \
	power.vala \
	gps.vala \
	connectivity.vala \
	profiles.vala \
	$(NULL)

settings_SOURCES = \
	$(settings_VALASOURCES:.vala=.c) \
	\
	$(NULL)

.vala.stamp: $(settings_VALASOURCES)
	$(VALAC) -C \
	            --pkg dbus-glib-1 \
	            --pkg evas \
	            --pkg ecore \
	            --pkg elm \
	            --pkg cairo \
	            --save-temps \
	            --basedir $(top_srcdir) $^
	touch $@

settings_LDADD = \
	$(DEPS_LIBS) \
	-lutil \
	$(NULL)
#TODO why is libutil needed?

EXTRA_DIST += \
	$(settings_VALASOURCES) \
	.vala.stamp \
	$(NULL)

CLEANFILES = \
	*.c \
	*.h \
	.vala.stamp \
	$(NULL)

DISTCLEANFILES = \
	$(NULL)

MAINTAINERCLEANFILES = \
	Makefile.in \
	$(NULL)
