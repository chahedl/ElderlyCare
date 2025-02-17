package com.example.elderlycare.data.network

import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object RetrofitClient {
    private const val BASE_URL = "http://192.168.1.251:3000/"

    private val retrofit by lazy {
        // Create logging interceptor
        val logging = HttpLoggingInterceptor().apply {
            // Set level to BODY to see full request and response details
            level = HttpLoggingInterceptor.Level.BODY
        }

        // Add logging interceptor to OkHttpClient
        val client = OkHttpClient.Builder()
            .addInterceptor(logging)
            .build()

        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

    fun getApiService(): ApiService {
        return retrofit.create(ApiService::class.java)
    }
}