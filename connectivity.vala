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

public class Setting.Connectivity : Setting.Abstract
{
    DBus.Connection dbus;
    dynamic DBus.Object dbus_disp; //Display

    //offline mode elements
    Frame power_frame;
    Table power_table;
    Button offline_mode;
    Toggle gsm_power;
    Toggle bt_power;
    Toggle wifi_power;

    /* Constructor of the class */
    public Connectivity()
    {
       this.dbus = DBus.Bus.get (DBus.BusType.SYSTEM);
       this.dbus_disp = dbus.get_object ("org.freesmartphone.odeviced",
                                 "/org/freesmartphone/Device/Display/0",
                                 "org.freesmartphone.Device.Display");
    }

    public override void run( Evas.Object obj, void* event_info ) throws GLib.Error
    {
        power_frame = new Elm.Frame( box );
        power_frame.label_set( "Device power status" );
        power_frame.size_hint_align_set( -1.0, -1.0 );
        power_frame.size_hint_weight_set( 1.0, 1.0 );
        power_frame.show();
        power_table  = new Elm.Table( power_frame );
        power_table.size_hint_align_set( -1.0, -1.0 );
        power_table.size_hint_weight_set( 1.0, 1.0 );
        power_table.show();
        power_frame.content_set( power_table );

        offline_mode = new Elm.Button( this.box );
        offline_mode.size_hint_align_set(  -1.0, -1.0 );
        offline_mode.size_hint_weight_set( 1.0, 0.0 );
        offline_mode.show();
        offline_mode.label_set( "Offline Mode" );     
        power_table.pack( offline_mode, 0, 0, 3, 1);

        gsm_power = new Elm.Toggle( this.box );
        gsm_power.show();
        gsm_power.label_set( "GSM Modem" );     
        power_table.pack( gsm_power, 0, 1, 2, 1);

        bt_power = new Elm.Toggle( this.box );
        bt_power.show();
        bt_power.label_set( "Bluetooth" );     
        power_table.pack( bt_power, 0, 2, 2, 1);

        wifi_power = new Elm.Toggle( this.box );
        wifi_power.show();
        wifi_power.label_set( "WiFi" );     
        power_table.pack( wifi_power, 0, 3, 2, 1);

        this.box.pack_start( power_frame );
        this.win.show();
    }

    public override string name()
    {
        return "Connectivity";
    }

    public override string icon()
    {
        return "/usr/share/vala-settings/icons/icon_connectivity.png";
    }
}
