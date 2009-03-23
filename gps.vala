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

public class Setting.GPS : Setting.Abstract
{
    DBus.Connection dbus;
    dynamic DBus.Object dbus_disp; //Display

    Elm.Bg bg;

    /* Constructor of the class */
    public GPS()
    {
       this.dbus = DBus.Bus.get (DBus.BusType.SYSTEM);
       this.dbus_disp = dbus.get_object ("org.freesmartphone.odeviced",
                                 "/org/freesmartphone/Device/Display/0",
                                 "org.freesmartphone.Device.Display");
    }

    public override void run( Evas.Object obj, void* event_info ) throws GLib.Error
    {
        bg = new Elm.Bg( this.box );
        bg.file_set( "/usr/share/vala-settings/icons/icon_gps.png" );
        bg.size_hint_weight_set( 1.0, 1.0 );
        bg.size_hint_min_set( 160, 160 );
        bg.size_hint_max_set( 640, 640 );
        bg.show();

        this.box.pack_end( bg );

        stdout.printf("background");
        this.win.show();
    }

    public override string name()
    {
        return "blah";
    }

    public override string icon()
    {
        return "/usr/share/vala-settings/icons/icon_gps.png";
    }
}
