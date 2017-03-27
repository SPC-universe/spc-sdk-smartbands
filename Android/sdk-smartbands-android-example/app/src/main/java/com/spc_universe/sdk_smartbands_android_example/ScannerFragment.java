package com.spc_universe.sdk_smartbands_android_example;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ListView;

import com.spc_universe.sdk_smartbands_android.controller.WristBandDevice;

public class ScannerFragment extends DialogFragment {

    private static final String TAG = ScannerFragment.class.getSimpleName();

    private OnDeviceSelectedListener onDeviceSelectedListener;
    private DeviceAdapter deviceAdapter;

    Button mScanButton;

    public static ScannerFragment getInstance() {
        return new ScannerFragment();
    }

    public interface OnDeviceSelectedListener {
        void onDeviceSelected(final BluetoothDevice device, final String name);

        void onDialogCanceled();
    }

    @Override
    public void onAttach(final Activity activity) {
        super.onAttach(activity);
        try {
            this.onDeviceSelectedListener = (OnDeviceSelectedListener) activity;
        } catch (final ClassCastException e) {
            throw new ClassCastException(activity.toString() + " must implement OnDeviceSelectedListener");
        }
    }

    @Override
    public void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onResume() {
        super.onResume();
        getActivity().registerReceiver(broadcastReceiver, receiverIntentFilter());
    }

    @Override
    public void onPause() {
        super.onPause();
        getActivity().unregisterReceiver(broadcastReceiver);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
    }

    @Override
    public Dialog onCreateDialog(final Bundle savedInstanceState) {
        final AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        final View dialogView = LayoutInflater.from(getActivity()).inflate(R.layout.fragment_device_selection, null);
        final ListView listview = (ListView) dialogView.findViewById(android.R.id.list);
        listview.setEmptyView(dialogView.findViewById(android.R.id.empty));
        listview.setAdapter(deviceAdapter = new DeviceAdapter(getActivity()));

        builder.setTitle(getString(R.string.scan));
        final AlertDialog dialog = builder.setView(dialogView).create();
        listview.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(final AdapterView<?> parent, final View view, final int position, final long id) {
                dialog.dismiss();
                final BluetoothDevice d = deviceAdapter.getItem(position);
                onDeviceSelectedListener.onDeviceSelected(d, d.getName() == null ? "xx" : d.getName());
            }
        });

        mScanButton = (Button) dialogView.findViewById(R.id.action_scan);
        mScanButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                WristBandDevice.getInstance(getActivity().getApplicationContext()).startLeScan(10000);
            }
        });

        WristBandDevice.getInstance(getActivity().getApplicationContext()).startLeScan(10000);

        return dialog;
    }

    @Override
    public void onCancel(DialogInterface dialog) {
        super.onCancel(dialog);
        onDeviceSelectedListener.onDialogCanceled();
    }

    private static IntentFilter receiverIntentFilter() {
        final IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(MainActivity.ACTION_DEVICE_FOUND);

        return intentFilter;
    }

    private final BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            switch (intent.getAction()) {
                case MainActivity.ACTION_DEVICE_FOUND:
                    BluetoothDevice bluetoothDevice = intent.getParcelableExtra("device");
                    if(bluetoothDevice.getName()!= null &&  bluetoothDevice.getName().contains("Bracel")){
                        deviceAdapter.addDevice(bluetoothDevice);
                    }
                    break;
            }
        }
    };


}
