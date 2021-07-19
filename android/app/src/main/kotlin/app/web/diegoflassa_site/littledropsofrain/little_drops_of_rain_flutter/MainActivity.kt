package app.web.diegoflassa_site.littledropsofrain.little_drops_of_rain_flutter

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    companion object {
        val TAG = MainActivity::class.simpleName
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i(TAG, "${TAG}.onCreate")
    }
}
