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
    Ecore.Idler idler;
    Elm.Hoversel profile_sel;
    const string str = "123456789dfdgdfgdgdfg";

    /* Constructor of the class */
    construct {
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


    public void cb_profile_selected( Evas.Object obj, void* event_info ){
       debug("selected a profile. How nice.");
    } 



    /* Idler gets called to populate the hoversel */
    public bool cb_idler_getprofiles ( ) {
        debug("Entering idler. Fetch profiles");
        string[] profiles = {};
        try {
            profiles = dbus_profile.GetProfiles( );
        } catch ( DBus.Error ex ) {
            // failed
            debug ("Failed to fetch profiles via DBus");
        } catch ( GLib.Error ex) {
            // other failure. no dbus conection?
            debug ("Failed DBus connection");
        }

        for (int i = 0; i < profiles.length; i++) {
            string profile = profiles[ i ];
            debug("%s", profile);
            //profile_sel.item_add( string label, string icon_file, IconType icon_type, Evas.SmartCallback func );
            profile_sel.item_add( profile, "", Elm.IconType.NONE, cb_profile_selected );
        }
        return false; //don't run again
    }

    public override void run( Evas.Object obj, void* event_info )
    {
        profile_sel = new Elm.Hoversel( this.box );
        profile_sel.label_set( "Profiles" );
        profile_sel.hover_parent_set( box );
        profile_sel.size_hint_weight_set( 0, 0 );
        profile_sel.size_hint_align_set( 0.5, 1.0 );
        profile_sel.show();
        this.box.pack_start(profile_sel );

        idler = new Ecore.Idler( cb_idler_getprofiles );
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
