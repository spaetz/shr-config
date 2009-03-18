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

public abstract class T.Abstract
{
    //protected Elm.Box win;
    public Elm.Box win;
    //public DBus.Connection conn { set; get; }
    //private DBus.Connection conn;
    //private dynamic DBus.Object bluez;
    //public MainLoop loop { set; get; }
    public Elm.Pager* p_parent;
    
    public void init(Elm.Pager par)
    {
        debug( "init module " );
        this.p_parent = par;
        this.win = new Elm.Box( par );
        this.win.size_hint_align_set( -1.0, -1.0 );
        this.win.size_hint_weight_set( 1.0, 1.0 );
        //this.win.homogenous_set( true );
        //win.smart_callback_add( "delete-request", close );
        //win.resize( 320, 320 );

        Elm.Bg bg = new Elm.Bg( this.win );
        bg.size_hint_weight_set( 1.0, 1.0 );
        bg.show();
        this.win.pack_end( bg );

        Elm.Label l = new Elm.Label( this.win );
        l.label_set(" Hello world ");
        l.show();
        this.win.pack_start( l );
        stdout.printf("Added label");
        Elm.Button quitbt = new Elm.Button( this.win );
        quitbt.label_set("Quit");
        quitbt.size_hint_weight_set( 1.0, 1.0 );
        quitbt.show();
        //quitbt.smart_callback_add( "clicked", close );
        this.win.pack_end( quitbt );
        this.win.show();

    }

    public abstract void run( Evas.Object obj, void* event_info );

    public void close()
    {
        debug( "close window" );
        win = null; // will call evas_object_del, hence close the window
    }

    public abstract string name();
}

