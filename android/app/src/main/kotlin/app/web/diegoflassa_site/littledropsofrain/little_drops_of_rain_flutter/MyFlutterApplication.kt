package app.web.diegoflassa_site.littledropsofrain.little_drops_of_rain_flutter

import android.util.Log
import com.google.firebase.FirebaseApp
import com.google.firebase.appcheck.FirebaseAppCheck
import com.google.firebase.appcheck.safetynet.SafetyNetAppCheckProviderFactory
import com.google.firebase.crashlytics.FirebaseCrashlytics
import io.flutter.app.FlutterApplication
import java.lang.Thread.getDefaultUncaughtExceptionHandler

class MyFlutterApplication : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        FirebaseApp.initializeApp(this)
        val firebaseAppCheck = FirebaseAppCheck.getInstance()
        firebaseAppCheck.installAppCheckProviderFactory(
            SafetyNetAppCheckProviderFactory.getInstance())
    }

    private val defaultUEH: Thread.UncaughtExceptionHandler? = getDefaultUncaughtExceptionHandler()
    private val _unCaughtExceptionHandler =
        Thread.UncaughtExceptionHandler { thread, ex ->
            // here I do logging of exception to a db
            Log.e("[MyApp]", "Uncaught exception:$ex")
            // Do what you want.
            FirebaseCrashlytics.getInstance().recordException(ex)
            // re-throw exception to O.S. if that is serious and need to be handled by o.s. Uncomment the next line that time.
            defaultUEH?.uncaughtException(thread, ex)
        }

    init {
        Thread.setDefaultUncaughtExceptionHandler(_unCaughtExceptionHandler)
    }
}