package com.example.anugrahesj;

import android.content.Intent;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.esj/print";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        if (call.method.equals("Print")) {
                            String data = call.argument("data");
                            String company = call.argument("company");
                            String header = call.argument("header");
                            String greetings = "Tes 123";

                            String center = new String(new byte[]{0x1B,97,1});
                            String left = new String(new byte[]{0x1B,97,0});
                            String right = new String(new byte[]{0x1B,97,2});
                            String nextLine = new String(new byte[]{0x0A});

                            String textToPrint = right+header+nextLine+center+company+nextLine+left+data; // plain or base64
                            Intent intent = new Intent("ru.a402d.rawbtprinter.action.PRINT_RAWBT"); // action
                            intent.putExtra("ru.a402d.rawbtprinter.extra.DATA",textToPrint); // extra
                            intent.setPackage("ru.a402d.rawbtprinter");
                            startService(intent);

//                            Intent intent = new Intent(getBaseContext(), PrintActivity.class);
//                            intent.putExtra("EXTRA_DATA", data);
//                            intent.putExtra("EXTRA_COMPANY", company);
//                            intent.putExtra("EXTRA_HEADER", header);
//                            startActivityForResult(intent, 2);
//                            result.success(greetings);
                        }
                    }
                });
    }
}

