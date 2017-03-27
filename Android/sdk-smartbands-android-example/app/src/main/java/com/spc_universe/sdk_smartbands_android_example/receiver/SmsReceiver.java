package com.spc_universe.sdk_smartbands_android_example.receiver;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.telephony.SmsMessage;
import android.text.TextUtils;
import android.util.Log;

import com.spc_universe.sdk_smartbands_android.controller.WristBandDevice;

/**
 * broadcast receiver for sms
 * some phone has compatibility issues with system sms broadcast receiver
 *
 * @author
 * @created
 */
public class SmsReceiver extends BroadcastReceiver {
    public static final boolean D = true;
    // Tag
    private String TAG = this.getClass().getSimpleName();

    private static final String SMS_RECEIVED = "android.provider.Telephony.SMS_RECEIVED";
    private static final String SMS_RECEIVED_NEW = "android.provider.Telephony.SMS_DELIVER";


    @Override
    public void onReceive(Context context, Intent intent) {
        if (D){
            Log.e(TAG, "+++ ON RECEIVE +++");
        }
        if (intent.getAction().equals(SMS_RECEIVED) || intent.getAction().equals(SMS_RECEIVED_NEW)) {
            Sms sms = getSms(context, intent);
            if (sms == null) {
                return;
            }

            String number = sms.getContact().getDisplayName();
            if (number.length() != 0 && number.startsWith("+86")) {
                number = number.substring(3, number.length());
            }
            boolean alleng = true;
            for (int j = 0; j < number.length(); j++) {
                if (number.charAt(j) < 0x80) {
                    continue;
                } else {
                    alleng = false;
                }
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2){
                if (WristBandDevice.getInstance(context).isConnected()) {
                    WristBandDevice.getInstance(context).sendNotification(1, number);
                }
            }
        }
    }


    public static Sms getSms(Context context, Intent intent) {
        StringBuilder number = new StringBuilder("");
        StringBuilder body = new StringBuilder("");

        Bundle bundle = intent.getExtras();
        if (bundle == null)
            return null;
        Object[] _pdus = (Object[]) bundle.get("pdus");
        SmsMessage[] message = new SmsMessage[_pdus.length];

        for (int i = 0; i < _pdus.length; i++) {
            message[i] = SmsMessage.createFromPdu((byte[]) _pdus[i]);
        }

        for (SmsMessage currentMessage : message) {
            if (!number.toString().equals(currentMessage.getDisplayOriginatingAddress())) {
                number.append(currentMessage.getDisplayOriginatingAddress());
            }
            body.append(currentMessage.getDisplayMessageBody());
        }

        return new Sms(number.toString(), body.toString(), SmsReceiver.getContact(context, number.toString()));
    }

    public static class Sms {
        public Sms() {
        }

        public Sms(String number, String body, Contact contact) {
            this.number = number;
            this.body = body;
            this.contact = contact;
        }

        private String number;
        private String body;
        private Contact contact;

        public String getNumber() {
            return number;
        }

        public void setNumber(String number) {
            this.number = number;
        }

        public String getBody() {
            return body;
        }

        public void setBody(String body) {
            this.body = body;
        }

        public Contact getContact() {
            return contact;
        }

        public void setContact(Contact contact) {
            this.contact = contact;
        }

    }

    public static Contact getContact(Context context, String phoneNumber) {
        Contact contact = new Contact(phoneNumber);
        if (TextUtils.isEmpty(phoneNumber)) {
            contact.setDisplayName("Unknown Number");
        }
        Cursor cursor = null;
        try {
            Uri uri = Uri.withAppendedPath(ContactsContract.PhoneLookup.CONTENT_FILTER_URI, Uri.encode(phoneNumber));
            cursor = context.getContentResolver().query(uri,
                    new String[]{ContactsContract.PhoneLookup.DISPLAY_NAME, ContactsContract.PhoneLookup.TYPE, ContactsContract.PhoneLookup.LABEL}, null,
                    null, ContactsContract.PhoneLookup.DISPLAY_NAME + " LIMIT 1");
            while (cursor.moveToNext()) {
                contact.setDisplayName(cursor.getString(cursor.getColumnIndex(ContactsContract.PhoneLookup.DISPLAY_NAME)));
                break;
            }
        } catch (Exception e) {
            contact.setDisplayName(phoneNumber);
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        return contact;
    }

    public static class Contact {
        private String number;
        private String displayName;

        public Contact(String phoneNumber) {
            this.number = phoneNumber;
            this.displayName = phoneNumber;
        }

        public String getNumber() {
            return number;
        }

        public void setNumber(String number) {
            this.number = number;
        }

        public String getDisplayName() {
            return displayName;
        }

        public void setDisplayName(String displayName) {
            this.displayName = displayName;
        }
    }
}