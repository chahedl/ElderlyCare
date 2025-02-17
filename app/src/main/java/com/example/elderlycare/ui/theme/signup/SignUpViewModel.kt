package com.example.elderlycare.ui.theme.signup

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.elderlycare.data.network.SignUpResponse
import com.example.elderlycare.data.repositories.UserRepository
import kotlinx.coroutines.launch
import retrofit2.Response

// Define the UI state for SignUp
data class SignUpUiState(
    val isLoading: Boolean = false,
    val isSignedUp: Boolean = false,
    val user: SignUpResponse? = null, // Add user data here
    val successMessage: String? = null,
    val errorMessage: String? = null,
    val hasNavigated: Boolean = false
)

class SignUpViewModel(private val userRepository: UserRepository) : ViewModel() {

    private var _signUpUiState: MutableLiveData<SignUpUiState> = MutableLiveData(SignUpUiState())
    val signUpUiState: LiveData<SignUpUiState> get() = _signUpUiState // Expose as LiveData

    // Function to handle user sign-up
    fun signUpUser(name: String, email: String, password: String) {
        viewModelScope.launch {
            _signUpUiState.value = SignUpUiState(isLoading = true)  // Set loading state
            Log.d("SignUpViewModel", "Sign-up request started for email: $email")  // Log start of request

            try {
                // Log the request body details
                Log.d("SignUpRequest", "Request Body: name=$name, email=$email, password=$password")

                // Make the sign-up request
                val response: Response<SignUpResponse> = userRepository.signUp(name, email, password)

                if (response.isSuccessful) {
                    // Log success if the response is successful
                    Log.d("SignUpResponse", "Sign-up successful: ${response.body()}")

                    val userResponse = response.body()
                    if (userResponse != null) {
                        _signUpUiState.value = SignUpUiState(
                            isSignedUp = true,
                            user = userResponse,
                            successMessage = "Sign-up successful!",
                            hasNavigated = true  // Mark as navigated
                        )
                    } else {
                        // Handle case where response body is null
                        _signUpUiState.value = SignUpUiState(errorMessage = "Sign-up failed: No response body")
                    }
                } else {
                    // Log error if the response is not successful
                    Log.e("SignUpError", "Sign-up failed with code ${response.code()}: ${response.message()}")
                    _signUpUiState.value = SignUpUiState(errorMessage = "Sign-up failed: ${response.message()}")
                }
            } catch (e: Exception) {
                // Log exception if something goes wrong
                Log.e("SignUpError", "Exception during sign-up: ${e.message}")
                _signUpUiState.value = SignUpUiState(errorMessage = e.message)
            }
        }
    }
}
