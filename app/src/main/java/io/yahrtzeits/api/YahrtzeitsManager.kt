package io.yahrtzeits.api

import android.content.Context
import androidx.room.Room
import com.kosherjava.zmanim.hebrewcalendar.JewishDate
import io.yahrtzeits.persistence.YahrtzeitDatabase
import io.yahrtzeits.types.Yahrtzeit
import io.yahrtzeits.types.YahrtzeitDate
import java.time.LocalDate
import java.util.Calendar

/**
 * [YahrtzeitsManager]
 *
 * Service for processing yahrtzeit dates.
 */
class YahrtzeitsManager private constructor(context : Context) {
    companion object {
        private const val DATABASE_NAME = "yahrtzeits"
        //Classic Kotlin singleton pattern:
        @Volatile private var instance: YahrtzeitsManager? = null
        fun getInstance(ctx : Context) = instance ?: synchronized(this) {
            instance ?: YahrtzeitsManager(ctx).also { instance = it }
        }
    }

    private val database = Room.databaseBuilder(
        context,
        YahrtzeitDatabase::class.java,
        DATABASE_NAME
    ).build()
    private val repository = database.yahrtzeitRepository()

    /**
     * Determine the next [YahrtzeitDate] for a given [Yahrtzeit].
     */
    fun next(yahrtzeit: Yahrtzeit) : YahrtzeitDate {
        val today = JewishDate()
        val upcoming = JewishDate(LocalDate.now())
        upcoming.jewishDayOfMonth = yahrtzeit.day
        setMonth(yahrtzeit, upcoming)
        if (today.compareTo(upcoming) > 0) advanceYear(yahrtzeit, upcoming)
        return YahrtzeitDate(yahrtzeit, upcoming.localDate, upcoming)
    }

    /**
     * Determine the next [YahrtzeitDate]s for a given set of [Yahrtzeit]s.
     */
    fun next(yahrtzeits: List<Yahrtzeit>) : List<YahrtzeitDate> {
        return yahrtzeits.map { next(it) }.sortedBy { it.gregorianDate }
    }

    fun getAllYahrtzeits() = repository.fetchAll()

    fun add(yahrtzeit : Yahrtzeit) = repository.add(yahrtzeit)

    fun remove(yahrtzeit: Yahrtzeit) = repository.remove(yahrtzeit)

    private fun advanceYear(yahrtzeit: Yahrtzeit, date: JewishDate) {
        if (date.jewishMonth == JewishDate.ADAR_II) {
            //Need to set it back to "plain" Adar, because it treats Adar Bet as the extra month (instead of Adar Aleph being extra)
            date.jewishMonth = JewishDate.ADAR
        }
        date.forward(Calendar.YEAR, 1)
        //now set the month correctly for this new year:
        setMonth(yahrtzeit, date)
    }

    private fun setMonth(yahrtzeit: Yahrtzeit, date: JewishDate) {
        if (yahrtzeit.month == JewishDate.ADAR_II) {
            // Special handling for years that Adar Bet doesn't exist:
            date.jewishMonth = if (date.isJewishLeapYear) JewishDate.ADAR_II else JewishDate.ADAR
        } else {
            date.jewishMonth = yahrtzeit.month
        }
    }



}


