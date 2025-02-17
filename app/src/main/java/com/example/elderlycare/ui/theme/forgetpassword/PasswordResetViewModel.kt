import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope

import com.example.elderlycare.data.network.ForgotPasswordRequest
import com.example.elderlycare.data.network.ResetPasswordRequest
import com.example.elderlycare.data.network.RetrofitClient
import com.example.elderlycare.data.network.VerifyResetCodeRequest
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class PasswordResetViewModel : ViewModel() {

    private val apiService = RetrofitClient.getApiService() // Assuming you have a RetrofitClient singleton
    private val _uiState = MutableStateFlow<PasswordResetState>(PasswordResetState.Initial)
    val uiState: StateFlow<PasswordResetState> = _uiState.asStateFlow()

    private var resetToken: String? = null
    private var verifiedToken: String? = null

    fun requestPasswordReset(email: String) {
        viewModelScope.launch {
            _uiState.value = PasswordResetState.Loading
            try {
                val response = apiService.requestPasswordReset(ForgotPasswordRequest(email))
                resetToken = response.resetToken
                _uiState.value = PasswordResetState.CodeSent(response.message)
            } catch (e: Exception) {
                _uiState.value = PasswordResetState.Error("Failed to send reset code: ${e.message}")
            }
        }
    }

    fun verifyCode(code: String) {
        viewModelScope.launch {
            _uiState.value = PasswordResetState.Loading
            try {
                resetToken?.let { token ->
                    val response = apiService.verifyResetCode(
                        VerifyResetCodeRequest(token, code)
                    )
                    verifiedToken = response.verifiedToken
                    _uiState.value = PasswordResetState.CodeVerified(response.message)
                } ?: throw IllegalStateException("Reset token not found")
            } catch (e: Exception) {
                _uiState.value = PasswordResetState.Error("Failed to verify code: ${e.message}")
            }
        }
    }

    fun resetPassword(newPassword: String) {
        viewModelScope.launch {
            _uiState.value = PasswordResetState.Loading
            try {
                verifiedToken?.let { token ->
                    val response = apiService.resetPassword(
                        ResetPasswordRequest(token, newPassword)
                    )
                    _uiState.value = PasswordResetState.Success(response.message)
                } ?: throw IllegalStateException("Verified token not found")
            } catch (e: Exception) {
                _uiState.value = PasswordResetState.Error("Failed to reset password: ${e.message}")
            }
        }
    }

    fun validatePassword(password: String): Boolean {
        val passwordPattern = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{8,}$".toRegex()
        return passwordPattern.matches(password)
    }

    fun validateEmail(email: String): Boolean {
        val emailPattern = "[a-zA-Z0-9._-]+@[a-z]+\\.+[a-z]+".toRegex()
        return emailPattern.matches(email)
    }

    fun resetState() {
        _uiState.value = PasswordResetState.Initial
        resetToken = null
        verifiedToken = null
    }
}

sealed class PasswordResetState {
    object Initial : PasswordResetState()
    object Loading : PasswordResetState()
    data class CodeSent(val message: String) : PasswordResetState()
    data class CodeVerified(val message: String) : PasswordResetState()
    data class Success(val message: String) : PasswordResetState()
    data class Error(val message: String) : PasswordResetState()
}