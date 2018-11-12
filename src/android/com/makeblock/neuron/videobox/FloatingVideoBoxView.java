package com.makeblock.neuron.videobox;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.media.MediaPlayer;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;

import com.makeblock.neuron.R;

/**
 * Created by liguomin on 2018/11/7.
 */
enum PLAYER_MODE {
    NORMAL,
    FULLSCREEN,
    VIDEOONLY
};

public class FloatingVideoBoxView extends FrameLayout {

    private static final String TAG = FloatingVideoBoxView.class.getSimpleName();

    private static final ViewGroup.LayoutParams NORMAL_PARAM = new ViewGroup.LayoutParams(320, 240);

    private float dX;
    private float dY;
    private int lastAction;
    private MediaPlayer player;
    private PLAYER_MODE mode;

    private float screenHeight;
    private float sceenWidth;

    private float normalPadding;
    private float fullScreenBtnSizeNormal;
    private float fullScreenBtnSizeFullScreen;
    private float replayBtnSizeNormal;
    private float replayBtnSizeFullScreen;

    private View view;
    private Button btnToggleFullScreen;
    private Button btnReplay;
    private SurfaceView videoContainer;

    private float relativeX;
    private float relativeY;
    private float relativeHeight;
    private float relativeWidth;

    public FloatingVideoBoxView(Context context) {
        super(context);
        mode = PLAYER_MODE.NORMAL;
        this.view = inflate(getContext(), R.layout.floating_video_box_layout,null);
        addView(this.view);

        initPlayer();
        initHolder();

        initButtons();
        initScreenSizeVariable((Activity) context);
    }

    @SuppressLint("ClickableViewAccessibility")
    private void initButtons() {
        this.btnToggleFullScreen = findViewById(R.id.btn_video_toggle_fullscreen);
        this.btnToggleFullScreen.setVisibility(View.GONE);
        this.btnToggleFullScreen.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    toggleFullScreen();
                }
                return true;
            }
        });

        this.btnReplay = findViewById(R.id.btn_video_replay);
        this.btnReplay.setVisibility(View.GONE);
        this.btnReplay.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    btnReplay.setVisibility(View.GONE);
                    player.start();
                }
                return true;
            }
        });
    }

    private void initScreenSizeVariable(Activity context) {
        DisplayMetrics displayMetrics = new DisplayMetrics();
        context.getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
        screenHeight = displayMetrics.heightPixels;
        sceenWidth = displayMetrics.widthPixels;

        DisplayMetrics currentMetric = getResources().getDisplayMetrics();
        normalPadding = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 3, currentMetric);
        fullScreenBtnSizeNormal = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 30, currentMetric);
        fullScreenBtnSizeFullScreen = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 54, currentMetric);
        replayBtnSizeNormal = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 65, currentMetric);
        replayBtnSizeFullScreen = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 85, currentMetric);
//        normalPadding = 3 * getResources().getDisplayMetrics().density;
    }

    private void initHolder() {
        videoContainer = this.findViewById(R.id.video_container);
        videoContainer.getHolder().addCallback(new SurfaceHolder.Callback() {
            @Override
            public void surfaceCreated(SurfaceHolder holder) {
                Log.d(TAG, "surfaceCreated=" + System.currentTimeMillis());
                player.setDisplay(holder);

            }

            @Override
            public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
                Log.d(TAG, "surfaceChanged=" + System.currentTimeMillis());
            }

            @Override
            public void surfaceDestroyed(SurfaceHolder holder) {
                Log.d(TAG, "surfaceDestroyed=" + System.currentTimeMillis());
            }
        });
        videoContainer.setZOrderMediaOverlay(true);
    }

    private void initPlayer() {
        final Activity context = (Activity)this.getContext();
        player = new MediaPlayer();
//        player.setAudioStreamType(AudioManager.STREAM_MUSIC);
        player.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                context.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        btnReplay.setVisibility(View.GONE);
                    }
                });
                player.start();
            }
        });
        player.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                if (autoloop()) {
                    player.start();
                }
                else {
                    context.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            btnReplay.setVisibility(View.VISIBLE);
                        }
                    });
                }
            }
        });
    }

    private boolean autoloop() {
        return this.mode == PLAYER_MODE.VIDEOONLY;
    }

    private boolean draggable() {
        return this.mode == PLAYER_MODE.NORMAL;
    }

    private void enterNormal() {
        ViewGroup.LayoutParams params = this.getLayoutParams();
        params.height = (int)this.calculateByHeight(NORMAL_PARAM.height);
        params.width = (int)this.calculateByHeight(NORMAL_PARAM.width);
        this.setLayoutParams(params);
        this.positionRightTop();

        this.view.setBackground(getResources().getDrawable(R.drawable.floating_video_border));
        this.view.setPadding((int)normalPadding, (int)normalPadding, (int)normalPadding, (int)normalPadding);

       this.modifyButtonsToNormal();
    }

    private void modifyButtonsToNormal() {
        this.btnToggleFullScreen.setBackground(getResources().getDrawable(R.drawable.icon_video_small_fullscreen));
        ViewGroup.LayoutParams btnToggleFulllScreenParams = this.btnToggleFullScreen.getLayoutParams();
        btnToggleFulllScreenParams.width = (int)fullScreenBtnSizeNormal;
        btnToggleFulllScreenParams.height = (int)fullScreenBtnSizeNormal;
        this.btnToggleFullScreen.setLayoutParams(btnToggleFulllScreenParams);
        this.btnToggleFullScreen.setVisibility(View.VISIBLE);

        ViewGroup.LayoutParams btnReplayParams = this.btnReplay.getLayoutParams();
        btnReplayParams.width = (int)replayBtnSizeNormal;
        btnReplayParams.height = (int)replayBtnSizeNormal;
        this.btnReplay.setLayoutParams(btnReplayParams);
    }

    private void enterVideoOnly() {
//        ViewGroup.LayoutParams params = this.getLayoutParams();
//        params.width = (int)this.relativeWidth;
//        params.height = (int)this.relativeHeight;
//        this.setLayoutParams(params);

        this.setX(this.relativeX);
        this.setY(this.relativeY);

        this.view.setBackgroundResource(0);
        this.view.setPadding(0,0,0,0);

        this.modifyButtonsToVideoOnly();
    }

    private void modifyButtonsToVideoOnly() {
        this.btnToggleFullScreen.setVisibility(View.GONE);
        this.btnReplay.setVisibility(View.GONE);
    }

    private void enterFullScreen() {
        ViewGroup.LayoutParams params = this.getLayoutParams();
        params.height = ViewGroup.LayoutParams.MATCH_PARENT;
        params.width = ViewGroup.LayoutParams.MATCH_PARENT;
        this.setLayoutParams(params);
        this.positionLeftTop();
        this.view.setBackground(null);
        this.view.setPadding(0,0,0,0);

        this.modifyButtonsToFullScreen();
    }

    private void modifyButtonsToFullScreen() {
        this.btnToggleFullScreen.setBackground(getResources().getDrawable(R.drawable.icon_video_big_fullscreen));
        ViewGroup.LayoutParams btnToggleFulllScreenParams = this.btnToggleFullScreen.getLayoutParams();
        btnToggleFulllScreenParams.width = (int)fullScreenBtnSizeFullScreen;
        btnToggleFulllScreenParams.height = (int)fullScreenBtnSizeFullScreen;
        this.btnToggleFullScreen.setLayoutParams(btnToggleFulllScreenParams);
        this.btnToggleFullScreen.setVisibility(View.VISIBLE);

        ViewGroup.LayoutParams btnReplayParams = this.btnReplay.getLayoutParams();
        btnReplayParams.width = (int)replayBtnSizeFullScreen;
        btnReplayParams.height = (int)replayBtnSizeFullScreen;
        this.btnReplay.setLayoutParams(btnReplayParams);
    }

    private void toggleFullScreen() {
        if (this.mode == PLAYER_MODE.FULLSCREEN) {
            this.setMode(PLAYER_MODE.NORMAL);
        }
        else if (this.mode == PLAYER_MODE.NORMAL) {
            this.setMode(PLAYER_MODE.FULLSCREEN);
        }
    }

    private void toggleDisplayByMode() {
        switch (this.mode) {
            case NORMAL:
                this.enterNormal();
                break;
            case VIDEOONLY:
                this.enterVideoOnly();
                break;
            case FULLSCREEN:
                this.enterFullScreen();
                break;
        }
    }

    private void positionLeftTop() {
        this.setX(0);
        this.setY(0);
    }

    private void positionRightTop() {
        DisplayMetrics displayMetrics = new DisplayMetrics();
        ((Activity)getContext()).getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
        int screenHeight = displayMetrics.heightPixels;
        int screenWidth = displayMetrics.widthPixels;

        int x = screenWidth - this.getLayoutParams().width;
        this.setY(0);
        this.setX(x);
    }

    private float calculateByHeight(float num) {
        return num / 768 * screenHeight;
    }

    private float calculateByWidth(float num) {
        return num / 1024 * sceenWidth;
    }

    private void hideContainer() {
        ViewGroup.LayoutParams params = this.videoContainer.getLayoutParams();
        params.height = 0;
        params.width = 0;
        this.videoContainer.setLayoutParams(params);
    }

    private void restoreContainer() {
        ViewGroup.LayoutParams params = this.videoContainer.getLayoutParams();
        params.height = ViewGroup.LayoutParams.MATCH_PARENT;
        params.width = ViewGroup.LayoutParams.MATCH_PARENT;
        this.videoContainer.setLayoutParams(params);
    }

    public void show() {
        if (this.mode == PLAYER_MODE.VIDEOONLY) {
            ViewGroup.LayoutParams params = this.getLayoutParams();
            params.width = (int)this.relativeWidth;
            params.height = (int)this.relativeHeight;
            this.setLayoutParams(params);
        }

        this.toggleDisplayByMode();
//        this.videoContainer.setVisibility(View.VISIBLE);
//
//        this.setVisibility(View.VISIBLE);
//        this.view.setVisibility(View.VISIBLE);
        this.restoreContainer();
    }

    public void hide() {
        ViewGroup.LayoutParams params = this.getLayoutParams();
        params.width = 0;
        params.height = 0;
        this.setLayoutParams(params);
        this.positionLeftTop();
//        this.videoContainer.setVisibility(View.INVISIBLE);
        this.hideContainer();
//        this.setVisibility(View.GONE);
//        this.view.setVisibility(View.GONE);
    }

    public void setMode(PLAYER_MODE mode) {
        this.mode = mode;
        this.toggleDisplayByMode();
    }

    public void setWidth(int width) {
        this.relativeWidth = this.calculateByWidth((width));

        ViewGroup.LayoutParams params = this.getLayoutParams();
        params.width = (int)this.relativeWidth;
        this.setLayoutParams(params);
    }

    public void setHeight(int height) {
        this.relativeHeight = this.calculateByHeight(height);

        ViewGroup.LayoutParams params = this.getLayoutParams();
        params.height = (int)this.relativeHeight;
        this.setLayoutParams(params);
    }

    public void setRelativeX(float x) {
        this.relativeX = this.calculateByWidth(x);
        this.setX(this.relativeX);
    }

    public void setRelativeY(float y) {
        this.relativeY = this.calculateByHeight(y);
        this.setY(this.relativeY);
    }

    public void playAssetVideo(AssetFileDescriptor afd) {
        try {
            player.reset();
            player.setDataSource(afd.getFileDescriptor(),afd.getStartOffset(), afd.getLength());
            player.prepare();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    @Override
    public boolean onTouchEvent(MotionEvent event) {
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                dX = this.getX() - event.getRawX();
                dY = this.getY() - event.getRawY();
                lastAction = MotionEvent.ACTION_DOWN;
                break;

            case MotionEvent.ACTION_MOVE:
                if (draggable()) {
                    this.setY(event.getRawY() + dY);
                    this.setX(event.getRawX() + dX);
                }
                lastAction = MotionEvent.ACTION_MOVE;
                break;

            case MotionEvent.ACTION_UP:
                lastAction = MotionEvent.ACTION_UP;
                break;

            default:
                return false;
        }
        return true;
    }

    @Override
    public boolean performClick() {
        return super.performClick();
    }
}
