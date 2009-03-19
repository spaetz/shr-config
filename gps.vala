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

public class T.GPS : T.Abstract
{
    Elm.Bg bg;

    public override void run( Evas.Object obj, void* event_info )
    {
        bg = new Elm.Bg( this.win );
        bg.file_set( "data/icon_gps.png" );
        bg.size_hint_weight_set( 1.0, 1.0 );
        bg.size_hint_min_set( 160, 160 );
        bg.size_hint_max_set( 640, 640 );
        bg.show();

        this.win.pack_end( bg );

        Elm.Button quitbt = new Elm.Button( this.win );
        quitbt.size_hint_weight_set( 1.0, 0.0 );
        quitbt.size_hint_align_set( -1.0, -1.0 );
        quitbt.label_set("Quit");
        quitbt.show();
        quitbt.smart_callback_add( "clicked", close );
        this.win.pack_end( quitbt );

        stdout.printf("background");
        p_parent->content_promote ( this.win );
    }

    public override string name()
    {
        return "Window with background";
    }
}
