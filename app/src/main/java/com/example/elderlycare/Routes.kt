package com.example.elderlycare

sealed class Routes(val route: String){

    object Home :     Routes("home")
    object AIscreen : Routes("AIscreen")
    object Favorite : Routes("Favorite")
    object HealthReminder : Routes("HealthReminder")
    object Screen1 : Routes("Screen1")
    object LunchScreen : Routes("LunchScreen")
    object Login : Routes("Login")
    object SignUp : Routes("SignUp")
    object ForgetPassword : Routes("ForgetPassword")
    object ConfirmCode : Routes("ConfirmCode")
    object ResetPass : Routes("ResetPassword")
    object PredictionScreen : Routes("PredictionScreen")
    object GoalSettingScreen: Routes("GoalSettingScreen")
    object ShowGoalsScreen: Routes("ShowGoalsScreen")
    object ProgressScreen: Routes("ProgressScreen")

    object GoalReminder: Routes("GoalReminder")








}