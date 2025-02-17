package com.example.elderlycare.data.network

import com.google.gson.annotations.SerializedName
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.POST

import retrofit2.http.GET
import retrofit2.http.PUT
import retrofit2.http.Path
import retrofit2.http.Query

// Request model for login
data class LoginRequest(
    val email: String,
    val password: String
)

data class PredictionResponse(
    val description: String,
    val medications: List<String>,
    val precautions: String,
    val predicted_disease: String,
    val recommended_diet: List<String>,
    val workout: List<String>
)


// Response model for login (adjust to match your backend response)
data class LoginResponse(
    val accestoken: String,  // JWT token returned from the server
    val refreshToken: String,  // Refresh token returned from the server
    val userId: String,
    val isFirstLogin : Boolean
)

data class SignUpRequest(
    val name : String,
    val email: String,
    val password: String
)

data class SignUpResponse(
    val success: Boolean,
    val message: String
)

data class ForgotPasswordRequest(val email: String)
data class ForgotPasswordResponse(
    val message: String,
    val resetToken: String
)
data class VerifyCodeRequest(val email: String ,val code: String)

data class VerifyCodeResponse(val message: String)

data class ResetPasswordRequest(
    val verifiedToken: String,
    val newPassword: String
)
data class SymptomsRequest(val symptoms: List<String>)

//tracking









//goals


data class AddGoalDto(
    val steps: Int,
    val water: Int,
    val sleepHours: Int,
    val coffeeCups: Int,
    val workout: Int
)
data class UpdateProgressRequest(
    val date: String,  // Format: "YYYY-MM-DD"
    val steps: Int?,
    val water: Int?,
    val sleepHours: Int?,
    val coffeeCups: Int?,
    val workout: Int?,
    val notes: String = ""  // Optional, defaults to empty string
)
data class VerifyResetCodeRequest(
    val resetToken: String,
    val code: String
)


data class UpdateGoalDto(
    val steps: Int? = null,
    val water: Int? = null,
    val sleepHours: Int? = null,
    val coffeeCups: Int? = null,
    val workout: Int? = null
)

data class GoalResponse(
    @SerializedName("_id")
    val id: String?, // Currently nullable, but we need to ensure it has a value
    val userId: String,
    val steps: Int,
    val water: Int,
    val sleepHours: Int,
    val coffeeCups: Int,
    val workout: Int
)
data class ProgressResponse(
    @SerializedName("_id")
    val id: String,
    val userId: String,
    val goalId: String,
    val date: String,
    val steps: Int?,
    val water: Int?,
    val sleepHours: Int?,
    val coffeeCups: Int?,
    val workout: Int?,
    val notes: String?
)
data class VerifyResetCodeResponse(
    val message: String,
    val verifiedToken: String
)
data class ResetPasswordResponse(
    val message: String
)



interface ApiService {
    @POST("auth/signup") // Ensure this matches your backend route
    suspend fun signUp(@Body signupRequest: SignUpRequest): Response<SignUpResponse>
    // Login API
    @POST("auth/login")  // Adjust to match your login endpoint in the backend
    suspend fun login(@Body loginRequest: LoginRequest): Response<LoginResponse>

    @POST("auth/forgot-password")
    suspend fun requestPasswordReset(@Body request: ForgotPasswordRequest): ForgotPasswordResponse

    @POST("auth/verify-reset-code")
    suspend fun verifyResetCode(@Body request: VerifyResetCodeRequest): VerifyResetCodeResponse

    @POST("auth/reset-password")
    suspend fun resetPassword(@Body request: ResetPasswordRequest): ResetPasswordResponse

    @POST("prediction/symptoms")
    suspend fun getPrediction(@Body request: SymptomsRequest): Response<PredictionResponse>

    @POST("goals/user/{userId}")
    suspend fun createGoal( @Path("userId") userId: String, @Body goal: AddGoalDto): Response<GoalResponse>

    //suspend fun addGoal(@Path("userId") userId: String, @Body request: AddGoalRequest): Response<Void>

    //@PUT("goals/{userId}/{goalId}")
   // suspend fun updateGoal(@Path("userId") userId: String, @Path("goalId") goalId: String, @Body request: UpdateGoalRequest): Response<Void>
    @PUT("goals/{goalId}")
    suspend fun updateGoal(
        @Path("goalId") goalId: String,
        @Body goal: UpdateGoalDto
    ): Response<GoalResponse>


    //@GET("goals/{userId}")
    //suspend fun getGoals(@Path("userId") userId: String): Response<List<GoalResponse>>
    @GET("goals/user/{userId}")
    suspend fun getUserGoals(
        @Path("userId") userId: String
    ): Response<List<GoalResponse>>



    @GET("goals/{goalId}/progress/today")
    suspend fun getTodayProgress(
        @Path("goalId") goalId: String
    ): Response<ProgressResponse>

    @GET("goals/{goalId}/progress")
    suspend fun getGoalProgress(
        @Path("goalId") goalId: String,
        @Query("startDate") startDate: String? = null,
        @Query("endDate") endDate: String? = null
    ): Response<List<ProgressResponse>>

    @POST("goals/{goalId}/progress")
    suspend fun updateProgress(
        @Path("goalId") goalId: String,
        @Body progressRequest: UpdateProgressRequest
    ): Response<ProgressResponse>

/*

        suspend fun updateProgress(userId: String, goalId: String, request: CreateTrackingRequest): TrackingResponse
        suspend fun getProgress(userId: String, goalId: String, days: Int): List<TrackingResponse>
        suspend fun getGoalComparison(userId: String, goalId: String): GoalComparisonResponse
*/
}

