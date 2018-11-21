
package co.work.rnshareigstories;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.support.v4.content.FileProvider;
import android.webkit.MimeTypeMap;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

import java.io.File;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RNShareInstagramStoriesModule extends ReactContextBaseJavaModule {
  private static final String INSTAGRAM_PACKAGE_NAME = "com.instagram.android";
  private static final String INSTAGRAM_STORIES_SHARE = "com.instagram.share.ADD_TO_STORY";

  private static final List FILE_TYPES_SUPPORTED = Arrays.asList("image/jpeg", "image/png");

  private final ReactApplicationContext reactContext;

  private enum ErrorCodes {
    GENERAL_ERROR,
    NOT_INSTALLED_ERROR,
    FILE_TYPE_UNSUPPORTED_ERROR,
    LAUNCH_ERROR
  }

  public RNShareInstagramStoriesModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNShareInstagramStories";
  }

  @Override
  public Map<String, Object> getConstants() {
    final Map<String, Object> constants = new HashMap<>();

    for (ErrorCodes code: ErrorCodes.values()) {
      constants.put(code.toString(), code.toString());
    }

    return constants;
  }

  private String getFileMimeType(String url) {
    String type = null;

    String extension = MimeTypeMap.getFileExtensionFromUrl(url);
    if (extension != null) {
      type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
    }

    return type;
  }

  private Uri getUriFromString(String path) {
    final String packageName = this.reactContext.getApplicationContext().getPackageName();

    return FileProvider.getUriForFile(this.reactContext.getApplicationContext(),
            packageName + ".provider", new File(Uri.parse(path).getPath()));
  }

  private boolean checkInstagramApp() {
    PackageManager pm = this.reactContext.getPackageManager();

    try {
      pm.getPackageInfo(INSTAGRAM_PACKAGE_NAME, 0);
    } catch (PackageManager.NameNotFoundException e) {
      return false;
    }

    return true;
  }

  @ReactMethod
  public void isAvailable(Promise promise) {
    promise.resolve(this.checkInstagramApp());
  }

  @ReactMethod
  public void shareWithStories(String backgroundAssetUri, String stickerAssetUri, Promise promise) {
    if (!this.checkInstagramApp()) {
      promise.reject(ErrorCodes.NOT_INSTALLED_ERROR.toString());
      return;
    }

    Uri backgroundAsset = this.getUriFromString(backgroundAssetUri);

    String fileType = this.getFileMimeType(backgroundAsset.getPath());
    if (fileType == null || !FILE_TYPES_SUPPORTED.contains(fileType)) {
      promise.reject(ErrorCodes.FILE_TYPE_UNSUPPORTED_ERROR.toString());
      return;
    }

    Intent intent = new Intent(INSTAGRAM_STORIES_SHARE);
    intent.setDataAndType(backgroundAsset, fileType);
    intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

    Activity activity = getCurrentActivity();

    if (stickerAssetUri != null) {
        Uri stickerAsset = this.getUriFromString(stickerAssetUri);
        intent.putExtra("interactive_asset_uri", stickerAsset);

        activity.grantUriPermission(
                INSTAGRAM_PACKAGE_NAME, stickerAsset,
                Intent.FLAG_GRANT_READ_URI_PERMISSION);
    }

    try {
      if (activity.getPackageManager().resolveActivity(intent, 0) != null) {
        activity.startActivityForResult(intent, 0);
        promise.resolve(true);
      }
      else {
        promise.reject(ErrorCodes.LAUNCH_ERROR.toString());
      }
    } catch(Error err) {
      System.err.println(err);
      promise.reject(ErrorCodes.GENERAL_ERROR.toString());
    }
  }
}
