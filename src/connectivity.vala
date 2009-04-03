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

public class Setting.Connectivity : Setting.Abstract
{
    DBus.Connection dbus;
    dynamic DBus.Object dbus_wifi; //WiFi power
    dynamic DBus.Object dbus_bt; //Bluetooth power
    dynamic DBus.Object dbus_gsm; //GSM power

    //offline mode elements
    Elm.Frame  power_frame;
    Elm.Table  power_table;
    Elm.Button offline_mode;
    Elm.Toggle gsm_power;
    Elm.Label  gsm_power_lab;
    Elm.Button gsm_more;
    Toggle     bt_power;
    Elm.Label  bt_power_lab;
    Elm.Button bt_more;
    Toggle     wifi_power;
    Elm.Label  wifi_power_lab;
    Elm.Button wifi_more;

    /* Constructor of the class */
    construct
    {
       this.dbus = DBus.Bus.get (DBus.BusType.SYSTEM);
       this.dbus_wifi = dbus.get_object ("org.freesmartphone.odeviced",
                                "/org/freesmartphone/Device/PowerControl/WiFi",
                                "org.freesmartphone.Device.PowerControl");
       this.dbus_bt   = dbus.get_object ("org.freesmartphone.odeviced",
                            "/org/freesmartphone/Device/PowerControl/Bluetooth",
                            "org.freesmartphone.Device.PowerControl");
       //[METHOD].GetName() .GetPower() .Reset() .SetPower( b:power )
       //[SIGNAL] .Power( s:device, b:power )

       this.dbus_wifi.Power += cb_wifi_status_changed;

       this.dbus_gsm = dbus.get_object ("org.freesmartphone.ogsmd",
                                        "/org/freesmartphone/GSM/Device",
                                        "org.freesmartphone.GSM.Device");
    //GetFeatures()GetPowerStatus(). Get|SetAntennaPower( b:power )
    //Get|SetSpeakerVolume( i:modem_volume )
    }

    private void cb_wifi_status_changed(dynamic DBus.Object wifi,
                                        string device, bool status ) {
        // TODO act here!
        //debug("Device %s has changed status to %s", device, (string) status );
        debug("Device %s has changed status to %d", device, (int) status);
    }


    /* callback when offline mode button was clicked */
    private void cb_offlinemode_clicked (  Evas.Object obj, void* event_info ){
        // set GSM/BT/Wifi to off
        set_gsm_power( false );        
        gsm_power.state_set( false );
        set_bt_power( false );        
        bt_power.state_set( false );
        set_wifi_power( false );        
        wifi_power.state_set( false );
    }

    /* callback when wifi toggle was switched */
    private void cb_wifipower_changed (  Evas.Object obj, void* event_info ){
       Elm.Toggle* p_tog = obj;
       bool state = p_tog->state_get ( );
       debug("WiFiState is now %d\n", (int) state);
       // do async call to turn on/off wifi
       set_wifi_power( state );
    }

    /* callback when bt toggle was switched */
    private void cb_btpower_changed (  Evas.Object obj, void* event_info ){
       Elm.Toggle* p_tog = obj;
       bool state = p_tog->state_get ( );
       debug("BTState is now %d\n", (int) state);
       // do async call to turn on/off bt
       set_bt_power( state );
    }


    /* callback when gsm toggle was switched */
    private void cb_gsmpower_changed (  Evas.Object obj, void* event_info ){
       Elm.Toggle* p_tog = obj;
       bool state = p_tog->state_get ( );
       debug("GSMState is now %d\n", (int) state);
       set_gsm_power( state );
    }


    /* function that turns GSM Antenna power on/off */
    private bool set_gsm_power( bool state ) {
       // do async call to turn on/off gsm
       try {
           dbus_gsm.SetAntennaPower( state );
       } catch ( DBus.Error ex ) {
            // failed, not showing the brightness box
            debug ("Failed to reach DBus");
            return false;
       } catch ( GLib.Error ex) {
            // other failure. no dbus conection?
            debug ("Failed DBus connection, not switching GSM power");
            return false;
       }
       return true;
    }

    /* function that turns Bluetooth on/off */
    private bool set_bt_power( bool state ) {
       try {
           dbus_bt.SetPower( state );
       } catch ( DBus.Error ex ) {
            // failed, not showing the brightness box
            debug ("Failed to reach DBus");
            return false;
       } catch ( GLib.Error ex) {
            // other failure. no dbus conection?
            debug ("Failed DBus connection, not switching BT power");
            return false;
       }
       return true;
    }

    /* function that turns WiFi on/off */
    private bool set_wifi_power( bool state ) {
       // do async call to turn on/off wifi
       try {
           dbus_wifi.SetPower( state );
       } catch ( DBus.Error ex ) {
            // failed, not showing the brightness box
            debug ("Failed to reach DBus");
            return false;
       } catch ( GLib.Error ex) {
            // other failure. no dbus conection?
            debug ("Failed DBus connection, not switching WiFi power");
            return false;
       }
       return true;
    }



    public override void run( Evas.Object? obj, void* event_info )
    {
        power_frame = new Elm.Frame( box );
        power_frame.label_set( "Device power status" );
        power_frame.size_hint_align_set( -1.0, -1.0 );
        power_frame.size_hint_weight_set( 1.0, 1.0 );
        power_frame.show();
        power_table  = new Elm.Table( power_frame );
        power_table.size_hint_align_set( -1.0, -1.0 );
        power_table.size_hint_weight_set( 1.0, 1.0 );
        power_table.show();
        power_frame.content_set( power_table );

        offline_mode = new Elm.Button( power_table );
        offline_mode.size_hint_align_set(  -1.0, -1.0 );
        offline_mode.size_hint_weight_set( 1.0, 0.0 );
        offline_mode.show();
        offline_mode.label_set( "Offline Mode" );     
        offline_mode.smart_callback_add( "clicked", cb_offlinemode_clicked );
        power_table.pack( offline_mode, 0, 0, 3, 1);


        gsm_power_lab = new Elm.Label( power_table );
        gsm_power_lab.size_hint_align_set( -1.0, 0.5 );
        gsm_power_lab.label_set( "GSM" );     
        gsm_power_lab.show();
        power_table.pack( gsm_power_lab, 0, 1, 1, 1);


        gsm_power = new Elm.Toggle( power_table );
        gsm_power.scale_set( 1.4 );
		try {
			bool gsm_status = dbus_gsm.GetAntennaPower();
			gsm_power.state_set( gsm_status );
			gsm_power.show();
        } catch ( DBus.Error ex ) {
            // failed
            debug ("Failed to antenna power via DBus");
        } catch ( GLib.Error ex) {
            // other failure. no dbus conection?
            debug ("Failed DBus connection");
        }
        gsm_power.smart_callback_add( "changed", cb_gsmpower_changed );
		power_table.pack( gsm_power, 1, 1, 1, 1);

        gsm_more = new Elm.Button ( power_table );
        gsm_more.label_set( ">" );
        gsm_more.show();
        //gsm_more.smart_callback_add( "changed", cb_gsmpower_changed );
        power_table.pack( gsm_more, 2, 1, 1, 1);

        bt_power_lab = new Elm.Label( power_table );
        bt_power_lab.size_hint_align_set( -1.0, 0.5 );
        bt_power_lab.label_set( "Bluetooth" );     
        bt_power_lab.show();
        power_table.pack( bt_power_lab, 0, 2, 1, 1);


        bt_power = new Elm.Toggle( power_table );
        bt_power.scale_set( 1.4 );
		try {
			bool bt_status = dbus_bt.GetPower();
			bt_power.state_set( bt_status );
			bt_power.show();
			debug("current bt state is %d", (int) bt_status );
        } catch ( DBus.Error ex ) {
            // failed
            debug ("Failed to bluetooth status via DBus");
        } catch ( GLib.Error ex) {
            // other failure. no dbus conection?
            debug ("Failed DBus connection");
        }
        bt_power.smart_callback_add( "changed", cb_btpower_changed );
        power_table.pack( bt_power, 1, 2, 1, 1);

        bt_more = new Elm.Button ( power_table );
        bt_more.label_set( ">" );
        bt_more.show();
        //gsm_more.smart_callback_add( "changed", cb_gsmpower_changed );
        power_table.pack( bt_more, 2, 2, 1, 1);


        wifi_power_lab = new Elm.Label( power_table );
        wifi_power_lab.size_hint_align_set( -1.0, 0.5 );
        wifi_power_lab.label_set( "WiFi" );     
        wifi_power_lab.show();
        power_table.pack( wifi_power_lab, 0, 3, 1, 1);

        wifi_power = new Elm.Toggle( power_table );
        wifi_power.scale_set( 1.4 );
		try {
			bool wifi_status = dbus_wifi.GetPower();
			wifi_power.state_set( wifi_status );
			wifi_power.show();
			debug("current wifi state is %d", (int)wifi_status );
        } catch ( DBus.Error ex ) {
            // failed
            debug ("Failed to bluetooth status via DBus");
        } catch ( GLib.Error ex) {
            // other failure. no dbus conection?
            debug ("Failed DBus connection");
        }
        wifi_power.smart_callback_add( "changed", cb_wifipower_changed );
        power_table.pack( wifi_power, 1, 3, 1, 1);

        wifi_more = new Elm.Button ( power_table );
        wifi_more.label_set( ">" );
        wifi_more.show();
        //gsm_more.smart_callback_add( "changed", cb_gsmpower_changed );
        power_table.pack( wifi_more, 2, 3, 1, 1);

        this.box.pack_start( power_frame );
        this.win.show();
    }

    public override string? name()
    {
        return "Connectivity";
    }

    public override string? icon()
    {
        return "/usr/share/vala-settings/icons/icon_connectivity.png";
    }
}
