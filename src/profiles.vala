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
using Ecore;

public class Setting.Profiles : Setting.Abstract
{
    DBus.Connection dbus;
    dynamic DBus.Object dbus_profile;

    Elm.Hoversel profile_sel;

    /* Constructor of the class */
    public Profiles()
    {
       this.dbus = DBus.Bus.get (DBus.BusType.SYSTEM);
       this.dbus_profile = dbus.get_object ("org.freesmartphone.opreferencesd",
                                 "/org/freesmartphone/Preferences",
                                 "org.freesmartphone.Preferences");
       //[METHOD] .Get|SetProfile() .GetProfiles()
       //[METHOD] .GetService( s:name ) .GetServices()

       //"/org/freesmartphone/Preferences/profiles",
       //"org.freesmartphone.Preferences.Service");
       //[METHOD] .GetKeys() .GetType( s:key ) .GetValue( s:key ) 
       //         .IsProfilable( s:key ) .SetValue( s:key, v:value )
       //[SIGNAL] .Notify( s:key, v:value )

    }

    public bool cb_idler_getprofiles ( ) {
        debug("Entering idler. Fetch profiles");
        GLib.Array<string> profiles = dbus_profile.GetProfiles( );
        debug("%d",  (int)profiles.length);
        return true; //don't run again
    }

    public override void run( Evas.Object obj, void* event_info )
    {
        profile_sel = new Elm.Hoversel( this.box );
        profile_sel.label_set( "Profiles" );
        profile_sel.size_hint_weight_set( 1.0, 1.0 );
        profile_sel.show();
        this.box.pack_start(profile_sel );

        var idler = new Ecore.Idler( cb_idler_getprofiles );
        this.win.show();
    }

    public override string name()
    {
        return "Profiles";
    }

    public override string icon()
    {
        return "/usr/share/vala-settings/icons/icon_profiles.png";
    }
}
