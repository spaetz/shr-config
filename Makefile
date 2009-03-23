all: compile link

compile: abstract.vala power.vala gps.vala connectivity.vala main.vala
	valac -c -X -Os           \
	            --pkg dbus-glib-1 \
	            --pkg eina \
	            --pkg evas \
	            --pkg ecore \
	            --pkg elm \
	            --save-temps \
	            $?

link: abstract.o power.o gps.o connectivity.o main.o
	$(CC) `pkg-config elementary dbus-glib-1 --libs` -o settings $?

clean: 
	rm *.o *.c *.h settings