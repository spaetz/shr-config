/**
 * Copyright (C) 2009 Michael 'Mickey' Lauer <mlauer@vanille-media.de>
 *               2009 Sebastian Spaeth <Sebastian@SSpaeth.de>
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

using Evas;
using Elm;


/* A Category contains necessary information about a module window
 * and inits/runs it.
 */
//------------------------------------------------------------------------
public class Category {
//------------------------------------------------------------------------
	public Setting.Abstract* mod;
	private Type _mod_type;

	public Category(Type mod_type) {
        //Type mod_type = typeof(Setting.Power);
		debug("Register module %s", mod_type.name() );
		_mod_type = mod_type;
		mod = GLib.Object.new (_mod_type, null);
		mod->init();
	}

	private void free_mod_instance() {
		debug("Freeing module %s", _mod_type.name() );
		mod = null;
	}

	public void run( Evas.Object obj, void* event_info ) {
		if (mod == null) {
			debug("Init and Run%s", _mod_type.name() );
			mod = GLib.Object.new (_mod_type, null);
		} else { debug("Just Run%s", _mod_type.name() ); }

		debug("created new instance");
		// connect close signal, so we free the odule after closing
		mod->sig_on_close += free_mod_instance;

		//finally actually run and show the module
		mod->init();
		mod->run( obj, event_info );
	}
}


/* MainApp is the main class that contains the whole application. 
 * MAIN is just executing this one. */
//------------------------------------------------------------------------
public class MainApp {
//------------------------------------------------------------------------
    // command line option handling
	// set default vals like this: static int opt_optionname = 2;
	static string opt_module  = "";
	static bool opt_verbose   = false;
	static bool opt_list_mods = false;

	const OptionEntry[] opt_entries = {
		{ "show-module", 'm', 0, OptionArg.STRING, out opt_module, "Directly show <modname> module screen", "<module>" },
		{ "list-modules", 'l', 0, OptionArg.NONE, out opt_list_mods, "Beep when done", null },
		{ "verbose", 'v', 0, OptionArg.NONE, out opt_verbose, "Be verbose", null },
		{ null }
	};

    // mein menu widgets
	Table table;
	Button[] buttons;
	Icon[] icons;

	private void add_module(Win win, Table table, Category c, int ind ) {
		//stdout.printf ("%s\n", c.name);
		int row = ind / 2;
		int col = ind % 2;

		icons[ind] = new Icon( win );
		icons[ind].file_set( c.mod->icon() );
		icons[ind].smooth_set( false );
		//icons[ind].scale_set( false, false );
		icons[ind].no_scale_set( true );

		buttons[ind] = new Button( win );
		buttons[ind].label_set( c.mod->name() );
		buttons[ind].icon_set( icons[ind] );
		buttons[ind].smart_callback_add( "clicked", c.run );
		buttons[ind].show();
		buttons[ind].size_hint_align_set( 0.5, 0.5 );
		buttons[ind].size_hint_weight_set( 1.0, 1.0 );
		table.pack(buttons[ind], col, row, 1, 1 );
	}


	private int parse_opts( string[args] args ) {
		OptionContext opt_context;
        opt_context = new OptionContext (
			"- central SHR settings administration");
		opt_context.add_main_entries (opt_entries, null);
		//opt_context.add_group (context, gtk_get_option_group (TRUE));

        int retval = 0;

		try { opt_context.parse ( ref args ); }
		catch (GLib.OptionError.UNKNOWN_OPTION e){
			//UNKNOWN_OPTION BAD_VALUE FAILED (OptionArgFunc cb failed)
			stdout.printf ("Option parsing failure:\n%s\n", e.message);
			retval = 2;
			//} catch (GLib.OptionError.BAD_VALUE e){
			//stdout.printf ("Bad value:\n%s\n", e.message);
			//retval = 3;
			//} catch (GLib.OptionError.FAILED e){
			//stdout.printf ("Unspecified Options parsing error:\n%s\n", e.message);
			//retval = 1;
		} finally {
			stdout.printf ("Run '%s --help' to see a full list of available command line options.\n\n", args[0]);
			}
		return retval;
	}


	//Class constructor
	MainApp( string[args] args ) {
		//debug("MainApp constructor");
        //TODO: how to call sys.exit(retval) in vala?
        if (parse_opts( args ) == 0) {
			show_main_menu( args );
		}
	}

	//Class deconstructor
	//~MainApp() {
		//debug("MainApp destructor");
	//}
 
	private int show_main_menu(  string[args] args ) {
		//Setting.Abstract mod = new GLib.Type.from_name("Setting.Power");
		Elm.init( args );

		Win win = new Win( null, "settings", WinType.BASIC );
		win.title_set( "SHR-settings" );
		win.autodel_set( true );
		win.resize( 320, 320 );
		win.smart_callback_add( "delete-request", exit );
		win.show();

		var bg = new Bg( win );
		bg.size_hint_weight_set( 1.0, 1.0 );
		bg.show();
		win.resize_object_add( bg );

		Box box = new Box( win );
		box.size_hint_align_set( -1.0, -1.0 );
		box.size_hint_weight_set( 1.0, 1.0 );
		box.show();
		win.resize_object_add( box );

		table = new Table( box );
		table.size_hint_align_set( -1.0, -1.0 );
		table.size_hint_weight_set( 1.0, 1.0 );
		table.homogenous_set( true );
		table.show();
		box.pack_start( table );

		GLib.SList<Category> categories = new GLib.SList<Category> ();
		categories.append (new Category( typeof( Setting.Connectivity )));
		categories.append (new Category( typeof( Setting.Profiles )));
		categories.append (new Category( typeof( Setting.Power  )));
		categories.append (new Category( typeof( Setting.GPS )));
		categories.append (new Category( typeof( Setting.GPS )));

		// create sufficiently large arrays for Buttons and Icons
		buttons = new Button[categories.length ()];
		icons = new Icon[categories.length ()];

		// iterate over all categories and create buttons
		for (int i = 0; i < categories.length (); i++) {
			Category cat = categories.nth_data(i);
			add_module (win, table, cat, i);
		}

        // Add the main quit button
		Button quitbt = new Button (box);
		quitbt.size_hint_weight_set( 1.0, 0.0 );
		quitbt.size_hint_align_set( -1.0, -1.0 );
		quitbt.label_set("Quit");
		quitbt.smart_callback_add( "clicked", exit );
		quitbt.show();
		box.pack_end( quitbt );

		Elm.run();
		Elm.exit();
		Elm.shutdown();
		return 0;
	}
} //End of MainApp

//------------------------ MAIN -------------------------------------
public int main( string[] args ) {
	new MainApp( args );
    return 0;
}
