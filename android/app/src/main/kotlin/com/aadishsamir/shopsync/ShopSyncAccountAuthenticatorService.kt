package com.aadishsamir.shopsync

import android.app.Service
import android.content.Intent
import android.os.IBinder

class ShopSyncAccountAuthenticatorService : Service() {
    private lateinit var authenticator: ShopSyncAccountAuthenticator

    override fun onCreate() {
        super.onCreate()
        authenticator = ShopSyncAccountAuthenticator(this)
    }

    override fun onBind(intent: Intent?): IBinder {
        return authenticator.iBinder
    }
}
