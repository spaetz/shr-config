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
	// array that keeps handles to idlers so they don't go away.
    Ecore.Idler[] idler;

    //profile selection items
    Elm.Table prof_table;
    Elm.Label cur_prof;
    Elm.Label cur_prof_v;
    Elm.Hoversel profile_sel;

    // profile characteristics. inited in class constructor
    static GLib.HashTable<string, pro_item?> pro_items;
    // links hoversel items to profile names
    GLib.HashTable<HoverselItem*,string> hItem_map;

    //
    struct pro_item {
        public string name;
        public Elm.Label* name_lab;
        public Elm.Label* val_lab;
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

	   // hook up the notify signal
	   dbus_pro_set.notify += cb_pref_changed;

       //dbus_pro_set = dbus.get_object ("org.freesmartphone.opreferencesd",
       //                         "/org/freesmartphone/Preferences/phone",
       //                         "org.freesmartphone.Preferences.Service");


       //"/Org/Freesmartphone/Preferences/profiles",
       //"org.freesmartphone.Preferences.Service");
       //[METHOD] .GetKeys() .GetType( s:key ) .GetValue( s:key ) 
       //         .IsProfilable( s:key ) .SetValue( s:key, v:value )
       //[SIGNAL] .Notify( s:key, v:value )

	   //create map from hoverselItem to profile name. populated later
	   hItem_map = new GLib.HashTable<HoverselItem,string>(direct_hash, direct_equal);

       pro_items = new GLib.HashTable<string,pro_item?>(GLib.str_hash, GLib.str_equal);
       pro_items.insert( "ring-tone", pro_item() {name="Ringtone"});
       pro_items.insert( "ring-volume", pro_item() {name="Ring volume"});
       pro_items.insert( "ring-loop", pro_item() {name="Ring loop"});
       pro_items.insert( "ring-length", pro_item() {name="Ring length"});
       pro_items.insert( "message-tone", pro_item() {name="Message tone"});
       pro_items.insert( "message-volume", pro_item() {name="Message volume"});
       pro_items.insert( "message-loop", pro_item() {name="Message loop"});
       pro_items.insert( "message-length", pro_item() {name="Message length"});
    }


	/*
	 * callback, when a new profile was selected from hoversel
	 */
    public void cb_profile_selected( Evas.Object obj, void* event_info ){
		string? profile = hItem_map.lookup( event_info );
		debug("selected a profile. How nice %s .", profile);
	   try{
		   dbus_profile.SetProfile( profile );
	   } catch ( DBus.Error ex ) {
		   // failed
		   debug ("Failed to set profiles via DBus");
           return;
	   } catch ( GLib.Error ex) {
		   // other failure. no dbus conection?
		   debug ("Failed DBus connection");
		   return;
	   }
       // update the profile characteristics
	   // obs: idler2 was used in run() but is unused by now
	   idler += new Idler(cb_idler_getprofiledata);
    } 



    /* Idler gets called to populate the hoversel */
    public bool cb_idler_getprofiles ( ) {
        debug("Entering idler. Fetch profiles");
        string[] profiles = {};

        //issue dbus calls to get name of all profiles and of current one
        try {
            profiles = dbus_profile.GetProfiles( );
        } catch ( DBus.Error ex ) {
            // failed
            debug ("Failed to fetch profiles via DBus");
            return false;
        } catch ( GLib.Error ex) {
            // other failure. no dbus conection?
            debug ("Failed DBus connection");
            return false;
        }

        //populate hoversel with all profile names and store handle to item
        for (int i = 0; i < profiles.length; i++) {
            unowned HoverselItem item = profile_sel.item_add( profiles[ i ], 
								        "", Elm.IconType.NONE, 
										cb_profile_selected);
			// store linkage between HoverselItem handle to profile name
			hItem_map.insert(item, profiles[i] );
        }
        return false; //don't run idler again
    }


    //-------------------------------------------------------------
    /* 
     * callback when a pref gets changed
     */
    private void cb_pref_changed (FreeSmartphone.PreferencesService pref, 
								  string key, Value val ) {
        debug("received value changed signal");
    }



    //-------------------------------------------------------------
    /* 
     * Idler gets called to populate or update the current profile data 
     */
    public bool cb_idler_getprofiledata ( ) {
		// table row is a counter to determine which table row to populate
        int table_row = 1;
		string current_profile;
		try {
			current_profile = dbus_profile.GetProfile( );
		} catch (DBus.Error ex) {
			critical("Could not get profile attributes via DBus: %s", ex.message);
			return false;  // don't run idler again
		}

        //set name of current profile on Hoversel and text label
		profile_sel.label_set( current_profile );
        cur_prof_v.label_set( current_profile );

        //'ring-loop''message-loop''ring-tone','ring-length','message-tone',
        //'ring-volume','message-volume','message-length'
        foreach (string str in pro_items.get_keys()) {
            debug("handling %s",str);
			table_row += 1;
            string strval = "";

			try {
				//TODO, can't the type be inferred without additional DBus call?
				string type = dbus_pro_set.get_type_( str );
				Value val = dbus_pro_set.get_value( str );
				if (type=="str") {
					strval = val.get_string();
				} else if (type=="int") {
					strval = val.get_int().to_string();
				}
			} catch (DBus.Error ex) {
				critical("Could not get profile attributes via DBus: %s", ex.message);
				return false;  // don't run idler again
			}
			// create or update the name label
			unowned pro_item? item = pro_items.lookup( str );
            if (item == null) {debug("not found proitem %s", str);}
			else {
				if (item.name_lab == null) {
					// first run. Create a new name and value label
					debug("first run, create new name label");
					item.name_lab = new Elm.Label( prof_table );
					item.name_lab->label_set( item.name );
					item.name_lab->size_hint_weight_set( 0, 0 );
					item.name_lab->size_hint_align_set( -1.0, -1.0 );
					item.name_lab->show();
					prof_table.pack( item.name_lab, 0, table_row, 1, 1);

					item.val_lab = new Elm.Label( prof_table );
					item.val_lab->size_hint_weight_set( 0, 0 );
					item.val_lab->size_hint_align_set( -1.0, -1.0 );
					item.val_lab->show();
					prof_table.pack( item.val_lab, 1, table_row, 1, 1);
				}
				// update value label on creating and updating
				item.val_lab->label_set( strval );
			}
        } 
        return false;
   }

    public override void run( Evas.Object? obj, void* event_info )
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

        idler  = new Ecore.Idler[0];
		idler += new Ecore.Idler( cb_idler_getprofiles );
        idler += new Ecore.Idler( cb_idler_getprofiledata );
        this.win.show();
    }

    public override string? name()
    {
        return "Profiles";
    }

    public override string? icon()
    {
        return "/usr/share/vala-settings/icons/icon_profiles.png";
    }
}
