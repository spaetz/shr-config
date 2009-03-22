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
public class Setting.ValueSlider {
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

public abstract class Setting.Abstract
{
    //protected Elm.Box win; and it's main elm elements
    protected Elm.Win win;
    protected Elm.Box box;
    //private Elm.Button quitbt;
    private Elm.Bg bg;

    //public MainLoop loop { set; get; }
    
    public void init()
    {
        debug( "init module %s", name() );
        win = new Win( null, "settings", WinType.BASIC );
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
         * //quitbt.smart_callback_add( "clicked", close );
         * quitbt.smart_callback_add( "clicked", this.cb_back_to_main );
         * box.pack_end( quitbt );
         */

    }
    /*
    private void cb_back_to_main() {
        // TODO disable GUI updates and stuff
        debug("closing module window");
        this.win.hide();
    }
    */

    public abstract void run( Evas.Object obj, void* event_info ) throws GLib.Error;

    public void close()
    {
        debug( "close window" );
        win = null; // will call evas_object_del, hence close the window
        box = null;
        // finally init() this module again. Counterintuitive, but we might
        // want to open it a second time and it needs to be inited then.
        this.init( );
    }

    public abstract string name();
    public abstract string icon();

}
