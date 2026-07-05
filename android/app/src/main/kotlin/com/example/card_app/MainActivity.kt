package com.example.card_app

import android.content.ContentValues
import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.provider.ContactsContract

class MainActivity: FlutterActivity() {
  private val CHANNEL = "my_app/contacts"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
      if (call.method == "addOrUpdate") {
        val args = call.arguments as? Map<String, Any?>
        if (args != null && insertContactAndroid(args)) {
          result.success(true)
        } else {
          result.success(false)
        }
      } else {
        result.notImplemented()
      }
    }
  }

  private fun insertContactAndroid(data: Map<String, Any?>): Boolean {
    try {
      // Extract basic fields
      val fullName     = (data["fullName"]    as? String)?.trim() ?: ""
      val phones       = data["phones"]        as? List<String> ?: emptyList()
      val emails       = data["emails"]        as? List<String> ?: emptyList()
      val organisation = (data["organisation"] as? String)?.trim() ?: ""
      val jobTitle     = (data["jobTitle"]     as? String)?.trim() ?: ""
      val location     = (data["location"]     as? String)?.trim() ?: ""
      val aboutMe      = (data["aboutMe"]      as? String)?.trim() ?: ""
      val websites     = data["websites"]      as? List<Map<String, String>> ?: emptyList()

      // Build the base Intent for inserting a new contact
      val intent = Intent(Intent.ACTION_INSERT).apply {
        type = ContactsContract.Contacts.CONTENT_TYPE

        if (fullName.isNotEmpty()) {
          putExtra(ContactsContract.Intents.Insert.NAME, fullName)
        }
        if (organisation.isNotEmpty()) {
          putExtra(ContactsContract.Intents.Insert.COMPANY, organisation)
        }
        if (jobTitle.isNotEmpty()) {
          putExtra(ContactsContract.Intents.Insert.JOB_TITLE, jobTitle)
        }

        // Combine location + aboutMe into NOTES
        val noteBuilder = StringBuilder()
        if (location.isNotEmpty()) {
          noteBuilder.append("Address: ").append(location).append("\n")
        }
        if (aboutMe.isNotEmpty()) {
          noteBuilder.append("About: ").append(aboutMe)
        }
        val noteText = noteBuilder.toString().trim()
        if (noteText.isNotEmpty()) {
          putExtra(ContactsContract.Intents.Insert.NOTES, noteText)
        }
      }

      // Build DATA rows for all phones, emails, and websites
      val dataRows = ArrayList<ContentValues>()

      // Phones
      for (phone in phones) {
        if (phone.trim().isEmpty()) continue
        val row = ContentValues().apply {
          put(ContactsContract.Data.MIMETYPE, ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
          put(ContactsContract.CommonDataKinds.Phone.NUMBER, phone.trim())
          put(ContactsContract.CommonDataKinds.Phone.TYPE, ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE)
        }
        dataRows.add(row)
      }

      // Emails
      for (email in emails) {
        if (email.trim().isEmpty()) continue
        val row = ContentValues().apply {
          put(ContactsContract.Data.MIMETYPE, ContactsContract.CommonDataKinds.Email.CONTENT_ITEM_TYPE)
          put(ContactsContract.CommonDataKinds.Email.ADDRESS, email.trim())
          put(ContactsContract.CommonDataKinds.Email.TYPE, ContactsContract.CommonDataKinds.Email.TYPE_WORK)
        }
        dataRows.add(row)
      }

      // Websites (set all to TYPE_OTHER)
      for (site in websites) {
        val url = (site["url"] ?: "").trim()
        if (url.isEmpty()) continue
        val row = ContentValues().apply {
          put(ContactsContract.Data.MIMETYPE, ContactsContract.CommonDataKinds.Website.CONTENT_ITEM_TYPE)
          put(ContactsContract.CommonDataKinds.Website.URL, url)
          put(ContactsContract.CommonDataKinds.Website.TYPE, ContactsContract.CommonDataKinds.Website.TYPE_OTHER)
        }
        dataRows.add(row)
      }

      if (dataRows.isNotEmpty()) {
        intent.putParcelableArrayListExtra(ContactsContract.Intents.Insert.DATA, dataRows)
      }

      // Launch the native "Add Contact" UI
      intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
      startActivity(intent)
      return true
    } catch (e: Exception) {
      e.printStackTrace()
      return false
    }
  }
}