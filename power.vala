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

/*
 * T.Power is a vala-settings plugin that display blanking timeout
 * and other power related settings
*/
public class T.Power : T.Abstract
{
    private DBus.Connection dbus;
    private dynamic DBus.Object dbus_disp;
    private dynamic DBus.Object dbus_res;

    // brightness slider elements
    private Elm.Box bright_box;
    private Elm.Label bright_label;
    private Elm.Label bright_v_label;
    private Elm.Slider bright;

    // timeout elements
    private string[] timeouts = {"idle","idle_dim","suspend"};
    private Elm.Table tout_table;

    // dim/suspend Policy elements
    private Elm.Table dimPol_table;
    private Elm.Label dimPol_lab;
    private Elm.Toggle dimPol_tog;
    private Elm.Label suspPol_lab;
    private Elm.Toggle suspPol_tog;

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
       //SetBrightness(i), GetBrightness, GetBacklightPower, 
       //SetBacklightPower(b), GetName
       this.dbus_res = dbus.get_object ("org.freesmartphone.ousaged",
                                 "/org/freesmartphone/Usage",
                                 "org.freesmartphone.Usage");
       // [Get,Set]ResourcePolicy(s), GetResourceState(s), GetResourceUsers(s),
       // ListResources, Reboot, Suspend, RequestResource, ReleaseResource, 
       // Sig: ResourceAvailable( s:resourcename, b:state ), 
       // Sig: ResourceChanged( s:resourcename, b:state, a{sv}:attributes )

       // connect signal if the state of any resource changes
       this.dbus_res.ResourceChanged += cb_resource_changed;
    }

    /*
     * Callback function that is called when a resource state has changed.
     */
    private void cb_resource_changed (dynamic DBus.Object dbus,
                                      string res, bool state, 
                                      string[] str_arr) {
       debug("Resource %s changed!\n", res);
    }


    /*
     * Callback function called by susPol_tog if we switch it
     */
    private void cb_dimsuspPol_tog_changed (  Evas.Object obj, void* event_info ){
       Elm.Toggle* p_tog = obj;
       bool state = p_tog->state_get ( );
       string res = p_tog->name_get ( );
       debug("State is now %d %s\n", (int) state, res );
       if (state) {
           // toggle moved to on, so set ResourcePolicy to Auto
           dbus_res.SetResourcePoliecy( res, "auto" );
           this.suspPol_tog.show();
       } else {
           // toggle moved to off, enable Resource permanently
           dbus_res.SetResourcePolicy( res, "enabled" );
           // if Display dimming is disabled,
           // hide the nonsensical suspend option.
           if (res == "Display") this.suspPol_tog.hide();
       }
    }


    /*
     * Callback function called by the brightness slider when we change it
     */
    private void cb_change_bright_value(  Evas.Object obj, void* event_info )
    {
       Elm.Slider* p_sli = obj;
       int newval = (int) p_sli->value_get();
       bright_v_label.label_set( newval.to_string() );
    }

    public void cb_change_bright_value_delayed(  Evas.Object obj, void* event_info)
    {
       Elm.Slider* p_sli = obj;
       int newval = (int) p_sli->value_get();
       //TODO: put dbus call in a separate method that throws DBus Errors
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
        // End of Brightness slider

        // Dim/Suspend Policy
        dimPol_table = new Elm.Table( box );
        dimPol_table.size_hint_align_set( -1.0, -1.0 );
        dimPol_table.size_hint_weight_set( 1.0, 1.0 );
        dimPol_table.show();
        box.pack_start( dimPol_table );

        dimPol_lab = new Elm.Label( box );
        dimPol_lab.show();
        dimPol_lab.label_set( "Screen dimming");
        dimPol_table.pack ( dimPol_lab, 0, 0, 1, 1 );

        dimPol_tog = new Elm.Toggle( box );
        dimPol_tog.name_set( "Display" );
        dimPol_tog.size_hint_weight_set( 1.0, 1.0 );
        string dimPol = dbus_res.GetResourcePolicy( "Display" );
        dimPol_tog.state_set( dimPol != "enabled" );
        dimPol_tog.show();
        dimPol_tog.smart_callback_add( "changed", cb_dimsuspPol_tog_changed);
        dimPol_table.pack ( dimPol_tog, 1, 0, 1, 1 );


        suspPol_lab = new Elm.Label( box );
        suspPol_lab.show();
        suspPol_lab.label_set( "Suspend");
        dimPol_table.pack ( suspPol_lab, 0, 1, 1, 1 );

        suspPol_tog = new Elm.Toggle( box );
        suspPol_tog.name_set( "CPU" );
        string suspPol = dbus_res.GetResourcePolicy( "CPU" );
        suspPol_tog.state_set( suspPol != "enabled" );
        // only show the toggle if it makes sense
        if ( dimPol_tog.state_get() )
            suspPol_tog.show();
        suspPol_tog.smart_callback_add( "changed", cb_dimsuspPol_tog_changed);
        suspPol_tog.size_hint_weight_set( 1.0, 1.0 );
        dimPol_table.pack ( suspPol_tog, 1, 1, 1, 1 );
        // End of Dim/Suspend Policy


        // The timout table
        tout_table = new Elm.Table( box );
        tout_table.size_hint_align_set( -1.0, -1.0 );
        tout_table.size_hint_weight_set( 1.0, 1.0 );
        tout_table.show();
        box.pack_start(tout_table);

        //for (int i = 0; i < categories.length (); i++) {
        //int i = 0;
        foreach (string str in timeouts) {
            debug(str);
        }
        // End of timeout table

 
        // Finally show the module window
        this.win.show();
    }

    public override string name()
    {
        return "Power";
    }
}
