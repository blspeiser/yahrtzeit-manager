package io.yahrtzeits

import android.app.Application
import com.kosherjava.zmanim.hebrewcalendar.JewishDate
import io.yahrtzeits.api.YahrtzeitsManager
import io.yahrtzeits.types.Yahrtzeit

/**
 * [YahrtzeitsApplication]
 *
 * Application class to provide itself as a context to relevant services.
 */
class YahrtzeitsApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        //set some data on startup for testing
        val manager = YahrtzeitsManager.getInstance(this)
        if(manager.getAllYahrtzeits().isEmpty()) {
        }
    }
}