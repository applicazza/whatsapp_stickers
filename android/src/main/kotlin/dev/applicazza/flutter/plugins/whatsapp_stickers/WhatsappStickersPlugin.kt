package dev.applicazza.flutter.plugins.whatsapp_stickers

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File


/** WhatsappStickersPlugin */
public class WhatsappStickersPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var context: Context? = null
  private var stickerPackList: List<StickerPack>? = null
  private var activity: Activity? = null
  private var result: Result? = null
  val ADD_PACK = 200

  private val EXTRA_STICKER_PACK_ID = "sticker_pack_id"
  private val EXTRA_STICKER_PACK_AUTHORITY = "sticker_pack_authority"
  private val EXTRA_STICKER_PACK_NAME = "sticker_pack_name"

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "whatsapp_stickers")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {

    private const val EXTRA_STICKER_PACK_ID = "sticker_pack_id"
    private const val EXTRA_STICKER_PACK_AUTHORITY = "sticker_pack_authority"
    private const val EXTRA_STICKER_PACK_NAME = "sticker_pack_name"

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "whatsapp_stickers")
      channel.setMethodCallHandler(WhatsappStickersPlugin())
    }

    @JvmStatic
    fun getContentProviderAuthorityURI(context: Context): Uri{
      return Uri.Builder().scheme(ContentResolver.SCHEME_CONTENT).authority(getContentProviderAuthority(context)).appendPath(StickerContentProvider.METADATA).build()
    }

    @JvmStatic
    fun getContentProviderAuthority(context: Context): String {
      return context.packageName + ".stickercontentprovider"
    }
    
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    this.result = result
    when (call.method) {
      "getPlatformVersion" ->
        result.success("Android " + android.os.Build.VERSION.RELEASE)
      "isWhatsAppInstalled" ->
        result.success(context?.let { WhitelistCheck.isWhatsAppInstalled(it) });
      "isWhatsAppConsumerAppInstalled" ->
        result.success(WhitelistCheck.isWhatsAppConsumerAppInstalled(context?.packageManager));
      "isWhatsAppSmbAppInstalled" ->
        result.success(WhitelistCheck.isWhatsAppSmbAppInstalled(context?.packageManager));
      "isStickerPackInstalled" -> {
        val stickerPackIdentifier = call.argument<String>("identifier");
        if (stickerPackIdentifier != null && context != null) {
          val installed = WhitelistCheck.isWhitelisted(context!!, stickerPackIdentifier)
          result.success(installed);
        }
      }
      "sendToWhatsApp" -> {
        try{
          val stickerPack: StickerPack = ConfigFileManager.fromMethodCall(context, call)
          // update json file
          ConfigFileManager.addNewPack(context, stickerPack)
          context?.let { StickerPackValidator.verifyStickerPackValidity(it, stickerPack) };
          // send intent to whatsapp
          val ws = WhitelistCheck.isWhatsAppConsumerAppInstalled(context?.packageManager)
          if(!(ws || WhitelistCheck.isWhatsAppSmbAppInstalled(context?.packageManager))){
            throw InvalidPackException(InvalidPackException.OTHER, "WhatsApp is not installed on target device!")
          }
          val whatsAppPackage = if(ws) WhitelistCheck.CONSUMER_WHATSAPP_PACKAGE_NAME else WhitelistCheck.SMB_WHATSAPP_PACKAGE_NAME
          val stickerPackIdentifier = stickerPack.identifier
          val stickerPackName = stickerPack.name
          val authority: String? = context?.let { getContentProviderAuthority(it) }

          val intent = createIntentToAddStickerPack(authority, stickerPackIdentifier, stickerPackName)

          try {
            this.activity?.startActivityForResult(Intent.createChooser(intent, "ADD Sticker"), ADD_PACK)
          } catch (e: ActivityNotFoundException) {
            throw InvalidPackException(InvalidPackException.FAILED, "Sticker pack not added. If you'd like to add it, make sure you update to the latest version of WhatsApp.")
          }

        } catch (e: InvalidPackException){
          result.error(e.code, e.message, null)
        }
      }
      else -> result.notImplemented()
    }
  }

  fun createIntentToAddStickerPack(authority: String?, identifier: String?, stickerPackName: String?): Intent? {
    val intent = Intent()
    intent.action = "com.whatsapp.intent.action.ENABLE_STICKER_PACK"
    intent.putExtra(this.EXTRA_STICKER_PACK_ID, identifier)
    intent.putExtra(this.EXTRA_STICKER_PACK_AUTHORITY, authority)
    intent.putExtra(this.EXTRA_STICKER_PACK_NAME, stickerPackName)
    return intent
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {
//    TODO("Not yet implemented"). Сrashed for audio player with whatsapp stickers when double-clicked back
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {

    if (requestCode == ADD_PACK) {
      // Create the intent
      if (resultCode == Activity.RESULT_CANCELED) {
        if (data != null) {
          val validationError = data.getStringExtra("validation_error")
          if (validationError != null) {
            this.result?.error("error", validationError, "")
          }
        } else {
          this.result?.error("cancelled", "cancelled", "")
        }
      } else if (resultCode == Activity.RESULT_OK) {
        if (data != null) {
          val bundle = data.extras!!
          if (bundle!!.containsKey("add_successful")) {
            this.result?.success("add_successful")
          } else if (bundle!!.containsKey("already_added")) {
            this.result?.error("already_added", "already_added", "")
          } else {
            this.result?.success("success")
          }
        } else {
          this.result?.success("success")
        }
      } else {
        this.result?.success("unknown")
      }
    }

    return true
  }
}
