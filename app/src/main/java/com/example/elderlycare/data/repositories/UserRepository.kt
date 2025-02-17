package com.example.elderlycare.data.repositories

import com.example.elderlycare.data.network.ApiService
import com.example.elderlycare.data.network.LoginRequest
import com.example.elderlycare.data.network.LoginResponse
import com.example.elderlycare.data.network.SignUpRequest
import com.example.elderlycare.data.network.SignUpResponse
import retrofit2.Response

class UserRepository(private val apiService: ApiService) {

    // Function to create a new user using the API with error handling
    suspend fun signUp(name: String, email: String, password: String): Response<SignUpResponse> {
        val signUpRequest = SignUpRequest(name, email, password)
        return apiService.signUp(signUpRequest)
    }   

    // Function to login a user
    suspend fun login(email: String, password: String): Response<LoginResponse> {
        val loginRequest = LoginRequest(email, password)
        return try {
            // Call the API to authenticate the user
            val response = apiService.login(loginRequest)

            // Handle successful response
            if (response.isSuccessful) {
                response
            } else {
                // Return error response in case of failure
                Response.error(response.code(), response.errorBody() ?: throw Exception("Login failed"))
            }
        } catch (exception: Exception) {
            throw Exception("Login failed: ${exception.message}")
        }
    }
}
