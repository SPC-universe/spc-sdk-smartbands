package com.spc_universe.sdk_smartbands_android_example;

import android.Manifest;
import android.app.FragmentManager;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.Switch;
import android.widget.TextView;

import com.spc_universe.sdk_smartbands_android.controller.CallbackHandler;
import com.spc_universe.sdk_smartbands_android.controller.WristBandDevice;
import com.spc_universe.sdk_smartbands_android.model.AlarmClock;
import com.spc_universe.sdk_smartbands_android.model.CurrentData;
import com.spc_universe.sdk_smartbands_android.model.DeviceInfo;
import com.spc_universe.sdk_smartbands_android.model.DeviceOptions;
import com.spc_universe.sdk_smartbands_android.model.HeartRateDetail;
import com.spc_universe.sdk_smartbands_android.model.KeyModel;
import com.spc_universe.sdk_smartbands_android.model.PowerInfo;
import com.spc_universe.sdk_smartbands_android.model.SedentaryReminder;
import com.spc_universe.sdk_smartbands_android.model.SleepData;
import com.spc_universe.sdk_smartbands_android.model.SportData;
import com.spc_universe.sdk_smartbands_android.model.SportGoals;
import com.spc_universe.sdk_smartbands_android.model.SupportedSports;
import com.spc_universe.sdk_smartbands_android.model.UserInfo;

import java.util.ArrayList;
import java.util.LinkedHashMap;

public class MainActivity extends AppCompatActivity implements View.OnClickListener, ScannerFragment.OnDeviceSelectedListener {

    public static final String ACTION_DEVICE_FOUND = "action.device.found";

    private LinearLayout scanLL;

    private LinearLayout connectionLL;
    private TextView deviceNameTV;
    private Button connectB;
    private Button disconnectB;

    private LinearLayout buttonsLL;

    private LinearLayout setCameraControlLL;
    private Switch cameraControlS;

    private LinearLayout sendNotificationLL;
    private EditText sendNotificationET;

    private LinearLayout setUserInfoLL;
    private EditText setUserInfoHeightET;
    private EditText setUserInfoWeightET;
    private Switch setUserInfoGenderS;
    private EditText setUserInfoAgeET;
    private EditText setUserInfoGoalET;

    private LinearLayout setDeviceOptionsLL;
    private Switch setDeviceOptionsLightS;
    private Switch setDeviceOptionsGestureS;
    private Switch setDeviceOptionsUnitTypeS;
    private Switch setDeviceOptionsTimeS;
    private Switch setDeviceOptionsAutoSleepS;
    private Switch setDeviceOptionsAdvS;
    private EditText setDeviceOptionsBackLightStartTimeET;
    private EditText setDeviceOptionsBackLightEndTimeET;
    private Switch setDeviceOptionsColorS;
    private Switch setDeviceOptionsLanguageS;
    private Switch setDeviceOptionsDisconnectS;

    private LinearLayout setSedentaryReminderLL;
    private EditText setSedentaryReminderIndexET;
    private EditText setSedentaryReminderStartHourET;
    private EditText setSedentaryReminderEndHourET;
    private EditText setSedentaryReminderWeekET;
    private EditText setSedentaryReminderMinutesET;
    private EditText setSedentaryReminderGoalET;

    private LinearLayout getAlarmLL;
    private EditText getAlarmIdET;

    private LinearLayout setAlarmLL;
    private EditText setAlarmIdET;
    private Switch setAlarmSmartS;
    private EditText setAlarmWeekET;
    private EditText setAlarmHourET;
    private EditText setAlarmMinuteET;

    private LinearLayout setSportLL;
    private EditText setSportDayET;
    private EditText setSport1TargetET;
    private EditText setSport2SportET;
    private EditText setSport2TargetET;
    private EditText setSport3SportET;
    private EditText setSport3TargetET;
    private EditText setSport4SportET;
    private EditText setSport4TargetET;
    private EditText setSport5SportET;
    private EditText setSport5TargetET;

    private LinearLayout removeScheduleLL;
    private EditText removeScheduleYearET;
    private EditText removeScheduleMonthET;
    private EditText removeScheduleDayET;
    private EditText removeScheduleHourET;
    private EditText removeScheduleMinuteET;

    private LinearLayout setScheduleLL;
    private EditText setScheduleYearET;
    private EditText setScheduleMonthET;
    private EditText setScheduleDayET;
    private EditText setScheduleHourET;
    private EditText setScheduleMinuteET;
    private EditText setScheduleTitleET;

    private ArrayList<LinearLayout> formsLayouts;

    private DataAdapter dataAdapter;

    private BluetoothDevice bluetoothDevice;

    private WristBandDevice wristBandDevice;

    private boolean connected = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        this.wristBandDevice = WristBandDevice.getInstance(getApplicationContext());

        this.wristBandDevice.setCallbackHandler(new CallbackHandler() {
            @Override
            public void onWristBandFindNewAgreement(BluetoothDevice device) {
                Intent intent = new Intent(MainActivity.ACTION_DEVICE_FOUND);
                intent.putExtra("device", device);
                sendBroadcast(intent);
            }

            @Override
            public void connectStatue(boolean isConnect) {
                connected = isConnect;
                if (connected) {
                    showData("Connected");
                } else {
                    showData("Disconnected");
                }
                updateUI();
            }

            @Override
            public void onDeviceInfoReceived(DeviceInfo deviceInfo) {
                showData(deviceInfo.toString());
            }

            @Override
            public void onPowerInfoReceived(PowerInfo powerInfo) {
                showData(powerInfo.toString());
            }

            @Override
            public void onSedentaryRemindersReceived(ArrayList<SedentaryReminder> sedentaryReminders) {
                for (SedentaryReminder sedentaryReminder : sedentaryReminders) {
                    showData(sedentaryReminder.toString());
                }
            }

            @Override
            public void onDeviceOptionsReceived(DeviceOptions deviceOptions) {
                showData(deviceOptions.toString());
            }

            @Override
            public void onKeyModelReceived(KeyModel keyModel) {
                showData(keyModel.toString());
            }

            @Override
            public void onHeartRateDetailReceived(HeartRateDetail heartRateDetail) {
                showData(heartRateDetail.toString());
            }

            @Override
            public void onSleepDataReceived(SleepData sleepData) {
                showData(sleepData.toString());
            }

            @Override
            public void onSportDataReceived(SportData sportData) {
                showData(sportData.toString());
            }

            @Override
            public void onCurrentDataReceived(CurrentData currentData) {
                showData(currentData.toString());
            }

            @Override
            public void onSupportedSportsReceived(SupportedSports supportedSports) {
                showData(supportedSports.toString());
            }

            @Override
            public void onSportGoalsReceived(SportGoals sportGoals) {
                showData(sportGoals.toString());
            }

            @Override
            public void onUserInfoReceived(UserInfo userInfo) {
                showData(userInfo.toString());
            }

            @Override
            public void onAlarmClockReceived(AlarmClock alarmClock) {
                showData(alarmClock.toString());
            }
        });

        checkAllPermisions();
    }

    private void showData(final String text) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                dataAdapter.addText(text);
            }
        });
    }

    public static final String[] PERMISIONS = new String[]{Manifest.permission.ACCESS_COARSE_LOCATION};

    public static final int REQUEST_CODE_PERMISION = 11000;

    public void checkAllPermisions() {
        if (!PermisionUtil.allPermissionGranted(this, PERMISIONS)) {
            if (PermisionUtil.shouldShowRequestPermissionRationale(this, PERMISIONS)) {
                ActivityCompat.requestPermissions(MainActivity.this, PERMISIONS, REQUEST_CODE_PERMISION);
            } else {
                ActivityCompat.requestPermissions(this, PERMISIONS, REQUEST_CODE_PERMISION);
            }
        } else {
            initView();
        }
    }

    private void initView() {
        dataAdapter = new DataAdapter(this);

        ListView list = (ListView) findViewById(R.id.list_data);
        list.setAdapter(dataAdapter);


        // SCAN
        scanLL = (LinearLayout) findViewById(R.id.scanLL);
        scanLL.setVisibility(View.VISIBLE);

        Button showScanDialogB = (Button) findViewById(R.id.showScanDialogB);
        showScanDialogB.setOnClickListener(this);


        // CONNECTION
        connectionLL = (LinearLayout) findViewById(R.id.connectionLL);

        deviceNameTV = (TextView) findViewById(R.id.deviceNameTV);

        connectB = (Button) findViewById(R.id.connectB);
        connectB.setOnClickListener(this);

        disconnectB = (Button) findViewById(R.id.disconnectB);
        disconnectB.setOnClickListener(this);


        // BUTTONS
        buttonsLL = (LinearLayout) findViewById(R.id.buttonsLL);

        Button restartB = (Button) findViewById(R.id.restartB);
        restartB.setOnClickListener(this);

        Button setDateB = (Button) findViewById(R.id.setDateB);
        setDateB.setOnClickListener(this);

        Button getDeviceInfoB = (Button) findViewById(R.id.getDeviceInfoB);
        getDeviceInfoB.setOnClickListener(this);

        Button getPowerInfoB = (Button) findViewById(R.id.getPowerInfoB);
        getPowerInfoB.setOnClickListener(this);

        Button getDeviceOptionsB = (Button) findViewById(R.id.getDeviceOptionsB);
        getDeviceOptionsB.setOnClickListener(this);

        Button getSedentaryReminderB = (Button) findViewById(R.id.getSedentaryReminderB);
        getSedentaryReminderB.setOnClickListener(this);

        Button getHeartRateDataB = (Button) findViewById(R.id.syncHeartRateData);
        getHeartRateDataB.setOnClickListener(this);

        Button syncActivityDataB = (Button) findViewById(R.id.syncActivityDataB);
        syncActivityDataB.setOnClickListener(this);

        Button syncCurrentDataB = (Button) findViewById(R.id.syncCurrentDataB);
        syncCurrentDataB.setOnClickListener(this);

        Button getSupportedSportsB = (Button) findViewById(R.id.getSupportedSportsB);
        getSupportedSportsB.setOnClickListener(this);

        Button getUserInfoB = (Button) findViewById(R.id.getUserInfoB);
        getUserInfoB.setOnClickListener(this);

        Button showSetCameraControlB = (Button) findViewById(R.id.showSetCameraControlB);
        showSetCameraControlB.setOnClickListener(this);

        setCameraControlLL = (LinearLayout) findViewById(R.id.setCameraControlLL);

        cameraControlS = (Switch) findViewById(R.id.cameraControlS);

        Button setCameraControlB = (Button) findViewById(R.id.setCameraControlB);
        setCameraControlB.setOnClickListener(this);

        Button showSendNotificationB = (Button) findViewById(R.id.showSendNotificationB);
        showSendNotificationB.setOnClickListener(this);

        sendNotificationLL = (LinearLayout) findViewById(R.id.sendNotificationLL);

        sendNotificationET = (EditText) findViewById(R.id.sendNotificationET);

        Button sendNotificationB = (Button) findViewById(R.id.sendNotificationB);
        sendNotificationB.setOnClickListener(this);

        Button showSetUserInfoB = (Button) findViewById(R.id.showSetUserInfoB);
        showSetUserInfoB.setOnClickListener(this);

        setUserInfoLL = (LinearLayout) findViewById(R.id.setUserInfoLL);

        setUserInfoHeightET = (EditText) findViewById(R.id.setUserInfoHeightET);
        setUserInfoWeightET = (EditText) findViewById(R.id.setUserInfoWeightET);
        setUserInfoGenderS = (Switch) findViewById(R.id.setUserInfoGenderS);
        setUserInfoAgeET = (EditText) findViewById(R.id.setUserInfoAgeET);
        setUserInfoGoalET = (EditText) findViewById(R.id.setUserInfoGoalET);

        Button setUserInfoB = (Button) findViewById(R.id.setUserInfoB);
        setUserInfoB.setOnClickListener(this);

        Button showSetDeviceOptionsB = (Button) findViewById(R.id.showSetDeviceOptionsB);
        showSetDeviceOptionsB.setOnClickListener(this);

        setDeviceOptionsLL = (LinearLayout) findViewById(R.id.setDeviceOptionsLL);

        setDeviceOptionsLightS = (Switch) findViewById(R.id.setDeviceOptionsLightS);
        setDeviceOptionsGestureS = (Switch) findViewById(R.id.setDeviceOptionsGestureS);
        setDeviceOptionsUnitTypeS = (Switch) findViewById(R.id.setDeviceOptionsUnitTypeS);
        setDeviceOptionsTimeS = (Switch) findViewById(R.id.setDeviceOptionsHour12S);
        setDeviceOptionsAutoSleepS = (Switch) findViewById(R.id.setDeviceOptionsSleepS);
        setDeviceOptionsAdvS = (Switch) findViewById(R.id.setDeviceOptionsAdvS);
        setDeviceOptionsBackLightStartTimeET = (EditText) findViewById(R.id.setDeviceOptionsBackLightStartTimeET);
        setDeviceOptionsBackLightEndTimeET = (EditText) findViewById(R.id.setDeviceOptionsBackLightEndTimeET);
        setDeviceOptionsColorS = (Switch) findViewById(R.id.setDeviceOptionsInverseColorS);
        setDeviceOptionsLanguageS = (Switch) findViewById(R.id.setDeviceOptionsLanguageS);
        setDeviceOptionsDisconnectS = (Switch) findViewById(R.id.setDeviceOptionsDisconnectS);

        Button setDeviceOptionsB = (Button) findViewById(R.id.setDeviceOptionsB);
        setDeviceOptionsB.setOnClickListener(this);

        Button showSetSedentaryReminderB = (Button) findViewById(R.id.showSetSedentaryReminderB);
        showSetSedentaryReminderB.setOnClickListener(this);

        setSedentaryReminderLL = (LinearLayout) findViewById(R.id.setSedentaryReminderLL);
        setSedentaryReminderIndexET = (EditText) findViewById(R.id.setSedentaryReminderIndexET);
        setSedentaryReminderStartHourET = (EditText) findViewById(R.id.setSedentaryReminderStartHourET);
        setSedentaryReminderEndHourET = (EditText) findViewById(R.id.setSedentaryReminderEndHourET);
        setSedentaryReminderWeekET = (EditText) findViewById(R.id.setSedentaryReminderWeekET);
        setSedentaryReminderMinutesET = (EditText) findViewById(R.id.setSedentaryReminderMinutesET);
        setSedentaryReminderGoalET = (EditText) findViewById(R.id.setSedentaryReminderGoalET);

        Button setSedentaryReminderB = (Button) findViewById(R.id.setSedentaryReminderB);
        setSedentaryReminderB.setOnClickListener(this);

        Button showGetAlarmB = (Button) findViewById(R.id.showGetAlarmB);
        showGetAlarmB.setOnClickListener(this);

        getAlarmLL = (LinearLayout) findViewById(R.id.getAlarmLL);
        getAlarmIdET = (EditText) findViewById(R.id.getAlarmIdET);

        Button getAlarmB = (Button) findViewById(R.id.getAlarmB);
        getAlarmB.setOnClickListener(this);

        Button showSetAlarmB = (Button) findViewById(R.id.showSetAlarmB);
        showSetAlarmB.setOnClickListener(this);

        setAlarmLL = (LinearLayout) findViewById(R.id.setAlarmLL);
        setAlarmIdET = (EditText) findViewById(R.id.setAlarmIdET);
        setAlarmSmartS = (Switch) findViewById(R.id.setAlarmSmartS);
        setAlarmWeekET = (EditText) findViewById(R.id.setAlarmWeekET);
        setAlarmHourET = (EditText) findViewById(R.id.setAlarmHourET);
        setAlarmMinuteET = (EditText) findViewById(R.id.setAlarmMinuteET);

        Button setAlarmB = (Button) findViewById(R.id.setAlarmB);
        setAlarmB.setOnClickListener(this);

        Button showSetSportB = (Button) findViewById(R.id.showSetSportB);
        showSetSportB.setOnClickListener(this);

        setSportLL = (LinearLayout) findViewById(R.id.setSportLL);
        setSportDayET = (EditText) findViewById(R.id.setSportDayET);
        setSport1TargetET = (EditText) findViewById(R.id.setSport1TargetET);
        setSport2SportET = (EditText) findViewById(R.id.setSport2SportET);
        setSport2TargetET = (EditText) findViewById(R.id.setSport2TargetET);
        setSport3SportET = (EditText) findViewById(R.id.setSport3SportET);
        setSport3TargetET = (EditText) findViewById(R.id.setSport3TargetET);
        setSport4SportET = (EditText) findViewById(R.id.setSport4SportET);
        setSport4TargetET = (EditText) findViewById(R.id.setSport4TargetET);
        setSport5SportET = (EditText) findViewById(R.id.setSport5SportET);
        setSport5TargetET = (EditText) findViewById(R.id.setSport5TargetET);

        Button setSportB = (Button) findViewById(R.id.setSportB);
        setSportB.setOnClickListener(this);

        Button showRemoveScheduleB = (Button) findViewById(R.id.showRemoveScheduleB);
        showRemoveScheduleB.setOnClickListener(this);

        Button removeAllScheduleB = (Button) findViewById(R.id.removeAllScheduleB);
        removeAllScheduleB.setOnClickListener(this);

        removeScheduleLL = (LinearLayout) findViewById(R.id.removeScheduleLL);
        removeScheduleYearET = (EditText) findViewById(R.id.removeScheduleYearET);
        removeScheduleMonthET = (EditText) findViewById(R.id.removeScheduleMonthET);
        removeScheduleDayET = (EditText) findViewById(R.id.removeScheduleDayET);
        removeScheduleHourET = (EditText) findViewById(R.id.removeScheduleHourET);
        removeScheduleMinuteET = (EditText) findViewById(R.id.removeScheduleMinuteET);

        Button removeScheduleB = (Button) findViewById(R.id.removeScheduleB);
        removeScheduleB.setOnClickListener(this);

        Button showSetScheduleB = (Button) findViewById(R.id.showSetScheduleB);
        showSetScheduleB.setOnClickListener(this);

        setScheduleLL = (LinearLayout) findViewById(R.id.setScheduleLL);
        setScheduleYearET = (EditText) findViewById(R.id.setScheduleYearET);
        setScheduleMonthET = (EditText) findViewById(R.id.setScheduleMonthET);
        setScheduleDayET = (EditText) findViewById(R.id.setScheduleDayET);
        setScheduleHourET = (EditText) findViewById(R.id.setScheduleHourET);
        setScheduleMinuteET = (EditText) findViewById(R.id.setScheduleMinuteET);
        setScheduleTitleET = (EditText) findViewById(R.id.setScheduleTitleET);

        Button setScheduleB = (Button) findViewById(R.id.setScheduleB);
        setScheduleB.setOnClickListener(this);

        formsLayouts = new ArrayList<>();
        formsLayouts.add(setCameraControlLL);
        formsLayouts.add(sendNotificationLL);
        formsLayouts.add(setUserInfoLL);
        formsLayouts.add(setDeviceOptionsLL);
        formsLayouts.add(setSedentaryReminderLL);
        formsLayouts.add(getAlarmLL);
        formsLayouts.add(setAlarmLL);
        formsLayouts.add(setSportLL);
        formsLayouts.add(removeScheduleLL);
        formsLayouts.add(setScheduleLL);

    }

    private void updateUI() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!connected) {
                    scanLL.setVisibility(View.VISIBLE);
                    if (bluetoothDevice != null) {
                        deviceNameTV.setText("Device: " + bluetoothDevice.getName());
                        connectionLL.setVisibility(View.VISIBLE);
                    } else {
                        deviceNameTV.setText("");
                        connectionLL.setVisibility(View.GONE);
                    }
                    buttonsLL.setVisibility(View.GONE);
                    connectB.setVisibility(View.VISIBLE);
                    disconnectB.setVisibility(View.GONE);
                } else {
                    scanLL.setVisibility(View.GONE);
                    connectionLL.setVisibility(View.VISIBLE);
                    connectB.setVisibility(View.GONE);
                    disconnectB.setVisibility(View.VISIBLE);
                    buttonsLL.setVisibility(View.VISIBLE);
                }
            }
        });
    }

    @Override
    public void onClick(View v) {

        switch (v.getId()) {
            case R.id.showScanDialogB:
                if (checkBluetooth()) {
                    showDeviceScanningDialog();
                } else {
                    showData("Enable Bluetooth");
                }
                break;
            case R.id.connectB:
                if (!connected) {
                    showData("Connecting");
                    this.wristBandDevice.setBluetoothDevice(bluetoothDevice);
                    this.wristBandDevice.connect();
                } else {
                    showData("It's already connected");
                }
                break;
            case R.id.disconnectB:
                if (connected) {
                    showData("Disconnecting");
                    this.wristBandDevice.setBluetoothDevice(null);
                    this.wristBandDevice.disconnect();
                } else {
                    showData("It's already disconnected");
                }
                break;
            case R.id.restartB:
                showData(getString(R.string.restart));
                this.wristBandDevice.restart();
                showForm(null);
                break;
            case R.id.setDateB:
                showData(getString(R.string.setDate));
                this.wristBandDevice.setDate();
                showForm(null);
                break;
            case R.id.getDeviceInfoB:
                showData(getString(R.string.getDeviceInfo));
                this.wristBandDevice.getDeviceInfo();
                showForm(null);
                break;
            case R.id.getPowerInfoB:
                showData(getString(R.string.getPowerInfo));
                this.wristBandDevice.getPower();
                showForm(null);
                break;
            case R.id.getSedentaryReminderB:
                showData(getString(R.string.getSedentaryReminder));
                this.wristBandDevice.getSedentaryReminder();
                showForm(null);
                break;
            case R.id.showSetSedentaryReminderB:
                showForm(setSedentaryReminderLL);
                break;
            case R.id.setSedentaryReminderB:
                showData(getString(R.string.setSedentaryReminder));
                try {
                    Integer index = Integer.parseInt(setSedentaryReminderIndexET.getText().toString());
                    Integer startHour = Integer.parseInt(setSedentaryReminderStartHourET.getText().toString());
                    Integer endHour = Integer.parseInt(setSedentaryReminderEndHourET.getText().toString());
                    Integer week = Integer.parseInt(setSedentaryReminderWeekET.getText().toString());
                    Integer minutes = Integer.parseInt(setSedentaryReminderMinutesET.getText().toString());
                    Integer goal = Integer.parseInt(setSedentaryReminderGoalET.getText().toString());

                    wristBandDevice.setSedentaryReminder(index, startHour, endHour, week, minutes, goal);
                } catch (Exception e) {
                    showData("Exception: " + e.getMessage());
                    e.printStackTrace();
                }
                showForm(setSedentaryReminderLL);
                break;
            case R.id.getDeviceOptionsB:
                showData(getString(R.string.getDeviceOptions));
                this.wristBandDevice.getOptions();
                showForm(null);
                break;
            case R.id.syncHeartRateData:
                showData(getString(R.string.syncHeartRateData));
                this.wristBandDevice.syncHeartRateData(true);
                showForm(null);
                break;
            case R.id.syncActivityDataB:
                showData(getString(R.string.syncActivityData));
                this.wristBandDevice.syncActivityData(true);
                showForm(null);
                break;
            case R.id.syncCurrentDataB:
                showData(getString(R.string.syncCurrentData));
                this.wristBandDevice.syncCurrentData(true);
                showForm(null);
                break;
            case R.id.getSupportedSportsB:
                showData(getString(R.string.getSupportedSports));
                this.wristBandDevice.getSupportedSports();
                showForm(null);
                break;
            case R.id.getUserInfoB:
                showData(getString(R.string.getUserInfo));
                this.wristBandDevice.getUserInfo();
                showForm(null);
                break;
            case R.id.showSetCameraControlB:
                showForm(setCameraControlLL);
                break;
            case R.id.setCameraControlB:
                showData(getString(R.string.setCameraControl));
                this.wristBandDevice.setCameraControl(cameraControlS.isChecked());
                showForm(setCameraControlLL);
                break;
            case R.id.showSendNotificationB:
                showForm(sendNotificationLL);
                break;
            case R.id.sendNotificationB:
                try {
                    showData(getString(R.string.sendNotification));
                    this.wristBandDevice.sendNotification(2, sendNotificationET.getText().toString());
                } catch (Exception e) {
                    showData("Exception: " + e.getMessage());
                    e.printStackTrace();
                }
                showForm(sendNotificationLL);
                break;
            case R.id.showSetUserInfoB:
                showForm(setUserInfoLL);
                break;
            case R.id.setUserInfoB:
                showData(getString(R.string.setUserInfo));
                try {
                    Integer height = Integer.parseInt(setUserInfoHeightET.getText().toString());
                    Integer weight = Integer.parseInt(setUserInfoWeightET.getText().toString());
                    Boolean gender = setUserInfoGenderS.isChecked();
                    Integer age = Integer.parseInt(setUserInfoAgeET.getText().toString());
                    Integer steps = Integer.parseInt(setUserInfoGoalET.getText().toString());
                    this.wristBandDevice.setUserInfo(height, weight, gender, age, steps);
                } catch (Exception e) {
                    showData("Exception: " + e.getMessage());
                    e.printStackTrace();
                }
                showForm(setUserInfoLL);
                break;
            case R.id.showSetDeviceOptionsB:
                showForm(setDeviceOptionsLL);
                break;
            case R.id.setDeviceOptionsB:
                showData(getString(R.string.setDeviceOptions));
                try {
                    Boolean light = setDeviceOptionsLightS.isChecked();
                    Boolean gesture = setDeviceOptionsGestureS.isChecked();
                    Boolean unitType = setDeviceOptionsUnitTypeS.isChecked();
                    Boolean time = setDeviceOptionsTimeS.isChecked();
                    Boolean autoSleep = setDeviceOptionsAutoSleepS.isChecked();
                    Boolean adv = setDeviceOptionsAdvS.isChecked();
                    Integer backlightStartTime = Integer.parseInt(setDeviceOptionsBackLightStartTimeET.getText().toString());
                    Integer backlightEndTime = Integer.parseInt(setDeviceOptionsBackLightEndTimeET.getText().toString());
                    Boolean color = setDeviceOptionsColorS.isChecked();
                    Boolean language = setDeviceOptionsLanguageS.isChecked();
                    Boolean disconnect = setDeviceOptionsDisconnectS.isChecked();
                    this.wristBandDevice.setOptions(
                            light,
                            gesture,
                            unitType,
                            time,
                            autoSleep,
                            adv,
                            backlightStartTime,
                            backlightEndTime,
                            color,
                            language,
                            disconnect
                    );
                } catch (Exception e) {
                    showData("Exception: " + e.getMessage());
                    e.printStackTrace();
                }
                showForm(setDeviceOptionsLL);
                break;
            case R.id.showGetAlarmB:
                showForm(getAlarmLL);
                break;
            case R.id.getAlarmB:
                showData(getString(R.string.getAlarm));
                try {
                    Integer id = Integer.parseInt(getAlarmIdET.getText().toString());
                    this.wristBandDevice.getAlarm(id);
                } catch (Exception e) {
                    showData("Exception: " + e.getMessage());
                    e.printStackTrace();
                }
                showForm(getAlarmLL);
                break;
            case R.id.showSetAlarmB:
                showForm(setAlarmLL);
                break;
            case R.id.setAlarmB:
                showData(getString(R.string.setAlarm));
                try {
                    Integer id = Integer.parseInt(setAlarmIdET.getText().toString());
                    Boolean smart = setAlarmSmartS.isChecked();
                    Integer week = Integer.parseInt(setAlarmWeekET.getText().toString());
                    Integer hour = Integer.parseInt(setAlarmHourET.getText().toString());
                    Integer minute = Integer.parseInt(setAlarmMinuteET.getText().toString());
                    this.wristBandDevice.setAlarm(id, smart, week, hour, minute);
                } catch (Exception e) {
                    showData("Exception: " + e.getMessage());
                    e.printStackTrace();
                }
                showForm(setAlarmLL);
                break;
            case R.id.showSetSportB:
                showForm(setSportLL);
                break;
            case R.id.setSportB:
                showData(getString(R.string.setSport));
                try {
                    Integer day = Integer.parseInt(setSportDayET.getText().toString());

                    LinkedHashMap<Integer, Integer> goals = new LinkedHashMap<>();

                    Integer sport1 = 1;
                    Integer target1 = 10000;
                    if (!setSport1TargetET.getText().toString().equals("")) {
                        target1 = Integer.parseInt(setSport1TargetET.getText().toString());
                    }
                    goals.put(sport1, target1);

                    if (!setSport2SportET.getText().toString().equals("") && !setSport2TargetET.getText().toString().equals("")) {
                        Integer sport2 = Integer.parseInt(setSport2SportET.getText().toString());
                        Integer target2 = Integer.parseInt(setSport2TargetET.getText().toString());
                        goals.put(sport2, target2);
                    }

                    if (!setSport3SportET.getText().toString().equals("") && !setSport3TargetET.getText().toString().equals("")) {
                        Integer sport3 = Integer.parseInt(setSport3SportET.getText().toString());
                        Integer target3 = Integer.parseInt(setSport3TargetET.getText().toString());
                        goals.put(sport3, target3);
                    }

                    if (!setSport4SportET.getText().toString().equals("") && !setSport4TargetET.getText().toString().equals("")) {
                        Integer sport4 = Integer.parseInt(setSport4SportET.getText().toString());
                        Integer target4 = Integer.parseInt(setSport4TargetET.getText().toString());
                        goals.put(sport4, target4);
                    }

                    if (!setSport5SportET.getText().toString().equals("") && !setSport5TargetET.getText().toString().equals("")) {
                        Integer sport5 = Integer.parseInt(setSport5SportET.getText().toString());
                        Integer target5 = Integer.parseInt(setSport5TargetET.getText().toString());
                        goals.put(sport5, target5);
                    }

                    this.wristBandDevice.setSports(day, goals);
                } catch (Exception e) {
                    showData("Exception: " + e.getMessage());
                    e.printStackTrace();
                }
                showForm(setSportLL);
                break;
            case R.id.showRemoveScheduleB:
                showForm(removeScheduleLL);
                break;
            case R.id.removeAllScheduleB:
                showData(getString(R.string.removeAllSchedule));
                this.wristBandDevice.clearAllSchedules();
                showForm(removeScheduleLL);
                break;
            case R.id.removeScheduleB:
                showData(getString(R.string.removeSchedule));
                try {
                    Integer year = Integer.parseInt(removeScheduleYearET.getText().toString());
                    Integer month = Integer.parseInt(removeScheduleMonthET.getText().toString());
                    Integer day = Integer.parseInt(removeScheduleDayET.getText().toString());
                    Integer hour = Integer.parseInt(removeScheduleHourET.getText().toString());
                    Integer minute = Integer.parseInt(removeScheduleMinuteET.getText().toString());
                    this.wristBandDevice.closeSchedule(year, month, day, hour, minute);
                } catch (Exception e) {
                    showData("Exception: " + e.getMessage());
                    e.printStackTrace();
                }
                showForm(removeScheduleLL);
                break;
            case R.id.showSetScheduleB:
                showForm(setScheduleLL);
                break;
            case R.id.setScheduleB:
                showData(getString(R.string.setSchedule));
                try {
                    Integer year = Integer.parseInt(setScheduleYearET.getText().toString());
                    Integer month = Integer.parseInt(setScheduleMonthET.getText().toString());
                    Integer day = Integer.parseInt(setScheduleDayET.getText().toString());
                    Integer hour = Integer.parseInt(setScheduleHourET.getText().toString());
                    Integer minute = Integer.parseInt(setScheduleMinuteET.getText().toString());
                    String title = setScheduleTitleET.getText().toString();

                    if(title.length() > 7){
                        title = title.substring(0, 6);
                    }

                    this.wristBandDevice.setSchedule(year, month, day, hour, minute, title);
                } catch (Exception e) {
                    showData("Exception: " + e.getMessage());
                    e.printStackTrace();
                }
                showForm(setScheduleLL);
                break;
            default:
                showData("No action defined to this button");
                showForm(null);
                break;
        }
        dataAdapter.notifyDataSetChanged();
    }

    private void showForm(LinearLayout linearLayout) {
        for (LinearLayout formLinearLayout : formsLayouts) {
            if (formLinearLayout != linearLayout) {
                formLinearLayout.setVisibility(View.GONE);
            } else {
                formLinearLayout.setVisibility(View.VISIBLE);
            }
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        updateUI();
    }

    private boolean checkBluetooth() {
        BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (mBluetoothAdapter == null) {
            return false;
        } else {
            if (!mBluetoothAdapter.isEnabled()) {
                return false;
            }
        }
        return true;
    }

    @Override
    public void onDeviceSelected(BluetoothDevice device, String name) {
        bluetoothDevice = device;
        showData("Selected device: " + device.getName() + " " + device.getAddress());
        updateUI();
    }

    @Override
    public void onDialogCanceled() {

    }

    /**
     * scan window
     */
    private void showDeviceScanningDialog() {
        final FragmentManager fm = getFragmentManager();
        final ScannerFragment dialog = ScannerFragment.getInstance();
        dialog.show(fm, "scan_fragment");
    }
}
