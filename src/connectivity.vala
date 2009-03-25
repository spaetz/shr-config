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
    Toggle bt_power;
    Toggle wifi_power;

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

        offline_mode = new Elm.Button( this.box );
        offline_mode.size_hint_align_set(  -1.0, -1.0 );
        offline_mode.size_hint_weight_set( 1.0, 0.0 );
        offline_mode.show();
        offline_mode.label_set( "Offline Mode" );     
        power_table.pack( offline_mode, 0, 0, 3, 1);


        bool gsm_status = dbus_gsm.GetAntennaPower();
        gsm_power = new Elm.Toggle( this.box );
        gsm_power.state_set( gsm_status );
        gsm_power.show();
        gsm_power.smart_callback_add( "changed", cb_gsmpower_changed );
        gsm_power.label_set( "GSM Modem" );     
        power_table.pack( gsm_power, 0, 1, 2, 1);

        bool bt_status = dbus_bt.GetPower();
        debug("current bt state is %d", (int) bt_status );
        bt_power = new Elm.Toggle( this.box );
        bt_power.state_set( bt_status );
        bt_power.show();
        bt_power.smart_callback_add( "changed", cb_btpower_changed );
        bt_power.label_set( "Bluetooth" );     
        power_table.pack( bt_power, 0, 2, 2, 1);

        debug("before" );
        bool wifi_status = dbus_wifi.GetPower();
        debug("after");
        debug("current wifi state is %d", (int)wifi_status );
        wifi_power = new Elm.Toggle( this.box );
        wifi_power.state_set( wifi_status );
        wifi_power.show();
        wifi_power.smart_callback_add( "changed", cb_wifipower_changed );
        wifi_power.label_set( "WiFi" );     
        power_table.pack( wifi_power, 0, 3, 2, 1);

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