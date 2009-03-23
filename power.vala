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
 * Setting.Power is a vala-settings plugin that display blanking timeout
 * and other power related settings
*/
public class Setting.Power : Setting.Abstract
{
    private DBus.Connection dbus;
    private dynamic DBus.Object dbus_disp; //Display
    private dynamic DBus.Object dbus_res;  //ResourcePolcies
    private dynamic DBus.Object dbus_idle; //IdleNotifier

    // brightness slider elements
    private Elm.Box bright_box;
    private ValueSlider bright;

    // dim/suspend Policy elements
    private Elm.Frame dimPol_frame;
    private Elm.Table dimPol_table;
    private Elm.Label dimPol_lab;
    private Elm.Toggle dimPol_tog;
    private Elm.Label suspPol_lab;
    private Elm.Toggle suspPol_tog;

    // timeout elements
    private Elm.Frame tout_frame;
    private string[] tout_strs = {"idle_dim","suspend"};
    private Elm.Table tout_table;
    private ValueSlider[] tout_sli;
    private Elm.Check adv_tout;

    /* Constructor of the class */
    construct {
       debug("Power() constructor");
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

       this.dbus_idle = dbus.get_object ( "org.freesmartphone.odeviced",
                                  "/org/freesmartphone/Device/IdleNotifier/0",
                                  "org.freesmartphone.Device.IdleNotifier" );
       //self.timeouts = this.dbus_idle.GetTimeouts(); // "busy""idle""idle_dim""idle_prelock""lock""suspend""awake"
      // async calls return GLib.HashTable<string,int>? timeouts, GLib.Error? err)
       // TODO: SetTimeout ( si ), listen to Signal: State ( s ) Method: GetState()
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
           dbus_res.SetResourcePolicy( res, "auto" );
           this.suspPol_tog.show();
       } else {
           // toggle moved to off, enable Resource permanently
           dbus_res.SetResourcePolicy( res, "enabled" );
           // if Display dimming is disabled,
           // hide the nonsensical suspend option.
           if (res == "Display") this.suspPol_tog.hide();
       }
    }


    public void cb_change_bright(  Evas.Object obj, void* event_info)
    {
       Elm.Slider* p_sli = obj;
       int newval = (int) p_sli->value_get();
       //TODO: put dbus call in a separate method that throws DBus Errors
       dbus_disp.SetBrightness ( newval );
       debug("Set new brightness value %d", newval);
    }


    public void cb_change_tout_value(  Evas.Object obj, void* event_info) {
       Elm.Slider* p_sli = obj;
       int newval = (int) p_sli->value_get();
       debug("Change timeout for %s to %d", p_sli->name_get(), newval );
       dbus_idle.SetTimeout( p_sli->name_get(), newval );
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

        // add the Brightness slider
        bright  = new Setting.ValueSlider( bright_box );
        bright.label.label_set( "Brightness" );
        bright.slider.min_max_set( 5, 100 );
        bright.value_set( brightval );
        bright.slider.smart_callback_add( "delay,changed", this.cb_change_bright);
        bright.show();

        bright_box.pack_end(bright.label);
        bright_box.pack_end(bright.slider);
        bright_box.pack_end(bright.vlabel);
        // End of Brightness slider

        // Dim/Suspend Policy

        dimPol_frame = new Elm.Frame( box );
        //dimPol_frame.style_set( "outdent_top" ); 
        dimPol_frame.size_hint_align_set( -1.0, -1.0 );
        dimPol_frame.size_hint_weight_set( 1.0, 0.0 );
        dimPol_frame.label_set( "Dim/Suspend policies" );
        dimPol_frame.show();
        box.pack_start( dimPol_frame );

        dimPol_table = new Elm.Table( dimPol_frame );
        dimPol_table.size_hint_align_set( -1.0, -1.0 );
        dimPol_table.size_hint_weight_set( 1.0, 0.0 );
        dimPol_table.show();
        dimPol_frame.content_set( dimPol_table );

        dimPol_lab = new Elm.Label( box );
        dimPol_lab.size_hint_align_set( -1.0, 0.5 );
        dimPol_lab.show();
        dimPol_lab.label_set( "Screen");
        dimPol_table.pack ( dimPol_lab, 0, 0, 1, 1 );

        dimPol_tog = new Elm.Toggle( box );
        dimPol_tog.name_set( "Display" );
        dimPol_tog.scale_set( 1.4 );
        dimPol_tog.size_hint_weight_set( 1.0, 1.0 );
        string dimPol = dbus_res.GetResourcePolicy( "Display" );
        dimPol_tog.state_set( dimPol != "enabled" );
        dimPol_tog.show();
        dimPol_tog.smart_callback_add( "changed", cb_dimsuspPol_tog_changed );
        dimPol_table.pack ( dimPol_tog, 1, 0, 1, 1 );


        suspPol_lab = new Elm.Label( box );
        suspPol_lab.size_hint_align_set( -1.0, 0.5 );
        suspPol_lab.show();
        suspPol_lab.label_set( "Suspend");
        dimPol_table.pack ( suspPol_lab, 0, 1, 1, 1 );

        suspPol_tog = new Elm.Toggle( box );
        suspPol_tog.scale_set( 1.4 );
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
        tout_frame = new Elm.Frame( box );
        tout_frame.size_hint_align_set( -1.0, -1.0 );
        tout_frame.size_hint_weight_set( 1.0, 0.0 );
        //tout_frame.style_set( "outdent_top" ); 
        tout_frame.label_set( "Timeout settings" );
        tout_frame.show();
        box.pack_start( tout_frame );

        tout_table = new Elm.Table( box );
        tout_table.size_hint_align_set( -1.0, -1.0 );
        tout_table.size_hint_weight_set( 1.0, 0.0 );
        tout_table.show();
        tout_frame.content_set( tout_table );

        // Get the timeout Hashtable
        // busy, idle, idle_dim, idle_prelock, lock, suspend, awake
        // TODO: need to do async call here?
        GLib.HashTable<string,int>? timeouts = this.dbus_idle.GetTimeouts();

        int row = 0;
        uint num_touts = timeouts.size( );

        // create an array of sufficient size
        tout_sli = new ValueSlider [ num_touts ];

        foreach (string tout_str in tout_strs) {
            int tout = timeouts.lookup( tout_str );
            //debug("%s %d of %d entries", str, tout_str, (int)num_touts );

            // add a new ValueSlider for the timeout
            tout_sli[row] = new ValueSlider ( tout_table );
            tout_sli[row].label.label_set( tout_str.replace("_"," ") );
            tout_sli[row].slider.min_max_set( -1, 60 );
            tout_sli[row].slider.name_set( tout_str );
            tout_sli[row].value_set( tout );
            tout_sli[row].slider.smart_callback_add( "delay,changed", cb_change_tout_value);
            tout_table.pack( tout_sli[row].label, 0, row, 1, 1);
            tout_table.pack( tout_sli[row].slider, 1, row, 1, 1);
            tout_table.pack( tout_sli[row].vlabel, 2, row, 1, 1);
            tout_sli[row].show();

            row += 1;
        }

        adv_tout = new Elm.Check( tout_table );
        tout_table.size_hint_align_set( -1.0, -1.0 );
        tout_table.size_hint_weight_set( 1.0, 0.0 );
        adv_tout.label_set( "Show advanced timeouts." );
        adv_tout.show();
        tout_table.pack( adv_tout, 0, row++, 3, 1);

        // End of timeout table

 
        // Finally show the module window
        this.win.show();
    }

    public override string name()
    {
        return "Power";
    }

    public override string icon()
    {
        return "/usr/share/vala-settings/icons/icon_power.png";
    }

}
