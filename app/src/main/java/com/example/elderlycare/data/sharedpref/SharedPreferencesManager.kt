package com.example.elderlycare.data.sharedpref


import android.content.Context
class SharedPreferencesManager(context: Context) {

    private val sharedPreferences = context.getSharedPreferences("app_preferences", Context.MODE_PRIVATE)

    // Save token and rememberMe flag
    fun saveToken(token: String, rememberMe: Boolean) {
        val editor = sharedPreferences.edit()
        editor.putString("token", token)
        editor.putBoolean("rememberMe", rememberMe)
        editor.apply()
    }

    // Get the stored token
    fun getToken(): String? {
        return sharedPreferences.getString("token", null)
    }

    // Get the rememberMe flag
    fun getRememberMe(): Boolean {
        return sharedPreferences.getBoolean("rememberMe", false)
    }

    // Clear token and rememberMe flag
    fun clearToken() {
        val editor = sharedPreferences.edit()
        editor.remove("token")
        editor.remove("rememberMe")
        editor.apply()
    }
}
