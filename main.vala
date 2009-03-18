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

using Evas;
using Elm;

Table table;
Button[] buttons;

public void add_module(Win win, Table table, Category c, int ind )
{
    stdout.printf ("%s\n", c.name);
    int row = ind / 2;
    int col = ind % 2;
    stdout.printf ("%d %d\n", row, col);
    
    buttons[ind] = new Button( win );
    buttons[ind].label_set( c.name );
    buttons[ind].smart_callback_add( "clicked", c.mod.run );
    buttons[ind].show();
    buttons[ind].size_hint_align_set( 0.5, 0.5 );
    buttons[ind].size_hint_weight_set( 1.0, 1.0 );
    table.pack(buttons[ind], row, col, 1, 1 );
}

public class Category {
    public T.Abstract mod;
    public string name;
}

public int main( string[] args )
{
    debug( "main()" );
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

    Pager mainpager = new Pager (win);
    mainpager.size_hint_weight_set( 1.0, 1.0 );
    win.resize_object_add( mainpager );

    Box box = new Box( win );
    box.size_hint_align_set( -1.0, -1.0 );
    box.size_hint_weight_set( 1.0, 1.0 );
    box.show();
    mainpager.content_push( box );

    table = new Table( box );
    table.size_hint_align_set( -1.0, -1.0 );
    table.size_hint_weight_set( 1.0, 1.0 );
    table.homogenous_set( true );
    table.show();
    box.pack_start( table );

    GLib.SList<Category> categories = new GLib.SList<Category> ();
    categories.append (new Category(){mod= new T.Power(), name="Power"});
    categories.append (new Category(){mod= new T.Power(), name="Display"});
    categories.append (new Category(){mod= new T.GPS(), name="GPS"});
  
    stdout.printf ("categories.length () = %u\n", categories.length ());
    buttons = new Button[categories.length ()];

    // iterate over all categories and create buttons
    for (int i = 0; i < categories.length (); i++) {
        Category cat = categories.nth_data(i);
        cat.mod.init( mainpager );
        mainpager.content_push( cat.mod.win );
        add_module (win, table, cat, i);
    }


    Button quitbt = new Button (box);
    quitbt.size_hint_weight_set( 1.0, 0.0 );
    quitbt.size_hint_align_set( -1.0, -1.0 );
    quitbt.label_set("Quit");
    quitbt.smart_callback_add( "clicked", exit );
    quitbt.show();
    box.pack_end( quitbt );

    mainpager.content_promote( box );
    mainpager.show();
    stdout.printf ("before runloop\n");
    run();
    shutdown();
    return 0;
}
