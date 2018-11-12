package com.makeblock.neuron.videobox;

import android.content.res.AssetFileDescriptor;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.util.Log;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.FrameLayout;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONException;

import java.io.IOException;

/**
 * Created by liguomin on 2018/11/8.
 */

public class FloatingVideoBox extends CordovaPlugin {

    private static final String TAG = FloatingVideoBox.class.getSimpleName();

    private FloatingVideoBoxView view;

    @Override
    public void initialize(final CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(0, 0);

        view = new FloatingVideoBoxView(cordova.getActivity());
        view.setBackgroundColor(Color.parseColor("#ffffff"));
        view.setLayoutParams(lp);

        this.cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                FrameLayout layout = cordova.getActivity().findViewById(android.R.id.content);
                layout.addView(view);
            }
        });
    }

    @Override
    public boolean execute(final String action, final CordovaArgs args, CallbackContext callbackContext) throws JSONException {

        this.cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    if (action.equals("setAttribute")) {
                        String key = args.getString(0);
                        if (key.equals("fullscreen")) {
                            boolean val = args.getBoolean(1);
                            if (val) {
                                view.setMode(PLAYER_MODE.FULLSCREEN);
                            }
                            else {
                                view.setMode(PLAYER_MODE.NORMAL);
                            }
                        }
                        else if (key.equals("videoonly")) {
                            view.setMode(PLAYER_MODE.VIDEOONLY);
                        }
                        else if (key.equals("width")) {
                            int val = args.getInt(1);
                            view.setWidth(val);
                        }
                        else if (key.equals("height")) {
                            int val = args.getInt(1);
                            view.setHeight(val);
                        }
                        else if (key.equals("x")) {
                            int val = args.getInt(1);
                            view.setRelativeX(val);
                        }
                        else if (key.equals("y")) {
                            int val = args.getInt(1);
                            view.setRelativeY(val);
                        }
                    }
                    else if (action.equals("show")) {
                        view.show();
                    }
                    else if (action.equals("hide")) {
                        view.hide();
                    }
                    else if (action.equals("playBundleVideo")) {
                        playVideo(args.getString(0));
                    }
                }
                catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        });
        if (action.equals("setAttribute")
                || action.equals("show")
                || action.equals("hide")
                || action.equals("playBundleVideo")
                || action.equals("onPrevButton")
                || action.equals("onNextButton")) {

            return true;
        }

        return false;
    }

    private void playVideo(String path) {
        try {
            AssetFileDescriptor afd = cordova.getActivity().getAssets().openFd(path);
            view.playAssetVideo(afd);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
