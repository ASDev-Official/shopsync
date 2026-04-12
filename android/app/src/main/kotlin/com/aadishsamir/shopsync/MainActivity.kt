package com.aadishsamir.shopsync

import android.accounts.Account
import android.accounts.AccountAuthenticatorResponse
import android.accounts.AccountManager
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	companion object {
		const val CHANNEL_NAME = "shopsync/system_accounts"
		const val SHOPSYNC_ACCOUNT_TYPE = "com.aadishsamir.shopsync.account"
		const val ACTION_ADD_ACCOUNT = "com.aadishsamir.shopsync.ADD_ACCOUNT"
	}

	private var pendingAddAccountRequest = false
	private var accountAuthenticatorResponse: AccountAuthenticatorResponse? = null

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		captureIntentAction(intent)
	}

	override fun onNewIntent(intent: Intent) {
		super.onNewIntent(intent)
		setIntent(intent)
		captureIntentAction(intent)
	}

	private fun captureIntentAction(intent: Intent?) {
		if (intent?.action == ACTION_ADD_ACCOUNT) {
			pendingAddAccountRequest = true
			@Suppress("DEPRECATION")
			accountAuthenticatorResponse =
				intent.getParcelableExtra(AccountManager.KEY_ACCOUNT_AUTHENTICATOR_RESPONSE)
		} else {
			accountAuthenticatorResponse = null
		}
	}

	private fun completeAccountAuthenticatorFlow(
		completed: Boolean,
		accountName: String? = null,
		accountType: String? = null,
		message: String? = null,
	) {
		val response = accountAuthenticatorResponse
		accountAuthenticatorResponse = null
		pendingAddAccountRequest = false

		if (response != null) {
			if (completed) {
				val resultBundle = Bundle().apply {
					if (!accountName.isNullOrBlank()) {
						putString(AccountManager.KEY_ACCOUNT_NAME, accountName)
					}
					putString(AccountManager.KEY_ACCOUNT_TYPE, accountType ?: SHOPSYNC_ACCOUNT_TYPE)
				}
				response.onResult(resultBundle)
			} else {
				response.onError(AccountManager.ERROR_CODE_CANCELED, message ?: "Account addition cancelled")
			}
		}
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
			.setMethodCallHandler { call, result ->
				val accountManager = AccountManager.get(this)

				when (call.method) {
					"addOrUpdateAccount" -> {
						val args = call.arguments as? Map<*, *>
						val email = args?.get("email")?.toString()
						val uid = args?.get("uid")?.toString()
						val displayName = args?.get("displayName")?.toString()
						val password = args?.get("password")?.toString()
						val provider = args?.get("provider")?.toString()
						val normalizedProvider = when {
							provider?.contains("google", ignoreCase = true) == true -> "google"
							provider?.contains("password", ignoreCase = true) == true -> "password"
							else -> provider
						}

						if (email.isNullOrBlank()) {
							result.error("invalid_args", "email is required", null)
							return@setMethodCallHandler
						}

						val existing = accountManager.getAccountsByType(SHOPSYNC_ACCOUNT_TYPE)
							.firstOrNull { it.name.equals(email, ignoreCase = true) }

						if (existing != null) {
							accountManager.setPassword(existing, password)
							if (!uid.isNullOrBlank()) {
								accountManager.setUserData(existing, "uid", uid)
							}
							if (!displayName.isNullOrBlank()) {
								accountManager.setUserData(existing, "displayName", displayName)
							}
							if (!normalizedProvider.isNullOrBlank()) {
								accountManager.setUserData(existing, "provider", normalizedProvider)
							}
							result.success(true)
							return@setMethodCallHandler
						}

						val account = Account(email, SHOPSYNC_ACCOUNT_TYPE)
						val userData = Bundle().apply {
							if (!uid.isNullOrBlank()) putString("uid", uid)
							if (!displayName.isNullOrBlank()) putString("displayName", displayName)
							if (!normalizedProvider.isNullOrBlank()) putString("provider", normalizedProvider)
						}

						val added = accountManager.addAccountExplicitly(account, password, userData)
						result.success(added)
					}

					"removeAccount" -> {
						val args = call.arguments as? Map<*, *>
						val email = args?.get("email")?.toString()

						if (email.isNullOrBlank()) {
							result.error("invalid_args", "email is required", null)
							return@setMethodCallHandler
						}

						val existing = accountManager.getAccountsByType(SHOPSYNC_ACCOUNT_TYPE)
							.firstOrNull { it.name.equals(email, ignoreCase = true) }

						if (existing == null) {
							result.success(true)
							return@setMethodCallHandler
						}

						val removed = accountManager.removeAccountExplicitly(existing)
						result.success(removed)
					}

					"listAccounts" -> {
						val accounts = accountManager.getAccountsByType(SHOPSYNC_ACCOUNT_TYPE)
						val mapped = accounts.map { account ->
							val password = accountManager.getPassword(account)
							val provider = accountManager.getUserData(account, "provider")
								?: if (!password.isNullOrBlank()) "password" else "password"
							mapOf(
								"name" to account.name,
								"uid" to accountManager.getUserData(account, "uid"),
								"displayName" to accountManager.getUserData(account, "displayName"),
								"provider" to provider,
								"hasPassword" to (!password.isNullOrBlank()).toString(),
							)
						}
						result.success(mapped)
					}

					"getStoredPassword" -> {
						val args = call.arguments as? Map<*, *>
						val email = args?.get("email")?.toString()

						if (email.isNullOrBlank()) {
							result.error("invalid_args", "email is required", null)
							return@setMethodCallHandler
						}

						val existing = accountManager.getAccountsByType(SHOPSYNC_ACCOUNT_TYPE)
							.firstOrNull { it.name.equals(email, ignoreCase = true) }

						if (existing == null) {
							result.success(null)
							return@setMethodCallHandler
						}

						result.success(accountManager.getPassword(existing))
					}

					"openSystemAddAccountFlow" -> {
						pendingAddAccountRequest = true
						accountManager.addAccount(
							SHOPSYNC_ACCOUNT_TYPE,
							null,
							null,
							null,
							this,
							null,
							null,
						)
						result.success(true)
					}

					"consumePendingAddAccountRequest" -> {
						val pending = pendingAddAccountRequest
						pendingAddAccountRequest = false
						result.success(pending)
					}

					"closeSystemAddAccountFlow" -> {
						val args = call.arguments as? Map<*, *>
						val completed = args?.get("completed") as? Boolean ?: false
						val accountName = args?.get("accountName")?.toString()
						val accountType = args?.get("accountType")?.toString()
						val message = args?.get("message")?.toString()
						completeAccountAuthenticatorFlow(
							completed = completed,
							accountName = accountName,
							accountType = accountType,
							message = message,
						)
						result.success(true)
						finish()
					}

					else -> result.notImplemented()
				}
			}
	}
}
