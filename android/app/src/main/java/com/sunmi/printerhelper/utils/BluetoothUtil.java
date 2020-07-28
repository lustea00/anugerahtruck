package com.sunmi.printerhelper.utils;

import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.Context;
import android.util.Log;
import android.widget.Toast;


import java.io.IOException;
import java.io.OutputStream;
import java.util.Set;
import java.util.UUID;

/**
 *  Simple package for connecting a sunmi printer via Bluetooth
 */
public class BluetoothUtil {

    private static final UUID PRINTER_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

    private static final String Innerprinter_Address = "00:AA:11:BB:22:CC";

    public static boolean isBlueToothPrinter = true;

    private static BluetoothSocket bluetoothSocket;

    private static BluetoothAdapter getBTAdapter() {
        return BluetoothAdapter.getDefaultAdapter();
    }

    private static BluetoothDevice getDevice(BluetoothAdapter bluetoothAdapter) {
        Log.d("tes", "device kosong tes");
        BluetoothDevice innerprinter_device = null;
        Set<BluetoothDevice> devices = bluetoothAdapter.getBondedDevices();
        for (BluetoothDevice device : devices) {
            if (device.getAddress().equals(Innerprinter_Address)) {
                innerprinter_device = device;
                Log.d("tes", devices.toString());
                break;
            }
            Log.d("tes", "device kosong");
        }
        return innerprinter_device;
    }

    private static BluetoothSocket getSocket(BluetoothDevice device) throws IOException {
        BluetoothSocket socket;
        socket = device.createRfcommSocketToServiceRecord(PRINTER_UUID);
        socket.connect();
        return  socket;
    }

    /**
     * connect bluetooth
     */
    public static boolean connectBlueTooth() {
        if (bluetoothSocket == null) {
            if (getBTAdapter() == null) {
                Log.d("tes",  "R.string.toast_3");
                return false;
            }
            if (!getBTAdapter().isEnabled()) {
                Log.d("tes",  "R.string.toast_4");
                return false;
            }
            BluetoothDevice device;
            if ((device = getDevice(getBTAdapter())) == null) {
                Log.d("tes",  "R.string.toast_5");
                return false;
            }

            try {
                bluetoothSocket = getSocket(device);
                Log.d("tes",  "R.string.toast_7");
            } catch (IOException e) {
                Log.d("tes",  "R.string.toast_6");
                return false;
            }
        } else {
            Log.d("tes", "Socket tidak kosong");
        }
        return true;
    }

    /**
     * disconnect bluethooth
     */
    public static void disconnectBlueTooth(Context context) {
        if (bluetoothSocket != null) {
            try {
                OutputStream out = bluetoothSocket.getOutputStream();
                out.close();
                bluetoothSocket.close();
                bluetoothSocket = null;
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else {
            Log.d("tes",  "Socket kosong 2");
        }
    }

    /**
     *  send esc cmd
     */
    public static void sendData(byte[] bytes) {
        connectBlueTooth();
        if (bluetoothSocket != null) {
            OutputStream out = null;
            try {
                out = bluetoothSocket.getOutputStream();
                out.write(bytes, 0, bytes.length);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }else{
            Log.d("tes",  "Socket kosong 1");
            //TODO handle disconnect event
        }
    }
}
