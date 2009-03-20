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

public class T.Power : T.Abstract
{
    private DBus.Connection dbus;
    private dynamic DBus.Object dbus_disp;

    //brightness slider elements
    private Elm.Box bright_box;
    private Elm.Label bright_label;
    private Elm.Label bright_v_label;
    private Elm.Slider bright;


    public Power()
    {
        /*itcfunc = Elm.GenlistItemClassFunc() { label_get = getLabel,
                                               icon_get  = getIcon,
                                               state_get = getState,
                                               del       = delItem };

        itc.item_style = "default";
        itc.func = itcfunc;
       */

       this.dbus = DBus.Bus.get (DBus.BusType.SYSTEM);
       this.dbus_disp = dbus.get_object ("org.freesmartphone.odeviced",
                                 "/org/freesmartphone/Device/Display/0",
                                 "org.freesmartphone.Device.Display");

       //SetBrightness(i), GetBrightness, GetBacklightPower, SetBacklightPower(b), GetName

        // dbus signals
        //this.bluez.RemoteDeviceFound += remote_device_found;
        // async dbus call
        //this.bluez.DiscoverDevices ();
        // 
    //private void remote_device_found (dynamic DBus.Object bluez,
    //                                  string address_, uint class_, int rssi_) {
    //    message ("Signal: RemoteDeviceFound(%s, %u, %d)", address_, class_, rssi_);
    //}


    }

    public void cb_change_bright_value(  Evas.Object obj, void* event_info)
    {
       Elm.Slider* p_sli = obj;
       int newval = (int) p_sli->value_get();
       bright_v_label.label_set( newval.to_string() );
       //debug("change label to %d", newval);
    }

    public void cb_change_bright_value_delayed(  Evas.Object obj, void* event_info)
    {
       Elm.Slider* p_sli = obj;
       int newval = (int) p_sli->value_get();
       dbus_disp.SetBrightness ( newval );
       debug("Set new brightness value %d", newval);
    }

    public override void run( Evas.Object obj, void* event_info ) throws GLib.Error
    {
        // The brightness slider box
        int brightval = dbus_disp.GetBrightness ();
        bright_box = new Elm.Box( box );
        bright_box.size_hint_align_set( -1.0, -1.0 );
        bright_box.size_hint_weight_set( 1.0, 1.0 );
        bright_box.show();
        bright_box.horizontal_set( true );
        box.pack_start(bright_box);

        bright_label = new Elm.Label(bright_box);
        bright_label.label_set( "Brightness" );
        bright_label.show();


        bright_v_label = new Elm.Label(bright_box);
        bright_v_label.size_hint_align_set( 1.0, 0.5 );
        bright_v_label.label_set( brightval.to_string() );
        bright_v_label.show();

        bright = new Elm.Slider(bright_box);
        bright.size_hint_align_set( -1.0, 0.5 );
        bright.size_hint_weight_set( 1.0, 1.0 );
        bright.min_max_set( 0, 100 );
        bright.value_set( brightval );
        bright.smart_callback_add( "delay,changed", cb_change_bright_value_delayed);
        bright.smart_callback_add( "changed", cb_change_bright_value);
        bright.show();

        bright_box.pack_end(bright_label);
        bright_box.pack_end(bright);
        bright_box.pack_end(bright_v_label);

        this.win.show();
        debug("added label");
    }

    public override string name()
    {
        return "Power";
    }
}
