package com.spc_universe.sdk_smartbands_android_example;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;

import java.util.HashMap;

public class PermisionUtil {

    /**
     * @param context    Context
     * @param permisions String[]
     * @return true: All permissions granted, false: Some permission denied
     */
    public static boolean allPermissionGranted(Context context, String[] permisions) {

        final HashMap<String, Integer> permisionStatus = new HashMap<>();

        for (String permission : permisions) {
            permisionStatus.put(permission, ContextCompat.checkSelfPermission(context, permission));
        }

        return !permisionStatus.containsValue(PackageManager.PERMISSION_DENIED);
    }

    /**
     * @param activity   activity to show dialog
     * @param permisions permisions to require
     * @return true: All permission granted, false: Some permission denied
     */
    public static boolean shouldShowRequestPermissionRationale(Activity activity, String[] permisions) {

        for (String permission : permisions) {
            if (ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)) {
                return true;
            }
        }
        return false;
    }
}
