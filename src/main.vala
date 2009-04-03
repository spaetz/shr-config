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
		//debug("Register module %s", mod_type.name() );
		_mod_type = mod_type;
		mod = GLib.Object.new (_mod_type, null);
        // initialize module with no parent object
		mod->init( null );
	}

	private void free_mod_instance() {
		debug("Freeing module %s", _mod_type.name() );
		mod = null;
	}

	public void run( Evas.Object? obj, void* event_info ) {
		if (mod == null) {
			debug("Init and Run%s", _mod_type.name() );
			mod = GLib.Object.new (_mod_type, null);
		} else { debug("Just Run%s", _mod_type.name() ); }

		debug("created new instance");
		// connect close signal, so we free the odule after closing
		mod->sig_on_close += free_mod_instance;

		//finally actually run and show the module
		mod->init( null );
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
	static string? opt_module  = null;
	static bool opt_verbose   = false;
	static bool opt_list_mods = false;

	const OptionEntry[] opt_entries = {
		{ "show-module", 'm', 0, OptionArg.STRING, out opt_module, "Directly show <modname> module screen", "<module>" },
		{ "list-modules", 'l', 0, OptionArg.NONE, out opt_list_mods, "Beep when done", null },
		{ "verbose", 'v', 0, OptionArg.NONE, out opt_verbose, "Be verbose", null },
		{ null }
	};

    // definition of all available modules is stored here
	static GLib.SList<Category> categories;

    // pointer to command line args
    static string[args] args;

    // main menu widgets
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


	/* is run to parse the command line options
	 * returns: 0 if OK, 1 on failure
     */
	private int parse_opts() {
		OptionContext opt_context;
        opt_context = new OptionContext (
			"- central SHR settings administration");
		opt_context.add_main_entries (opt_entries, null);
		//opt_context.add_group (context, gtk_get_option_group (TRUE));

        int retval = 0;

		try { opt_context.parse ( ref args ); }
		catch (GLib.OptionError e){
			//UNKNOWN_OPTION, BAD_VALUE, FAILED (OptionArgFunc cb failed)
			stdout.printf ("%s\n", e.message);
			stdout.printf ("Run '%s --help' to see a full list of available command line options.\n\n", args[0]);
			retval = 1;
		}
		return retval;
	}


	/*
	 * MainApp class constructor
     */
	MainApp( string[args] args ) {
        // save pointer to args[]
		this.args = args;
        // Elm needs already to be inited when we register modules
		Elm.init( args );

		// define all possible modules here
        categories = new GLib.SList<Category> ();
		categories.append (new Category( typeof( Setting.Connectivity )));
		categories.append (new Category( typeof( Setting.Profiles )));
		categories.append (new Category( typeof( Setting.Power  )));
		categories.append (new Category( typeof( Setting.GPS )));
		categories.append (new Category( typeof( Setting.GPS )));
	}


	/*
	 * MainApp class destructor
     */
	~MainApp() {
		Elm.shutdown();
	}



	/* This is run in order to actually start the MainApp. It returns the error
	 * value that will be handed back to the OS.
	 * returns: 0:OK, 1:option parsing error, 2:module name not found
	 */
	public int run() {
        int retval; //main app return value

		//parse command line and return with error number if necessary
        retval = parse_opts();
        if (retval != 0) {return retval;}

        // Do whatever command line options tell us to do:
		if ( opt_list_mods ) {
			// List all available modules and exit
			stdout.printf("All available modules:\n");
			foreach (Category category in categories) {
				stdout.printf("- %s\n", category.mod->name());
			}
		} else if ( opt_module != null ) {
			// start a specific module window
            bool found = false;
			foreach (Category category in categories) {
				if ( category.mod->name() == opt_module ) {
                    found = true;
					// quit elm after closing this module
					category.mod->exit_on_close = true;
					category.run( null, "");
					Elm.run();
				}
			}
			if (!found) {
				stderr.printf("Could not find module %s\n", opt_module);
                retval = 2;
			};

		} else {
			// show the main window (usually this should happen)
			retval = show_main_menu();
		}

		return retval;
	}
 
	private int show_main_menu( ) {
		//Setting.Abstract mod = new GLib.Type.from_name("Setting.Power");

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
		return 0;
	}
} //End of MainApp

//------------------------ MAIN -------------------------------------
public int main( string[] args ) {
	MainApp app = new MainApp( args );
    return app.run();
}
