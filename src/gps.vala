/**
 * Copyright (C) 2009 Sebastian Spaeth <Sebastian@SSpaeth.de>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 */

using Elm;
using Cairo;

public class Barchart : GLib.Object {
	private const int SIZE = 10;
	private Cairo.ImageSurface surface;

    construct {
		//
    }

    public void create_img (uchar[] data, int width, int height) {
		surface = new Cairo.ImageSurface.for_data (data, Cairo.Format.ARGB32, width, height, 0);
        var ctx = new Cairo.Context( surface );
        ctx.set_source_rgb (0, 0, 0);
        ctx.set_line_width (2);
        ctx.set_tolerance (0.1);
        ctx.move_to (SIZE, 0);
        ctx.rel_line_to (SIZE, 2 * SIZE);
        ctx.rel_line_to (-2 * SIZE, 0);
        ctx.close_path ();

        surface.flush();
		surface.finish(); // or rather use flush?

	}
/*    private void create_widgets () {
		surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, 200, 200);
        var ctx = new Cairo.Context( surface );
        ctx.set_source_rgb (0, 0, 0);
        ctx.set_line_width (SIZE / 4);
        ctx.set_tolerance (0.1);

        ctx.set_line_join (LineJoin.ROUND);
        ctx.set_dash (new double[] {SIZE / 4.0, SIZE / 4.0}, 0);
        stroke_shapes (ctx, 0, 0);

        ctx.set_dash (null, 0);
        stroke_shapes (ctx, 0, 3 * SIZE);

        ctx.set_line_join (LineJoin.BEVEL);
        stroke_shapes (ctx, 0, 6 * SIZE);

        ctx.set_line_join (LineJoin.MITER);
        stroke_shapes(ctx, 0, 9 * SIZE);

        fill_shapes (ctx, 0, 12 * SIZE);

        ctx.set_line_join (LineJoin.BEVEL);
        fill_shapes (ctx, 0, 15 * SIZE);
        ctx.set_source_rgb (1, 0, 0);
        stroke_shapes (ctx, 0, 15 * SIZE);
    }

    private void stroke_shapes (Context ctx, int x, int y) {
        this.draw_shapes (ctx, x, y, ctx.stroke);
    }

    private void fill_shapes (Context ctx, int x, int y) {
        this.draw_shapes (ctx, x, y, ctx.fill);
    }

    private delegate void DrawMethod ();

    private void draw_shapes (Context ctx, int x, int y, DrawMethod draw_method) {
        ctx.save ();

        ctx.new_path ();
        ctx.translate (x + SIZE, y + SIZE);
        bowtie (ctx);
        draw_method ();

        ctx.new_path ();
        ctx.translate (3 * SIZE, 0);
        square (ctx);
        draw_method ();

        ctx.new_path ();
        ctx.translate (3 * SIZE, 0);
        triangle (ctx);
        draw_method ();

        ctx.new_path ();
        ctx.translate (3 * SIZE, 0);
        inf (ctx);
        draw_method ();

        ctx.restore();
    }

    private void triangle (Context ctx) {
        ctx.move_to (SIZE, 0);
        ctx.rel_line_to (SIZE, 2 * SIZE);
        ctx.rel_line_to (-2 * SIZE, 0);
        ctx.close_path ();
    }

    private void square (Context ctx) {
        ctx.move_to (0, 0);
        ctx.rel_line_to (2 * SIZE, 0);
        ctx.rel_line_to (0, 2 * SIZE);
        ctx.rel_line_to (-2 * SIZE, 0);
        ctx.close_path ();
    }

    private void bowtie (Context ctx) {
        ctx.move_to (0, 0);
        ctx.rel_line_to (2 * SIZE, 2 * SIZE);
        ctx.rel_line_to (-2 * SIZE, 0);
        ctx.rel_line_to (2 * SIZE, -2 * SIZE);
        ctx.close_path ();
    }

    private void inf (Context ctx) {
        ctx.move_to (0, SIZE);
        ctx.rel_curve_to (0, SIZE, SIZE, SIZE, 2 * SIZE, 0);
        ctx.rel_curve_to (SIZE, -SIZE, 2 * SIZE, -SIZE, 2 * SIZE, 0);
        ctx.rel_curve_to (0, SIZE, -SIZE, SIZE, -2 * SIZE, 0);
        ctx.rel_curve_to (-SIZE, -SIZE, -2 * SIZE, -SIZE, -2 * SIZE, 0);
        ctx.close_path ();
    }

	public uchar[] data() {
        return surface.get_data();
	}
*/
}

public class Setting.GPS : Setting.Abstract
{
    //DBus.Connection dbus;
    //dynamic DBus.Object dbus_disp; //Display

    Elm.Toggle pol_tog;

    //GPS info box widgets
    Elm.Frame gpsinfo_f;

	Evas.Image barchart;
	Barchart bchart;
    /* Constructor of the class */
    //public GPS()
    //{
    //   this.dbus = DBus.Bus.get (DBus.BusType.SYSTEM);
    //   this.dbus_disp = dbus.get_object ("org.freesmartphone.odeviced",
    //                             "/org/freesmartphone/Device/Display/0",
    //                             "org.freesmartphone.Device.Display");
    //}

	public void cb_gpsPol_tog_changed( Evas.Object obj, void* event_info ) {
		debug("gps Policy changed called");
	}

    public override void run( Evas.Object? obj, void* event_info )
    {

		// GPS Radio Policy toggle
        pol_tog = new Elm.Toggle( this.box );
        pol_tog.scale_set(1.4);
        pol_tog.label_set("GPS reception");
        pol_tog.smart_callback_add( "changed", cb_gpsPol_tog_changed);
        pol_tog.size_hint_weight_set( 1.0, 0.0 );
        pol_tog.show();
        this.box.pack_start( pol_tog );

        gpsinfo_f = new Elm.Frame( this.box );
        gpsinfo_f.size_hint_weight_set( 1.0, 1.0 );
        gpsinfo_f.size_hint_align_set( -1.0, -1.0 );
        gpsinfo_f.label_set("GPS info");
        gpsinfo_f.show();
        this.box.pack_end( gpsinfo_f );

		barchart = new Evas.Image ( gpsinfo_f.evas_get() );
        //barchart.filled_set ( true );
        barchart.size_set( 200, 200 );
        barchart.alpha_set ( true );
		debug("1");
        weak string data = barchart.data_get( true );
		debug("2");
		bchart = new Barchart();
		bchart.create_img( data, 200, 200 );
		debug("3");
		barchart.data_set( data );
        barchart.data_update_add ( 0, 0, 200, 200);
		debug("4");
        int h, w;
        barchart.size_get( out h, out w );
        debug("size2 %d,%d",h,w);
        //barchart.file_set("/home/spaetz/src/shr-config/data/icon_gps.png", "key"); //"/usr/share/icons/xine.xpm", "key");// 
        barchart.show();
        gpsinfo_f.content_set( (Elm.Object) barchart );

        this.win.show();
    }

    public override string? name()
    {
        return "GPS";
    }

    public override string? icon()
    {
        return "/usr/share/shr-config/icons/icon_gps.png";
    }
}
