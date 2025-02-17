package com.example.elderlycare.ui.theme.login

import android.content.Context
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.elderlycare.data.network.LoginResponse
import com.example.elderlycare.data.repositories.UserRepository
import kotlinx.coroutines.launch
import retrofit2.Response
import android.util.Log

// Define the UI state
data class LoginUiState(
    val isLoading: Boolean = false,
    val isLoggedIn: Boolean = false,
    val token: String? = null,
    val errorMessage: String? = null,
    val hasNavigated: Boolean = false,
    val isFirstLogin: Boolean = false

)

class LoginViewModel(private val userRepository: UserRepository) : ViewModel() {

    private var _loginUiState: MutableLiveData<LoginUiState> = MutableLiveData(LoginUiState())
    val loginUiState: LiveData<LoginUiState> get() = _loginUiState

    fun logout(context: Context) {
        val sharedPreferences = context.getSharedPreferences("MyPrefs", Context.MODE_PRIVATE)
        sharedPreferences.edit().clear().apply()
    }

    private fun saveUserData(context: Context, accessToken: String, refreshToken: String, userId: String, rememberMe: Boolean) {
        val sharedPreferences = context.getSharedPreferences("MyPrefs", Context.MODE_PRIVATE)
        with(sharedPreferences.edit()) {
            putString("ACCESS_TOKEN", accessToken)
            putString("REFRESH_TOKEN", refreshToken)
            putString("USER_ID", userId)
            putBoolean("RememberMe", rememberMe)
            apply()
        }
    }

    fun loginUser(context: Context, email: String, password: String, rememberMe: Boolean) {
        viewModelScope.launch {
            _loginUiState.value = LoginUiState(isLoading = true)

            try {
                val response: Response<LoginResponse> = userRepository.login(email, password)

                if (response.isSuccessful) {
                    val loginResponse = response.body()
                    if (loginResponse != null) {
                        val accessToken = loginResponse.accestoken
                        val refreshToken = loginResponse.refreshToken
                        val userId = loginResponse.userId
                        val isFirstLogin = loginResponse.isFirstLogin
                        Log.d("LoginViewModel", "Login successful: isFirstLogin = $isFirstLogin")
                        Log.d("LoginViewModel", "Login successful: userid = $userId")


                        saveUserData(context, accessToken, refreshToken, userId, rememberMe)

                        _loginUiState.value = LoginUiState(isLoggedIn = true, token = accessToken, isFirstLogin = isFirstLogin)
                    } else {
                        _loginUiState.value = LoginUiState(errorMessage = "Login failed: No response body")
                    }
                } else {
                    _loginUiState.value = LoginUiState(errorMessage = "Login failed: ${response.message()}")
                }
            } catch (e: Exception) {
                _loginUiState.value = LoginUiState(errorMessage = e.message)
            }
        }
    }}