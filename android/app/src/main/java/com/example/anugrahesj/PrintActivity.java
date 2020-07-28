package com.example.anugrahesj;

import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.CompoundButton;

import androidx.appcompat.app.AppCompatActivity;

import com.sunmi.printerhelper.utils.BluetoothUtil;
import com.sunmi.printerhelper.utils.ESCUtil;
import com.sunmi.printerhelper.utils.SunmiPrintHelper;

import java.io.IOException;

public class PrintActivity extends AppCompatActivity {
    boolean isBold = true;
    boolean isUnderLine = false;
    Bitmap bMap;
    int record = 17;
    private String[] mStrings = new String[]{"CP437", "CP850", "CP860", "CP863", "CP865", "CP857", "CP737", "Windows-1252", "CP866", "CP852", "CP858", "CP874","CP855", "CP862", "CP864", "GB18030", "BIG5", "KSC5601", "utf-8"};
    String text;
    String company;
    String header;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Bundle extras = getIntent().getExtras();
        if (extras != null) {
            text = extras.getString("EXTRA_DATA");
            company = extras.getString("EXTRA_COMPANY");
            header = extras.getString("EXTRA_HEADER");
            //The key argument here must match that used in the other activity
        }
        Resources res = getResources();
        bMap = BitmapFactory.decodeResource(res, R.drawable.ic_logo_tes2);
        Log.e("tes", "Masuk onCreate");
        onClick(text, company);
    }


    public void onClick(String data, String company) {
        String content = "tes 1 \n" +
                "tes 2" +
                "tes 3";
        Log.d("tes", "print 1");
        float size = Integer.parseInt("10");
        if (!BluetoothUtil.isBlueToothPrinter) {
            SunmiPrintHelper.getInstance().initPrinter();
            SunmiPrintHelper.getInstance().printText(content, size, isBold, isUnderLine);
            SunmiPrintHelper.getInstance().feedPaper();
            Log.d("tes", "tes");
        } else {
            printByBluTooth(data, company);
            Log.d("tes", "print 3");
        }
    }

    private void printByBluTooth(String content, String company) {
        try {
            if (isBold) {
                BluetoothUtil.sendData(ESCUtil.boldOn());
            } else {
                BluetoothUtil.sendData(ESCUtil.boldOff());
            }

            if (isUnderLine) {
                BluetoothUtil.sendData(ESCUtil.underlineWithOneDotWidthOn());
            } else {
                BluetoothUtil.sendData(ESCUtil.underlineOff());
            }

            if (record < 17) {
                BluetoothUtil.sendData(ESCUtil.singleByte());
                BluetoothUtil.sendData(ESCUtil.setCodeSystemSingle(codeParse(record)));
            } else {
                BluetoothUtil.sendData(ESCUtil.singleByteOff());
                BluetoothUtil.sendData(ESCUtil.setCodeSystem(codeParse(record)));
            }
//            Resources res = getResources();
//            bMap = BitmapFactory.decodeResource(res, R.drawable.bg_top);
            Log.e("tes", "Masuk onCreate");
//            Log.e("tes", bMap.toString());
//            Bitmap bMap = BitmapFactory.decodeResource(getApplication().getApplicationContext().getResources(), R.drawable.ic_logo_tes);
            Bitmap bmp = Bitmap.createBitmap(bMap, 0, 0, 10, 10);
            BluetoothUtil.sendData(ESCUtil.alignRight());
            BluetoothUtil.sendData(header.getBytes(mStrings[record]));
            BluetoothUtil.sendData(ESCUtil.alignCenter());
            BluetoothUtil.sendData(company.getBytes(mStrings[record]));
//            BluetoothUtil.sendData(ESCUtil.printBitmap(bMap));
//            BlutoothUtil.sendData(ESCUtil)
            BluetoothUtil.sendData(ESCUtil.alignLeft());
            BluetoothUtil.sendData(content.getBytes(mStrings[record]));
            BluetoothUtil.sendData(ESCUtil.nextLine(3));
        } catch (IOException e) {
            e.printStackTrace();
            Log.d("tes1", e.toString());
        }
        finish();
    }

    private byte codeParse(int value) {
        byte res = 0x00;
        switch (value) {
            case 0:
                res = 0x00;
                break;
            case 1:
            case 2:
            case 3:
            case 4:
                res = (byte) (value + 1);
                break;
            case 5:
            case 6:
            case 7:
            case 8:
            case 9:
            case 10:
            case 11:
                res = (byte) (value + 8);
                break;
            case 12:
                res = 21;
                break;
            case 13:
                res = 33;
                break;
            case 14:
                res = 34;
                break;
            case 15:
                res = 36;
                break;
            case 16:
                res = 37;
                break;
            case 17:
            case 18:
            case 19:
                res = (byte) (value - 17);
                break;
            case 20:
                res = (byte) 0xff;
                break;
            default:
                break;
        }
        return (byte) res;
    }
}
