/**
 * Copyright (C) 2009 Michael 'Mickey' Lauer <mlauer@vanille-media.de>
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


/*  ValueSlider provides a name label, a slider, and a value label
 *  it updates the value when the slider is moved. The elements still need to
 *  be manually packed into a table, box, etc.
 */
/*---------------------------------------------------------------*/
public class Setting.ValueSlider {
/*---------------------------------------------------------------*/
    public Elm.Label label;
    public Elm.Slider slider;
    public Elm.Label vlabel;

    public ValueSlider( Elm.Object parent ) {
        init( parent );
    }

    private void init(  Elm.Object parent ) {
        label  = new Elm.Label( parent );
        slider = new Elm.Slider( parent );
        vlabel = new Elm.Label( parent );

        label.size_hint_align_set( -1.0, 0.5 );
        vlabel.size_hint_align_set( 1.0, 0.5 );
        slider.size_hint_align_set( -1.0, 0.5 );
        slider.size_hint_weight_set( 1.0, 0.0 );

        //slider.smart_callback_add( "delay,changed", cb_change_value_delayed);
        slider.smart_callback_add( "changed", cb_change_value);
    }

    /*Callback to update the the value label when the value changed*/
    public void cb_change_value ( Evas.Object obj, void* event_info ) {
       Elm.Slider* p_sli = obj;
       int newval = (int)p_sli->value_get();
       vlabel.label_set( newval.to_string() );
    }

    // show() all the elements
    public void show ( ) {
        label.show();
        slider.show();
        vlabel.show();
    }

    // set the sliders value. Also update value label as no callback for
    // event "changed" is issued when value_set()'ting. (consider that elm bug)
    public void value_set ( int value ) {
        slider.value_set( value );
        vlabel.label_set( value.to_string() );
    }
}

/*---------------------------------------------------------------*/
public abstract class Setting.Abstract : GLib.Object
/*---------------------------------------------------------------*/
{
    //protected Elm.Box win; and it's main elm elements
    protected Elm.Win win;
    public Elm.Box box;
    //private Elm.Button quitbt;
    private Elm.Bg bg;

    //public MainLoop loop { set; get; }

    // A signal that tells main() to 'free' this module
    protected signal void sig_on_close ();

	// call Elm.exit() after on closing this module?
	public bool exit_on_close {
		get; set; default = false;
	}

    public void init( Elm.Object? parent )
    {
        //debug( "init module %s", name() );
        win = new Win( parent, this.name(), WinType.BASIC );
        win.title_set( name() );
        win.autodel_set( true );
        win.resize( 320, 320 );
        win.smart_callback_add( "delete-request", close );
        //win.show();

        //this.win.smart_callback_add( "delete-request", close );
        //win.resize( 320, 320 );

        bg = new Elm.Bg( this.win );
        bg.size_hint_weight_set( 1.0, 1.0 );
        bg.show();
        this.win.resize_object_add( bg );

        box = new Elm.Box(win);
        box.size_hint_weight_set( 1.0, 1.0 );
        box.show();
        win.resize_object_add(box);

        /* disable quit button on module windows!
         * quitbt = new Elm.Button( this.win );
         * quitbt.label_set("Quit");
         * quitbt.size_hint_weight_set( 1.0, 0.0 );
         * quitbt.size_hint_align_set( -1.0, 1.0 );
         * quitbt.show();
         * quitbt.smart_callback_add( "clicked", close );
         * //quitbt.smart_callback_add( "clicked", this.cb_back_to_main );
         * box.pack_end( quitbt );
         */

    }


    public abstract void run( Evas.Object? obj, void* event_info );

    public void close()
    {
        win = null; // will call evas_object_del, hence close the window

        // send sig to free this module instance
        sig_on_close ();
		// Exit elm if we only show this module window
		if (exit_on_close) {Elm.exit();}
    }

    public abstract string? name();
    public abstract string? icon();

}
