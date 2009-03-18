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

public class T.Power : T.Abstract

{
    public Power()
    {
        /*itcfunc = Elm.GenlistItemClassFunc() { label_get = getLabel,
                                               icon_get  = getIcon,
                                               state_get = getState,
                                               del       = delItem };

        itc.item_style = "default";
        itc.func = itcfunc;
       */
        //this.conn = DBus.Bus.get (DBus.BusType.SYSTEM);
        //this.bluez = conn.get_object ("org.bluez", "/org/bluez/hci0", "org.bluez.Adapter");

        // dbus signals
        //this.bluez.RemoteDeviceFound += remote_device_found;
        // async dbus call
        //this.bluez.DiscoverDevices ();
        // 
    //private void remote_device_found (dynamic DBus.Object bluez,
    //                                  string address_, uint class_, int rssi_) {
    //    message ("Signal: RemoteDeviceFound(%s, %u, %d)", address_, class_, rssi_);
    //}


    }

    public override void run( Evas.Object obj, void* event_info )
    {
        debug("before added label");

        Elm.Button quitbt = new Elm.Button( this.win );
        quitbt.label_set("Quit");
        quitbt.show();
        quitbt.smart_callback_add( "clicked", close );
        this.win.pack_end( quitbt );

        this.p_parent->content_promote ( this.win );
        debug("added label");

      /*  list = new Elm.Genlist( win );
        debug( "created genlist %p", list );
        for ( int i = 1; i <= 1000; ++i )
        {
            list.item_append( itc, (void*)i, null, Elm.GenlistItemFlags.NONE, onSelectedItem );
        }
        list.show();
        list.size_hint_weight_set( 1.0, 1.0 );
        win.pack_end( list );
       */
    }

    public override string name()
    {
        return "Power settings";
    }
}
