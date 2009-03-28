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
using DBus;
using FreeSmartphone;

namespace FreeSmartphone {
	[DBus (name = "org.freesmartphone.Preferences.Service")]
	public interface PreferencesService : GLib.Object {
		public abstract string[] get_keys() throws DBus.Error;
		public abstract GLib.Value get_value(string key) throws DBus.Error;
		public abstract void set_value(string key, GLib.Value value) throws DBus.Error;
		public abstract bool is_profilable(string key) throws DBus.Error;
		public abstract string get_type_(string key) throws DBus.Error;
		public signal void notify(string key, GLib.Value value);
	}
}

public class Setting.Profiles : Setting.Abstract
{
    DBus.Connection conn;
    dynamic DBus.Object dbus_profile;
    FreeSmartphone.PreferencesService dbus_pro_set;
    Ecore.Idler idler;
    Ecore.Idler idler2;

    //profile selection items
    Elm.Table prof_table;
    Elm.Label cur_prof;
    Elm.Label cur_prof_v;
    Elm.Hoversel profile_sel;

    // profile items in order we want to show them. inited in class constructor
    GLib.HashTable<string,pro_item?> pro_items;

    struct pro_item {
        public string name;
        public Elm.Label* val_label;
    }

    /* Constructor of the class */
    construct {
       this.conn = DBus.Bus.get (DBus.BusType.SYSTEM);
       this.dbus_profile = conn.get_object ("org.freesmartphone.opreferencesd",
                                 "/org/freesmartphone/Preferences",
                                 "org.freesmartphone.Preferences");
       //[METHOD] .Get|SetProfile() .GetProfiles()
       //[METHOD] .GetService( s:name ) .GetServices()

       dbus_pro_set = (FreeSmartphone.PreferencesService) conn.get_object<PreferencesService> ("org.freesmartphone.opreferencesd", "/org/freesmartphone/Preferences/phone");

       //dbus_pro_set = dbus.get_object ("org.freesmartphone.opreferencesd",
       //                         "/org/freesmartphone/Preferences/phone",
       //                         "org.freesmartphone.Preferences.Service");


       //"/Org/Freesmartphone/Preferences/profiles",
       //"org.freesmartphone.Preferences.Service");
       //[METHOD] .GetKeys() .GetType( s:key ) .GetValue( s:key ) 
       //         .IsProfilable( s:key ) .SetValue( s:key, v:value )
       //[SIGNAL] .Notify( s:key, v:value )

       pro_items = new GLib.HashTable<string,pro_item?>(GLib.direct_hash, GLib.str_equal);
       pro_items.insert( "ring-tone", pro_item() {name="Ringtone"});
       pro_items.insert( "ring-volume", pro_item() {name="Ring volume"});
       pro_items.insert( "ring-loop", pro_item() {name="Ring loop"});
       pro_items.insert( "ring-length", pro_item() {name="Ring length"});
       pro_items.insert( "message-tone", pro_item() {name="Message tone"});
       pro_items.insert( "message-volume", pro_item() {name="Message volume"});
       pro_items.insert( "message-loop", pro_item() {name="Message loop"});
       pro_items.insert( "message-length", pro_item() {name="Message length"});
    }


    public void cb_profile_selected( Evas.Object obj, void* event_info ){
       debug("selected a profile. How nice.");
    } 



    /* Idler gets called to populate the hoversel */
    public bool cb_idler_getprofiles ( ) {
        debug("Entering idler. Fetch profiles");
        string[] profiles = {};
        string cur_prof;

        //issue dbus calls to get name of all profiles and of current one
        try {
            profiles = dbus_profile.GetProfiles( );
            cur_prof = dbus_profile.GetProfile( );
        } catch ( DBus.Error ex ) {
            // failed
            debug ("Failed to fetch profiles via DBus");
            return false;
        } catch ( GLib.Error ex) {
            // other failure. no dbus conection?
            debug ("Failed DBus connection");
            return false;
        }

        //set name of current profile
        cur_prof_v.label_set( cur_prof );

        //populate hoversel with all profile names
        for (int i = 0; i < profiles.length; i++) {
            //string profile = ;
            profile_sel.item_add( profiles[ i ], "", Elm.IconType.NONE, cb_profile_selected );
        }
        return false; //don't run again
    }


    //-------------------------------------------------------------
    /* 
     * callback when a pref gets changed
     */
    private void cb_pref_changed (FreeSmartphone.PreferencesService pref, string key, Value val ) {
        debug("received value changed signal");
    }



    //-------------------------------------------------------------
    /* 
     * Idler gets called to populate the current profile data 
     */
    public bool cb_idler_getprofiledata ( ) {
        //[METHOD].GetKeys() .GetType( s:key ) .Get|SetValue(key (,val))
        //[METHOD] .IsProfilable( s:key )
        //[SIGNAL] .Notify( s:key, v:val)

        debug("Idler2");

        // hook up the notify signal
        dbus_pro_set.notify += cb_pref_changed;

        //'ring-loop''message-loop''ring-tone','ring-length','message-tone',
        //'ring-volume','message-volume','message-length'
        foreach (string str in pro_items.get_keys()) {
            debug("handling %s",str);
            string type = dbus_pro_set.get_type_( str );
            Value val = dbus_pro_set.get_value( str );
            if (type=="str") {
              debug("str: %s type", val.get_string());
            } else if (type=="int") {
              debug("int: %d", val.get_int());
            }
        } 
        return false;
   }

    public override void run( Evas.Object obj, void* event_info )
    {
        prof_table = new Elm.Table( this.box );
        prof_table.size_hint_weight_set( 1.0, 1.0 );
        prof_table.size_hint_align_set( -1.0, -1.0 );
        prof_table.show();
        this.box.pack_start( prof_table );

        profile_sel = new Elm.Hoversel( prof_table );
        profile_sel.label_set( "Profiles" );
        profile_sel.hover_parent_set( box );
        profile_sel.size_hint_weight_set( 0, 0 );
        profile_sel.size_hint_align_set( -1.0, -1.0 );
        profile_sel.show();
        prof_table.pack( profile_sel, 0, 0, 1, 1);

        // current profile label
        cur_prof = new Elm.Label( prof_table );
        cur_prof.label_set( "Current profile: " );
        cur_prof.size_hint_weight_set( 0, 0 );
        cur_prof.size_hint_align_set( -1.0, -1.0 );
        cur_prof.show();
        prof_table.pack( cur_prof, 0, 1, 1, 1);

        // current profile value label
        cur_prof_v = new Elm.Label( prof_table );
        cur_prof_v.label_set( "NA" );
        cur_prof_v.size_hint_weight_set( 0, 0 );
        cur_prof_v.size_hint_align_set( -1.0, -1.0 );
        cur_prof_v.show();
        prof_table.pack( cur_prof_v, 1, 1, 1, 1);

        idler = new Ecore.Idler( cb_idler_getprofiles );
        idler2 = new Ecore.Idler( cb_idler_getprofiledata );
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
