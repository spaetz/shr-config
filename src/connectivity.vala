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
    Frame power_frame;
    Table power_table;
    Button offline_mode;
    Toggle gsm_power;
    Elm.Label gsm_power_lab;
    Toggle bt_power;
    Elm.Label bt_power_lab;
    Toggle wifi_power;
    Elm.Label wifi_power_lab;

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
        debug("Device %s has changed status to %s", device, (string) status );
    }


    /* callback when offline mode button was clicked */
    private void cb_offlinemode_clicked (  Evas.Object obj, void* event_info ){
        // set GSM/BT/Wifi to off        
        gsm_power.state_set( false );
        bt_power.state_set( false );
        wifi_power.state_set( false );
    }

    /* callback when wifi toggle was switched */
    private void cb_wifipower_changed (  Evas.Object obj, void* event_info ){
       Elm.Toggle* p_tog = obj;
       bool state = p_tog->state_get ( );
       debug("WiFiState is now %d\n", (int) state);
       // do async call to turn on/off wifi
       dbus_wifi.SetPower( state );
    }

    /* callback when bt toggle was switched */
    private void cb_btpower_changed (  Evas.Object obj, void* event_info ){
       Elm.Toggle* p_tog = obj;
       bool state = p_tog->state_get ( );
       debug("BTState is now %d\n", (int) state);
       // do async call to turn on/off bt
       dbus_bt.SetPower( state );
    }

    /* callback when gsm toggle was switched */
    private void cb_gsmpower_changed (  Evas.Object obj, void* event_info ){
       Elm.Toggle* p_tog = obj;
       bool state = p_tog->state_get ( );
       debug("GSMState is now %d\n", (int) state);
       // do async call to turn on/off gsm
       dbus_gsm.SetAntennaPower( state );
    }

    /* callback when gsm toggle was switched on*/
    private void cb_gsmpower_on (  Evas.Object obj, void* event_info ){
       //Elm.Toggle* p_tog = obj;
       //bool state = p_tog->state_get ( );
       debug("GSM Power on!");
       // do async call to turn on/off gsm
       //dbus_gsm.SetAntennaPower( state );
    }

    /* callback when gsm toggle was switched off*/
    private void cb_gsmpower_off (  Evas.Object obj, void* event_info ){
       //Elm.Toggle* p_tog = obj;
       //bool state = p_tog->state_get ( );
       debug("GSM Power off!");
       // do async call to turn on/off gsm
       //dbus_gsm.SetAntennaPower( state );
    }

    public override void run( Evas.Object obj, void* event_info ) throws GLib.Error
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
        gsm_power.label_set( "GSM Modem" );     
        gsm_power_lab.show();
        power_table.pack( gsm_power_lab, 0, 1, 1, 1);

        bool gsm_status = dbus_gsm.GetAntennaPower();
        gsm_power = new Elm.Toggle( power_table );
        gsm_power.state_set( gsm_status );
        gsm_power.scale_set( 1.4 );
        gsm_power.show();
        gsm_power.smart_callback_add( "changed", cb_gsmpower_changed );
        gsm_power.smart_callback_add( "elm,state,toggle,on", cb_gsmpower_on );
        gsm_power.smart_callback_add( "elm,state,toggle,on", cb_gsmpower_off );
        power_table.pack( gsm_power, 1, 1, 1, 1);


        bt_power_lab = new Elm.Label( power_table );
        bt_power_lab.size_hint_align_set( -1.0, 0.5 );
        bt_power.label_set( "Bluetooth" );     
        bt_power_lab.show();
        power_table.pack( bt_power_lab, 0, 2, 1, 1);

        bool bt_status = dbus_bt.GetPower();
        debug("current bt state is %d", (int) bt_status );
        bt_power = new Elm.Toggle( power_table );
        bt_power.state_set( bt_status );
        bt_power.scale_set( 1.4 );
        bt_power.show();
        bt_power.smart_callback_add( "changed", cb_btpower_changed );
        power_table.pack( bt_power, 0, 2, 1, 1);


        wifi_power_lab = new Elm.Label( power_table );
        wifi_power_lab.size_hint_align_set( -1.0, 0.5 );
        wifi_power.label_set( "Bluetooth" );     
        wifi_power_lab.show();
        power_table.pack( wifi_power_lab, 0, 3, 1, 1);

        bool wifi_status = dbus_wifi.GetPower();
        debug("current wifi state is %d", (int)wifi_status );
        wifi_power = new Elm.Toggle( power_table );
        wifi_power.state_set( wifi_status );
        wifi_power.scale_set( 1.4 );
        wifi_power.show();
        wifi_power.smart_callback_add( "changed", cb_wifipower_changed );
        wifi_power.label_set( "WiFi" );     
        power_table.pack( wifi_power, 0, 3, 1, 1);

        this.box.pack_start( power_frame );
        this.win.show();
    }

    public override string name()
    {
        return "Connectivity";
    }

    public override string icon()
    {
        return "/usr/share/vala-settings/icons/icon_connectivity.png";
    }
}
