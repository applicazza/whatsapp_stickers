package dev.applicazza.flutter.plugins.whatsapp_stickers;

import android.content.ContentResolver;
import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import io.flutter.plugin.common.MethodCall;
import io.flutter.util.PathUtils;

import static dev.applicazza.flutter.plugins.whatsapp_stickers.StickerPackLoader.getStickerAssetUri;

public class ConfigFileManager {

    public static final String CONTENT_FILE_NAME = "sticker_packs.json";

    static List<StickerPack> getStickerPacks(Context context){
        List<StickerPack> stickerPackList;
        File file = new File(getConfigFilePath(context));
        if(!file.exists()){
            return new ArrayList<StickerPack>();
        }
        try (InputStream contentsInputStream = new FileInputStream(file)) {
           stickerPackList = ContentFileParser.parseStickerPacks(contentsInputStream);
        } catch (IOException | IllegalStateException e) {
            throw new RuntimeException("config file has some issues: " + e.getMessage(), e);
        }
        return stickerPackList;
    }

    static StickerPack fromMethodCall(Context context, MethodCall call){
        String identifier = call.argument("identifier");
        String name = call.argument("name");
        String publisher = call.argument("publisher");
        String trayImageFileName = call.argument("trayImageFileName");
        trayImageFileName = getFileName(trayImageFileName);
        String publisherWebsite = call.argument("publisherWebsite");
        String privacyPolicyWebsite = call.argument("privacyPolicyWebsite");
        String licenseAgreementWebsite = call.argument("licenseAgreementWebsite");
        Map<String, List<String>> stickers = call.argument("stickers");

        StickerPack newStickerPack = new StickerPack(identifier, name, publisher, trayImageFileName, "", publisherWebsite, privacyPolicyWebsite, licenseAgreementWebsite, "1", false);
        List<Sticker> newStickers = new ArrayList<Sticker>();
        assert stickers != null;
        for (Map.Entry<String, List<String>> entry : stickers.entrySet()) {
            Sticker s = new Sticker(getFileName(entry.getKey()), entry.getValue());
            newStickers.add(s);
        }
        newStickerPack.setStickers(newStickers);
        newStickerPack.setAndroidPlayStoreLink("");
        newStickerPack.setIosAppStoreLink("");
        return newStickerPack;
    }

    static boolean addNewPack(Context context, StickerPack stickerPack) throws JSONException, InvalidPackException {
        List<StickerPack> stickerPacks = new ArrayList<StickerPack>();
        for(StickerPack s: getStickerPacks(context)){
            if(!s.identifier.equals(stickerPack.identifier)){
                stickerPacks.add(s);
            }
        }
        stickerPacks.add(stickerPack);
        return updateConfigFile(context,stickerPacks);
    }

    static String getFileName(String name){
        if(name.contains("assets://")){
            name = name.replace("assets://", "");
            name = name.replace("/", "_MZN_AD_");
        }else if(name.contains("file://")) {
            name = name.replace("file://", "");
            name = name.replace("/", "_MZN_FD_");
        }
        return name;
    }

    static boolean updateConfigFile(Context context, List<StickerPack> stickerPacks) throws JSONException, InvalidPackException {
        JSONObject mObj = new JSONObject();
        if(stickerPacks.size() <= 0){
            mObj.put("android_play_store_link", "");
            mObj.put("ios_app_store_link", "");
        }else{
            mObj.put("android_play_store_link", stickerPacks.get(0).androidPlayStoreLink);
            mObj.put("ios_app_store_link", stickerPacks.get(0).iosAppStoreLink);
        }
        JSONArray _packs = new JSONArray();
        for(StickerPack s: stickerPacks){
            JSONObject obj = new JSONObject();
            obj.put("identifier", s.identifier);
            obj.put("name", s.name);
            obj.put("publisher", s.publisher);
            obj.put("tray_image_file", getFileName(s.trayImageFile));
            obj.put("image_data_version", s.imageDataVersion);
            obj.put("avoid_cache", s.avoidCache);
            obj.put("publisher_email", s.publisherEmail);
            obj.put("publisher_website", s.publisherWebsite);
            obj.put("privacy_policy_website", s.privacyPolicyWebsite);
            obj.put("license_agreement_website", s.licenseAgreementWebsite);

            JSONArray stickerList = new JSONArray();
            for (Sticker _sticker: s.getStickers()) {
                JSONObject stickerObj = new JSONObject();
                String stickerFileName = getFileName(_sticker.imageFileName);
                stickerObj.put("image_file", stickerFileName);
                JSONArray _emojies = new JSONArray();
                for(String emoji: _sticker.emojis){
                    _emojies.put(emoji);
                }
                stickerObj.put("emojis", _emojies);
                stickerList.put(stickerObj);
            }
            obj.put("stickers", stickerList);
            _packs.put(obj);
        }
        mObj.put("sticker_packs", _packs);
        writeConfigFile(context, mObj.toString());
        return true;
    }

    static void writeConfigFile(Context context, String jsonString){
        String filePath = getConfigFilePath(context);
        File f = new File(filePath);
        try {
            FileWriter writer = new FileWriter(f);
            writer.write(jsonString);
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    static void generateConfigFile(Context context) throws JSONException {
        File file = new File(getConfigFilePath(context));
        if(!file.exists()){
            //prepare data
            JSONObject mObj = new JSONObject();
            mObj.put("android_play_store_link", "");
            mObj.put("ios_app_store_link", "");
            JSONArray _packs = new JSONArray();
            mObj.put("sticker_packs", _packs);
            // write in file
            writeConfigFile(context, mObj.toString());
        }
    }

    public static String getConfigFilePath(Context context){
        return PathUtils.getDataDirectory(context) + File.separator + CONTENT_FILE_NAME;
    }
}
