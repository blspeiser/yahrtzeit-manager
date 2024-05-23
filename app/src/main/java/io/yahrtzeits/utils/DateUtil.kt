package io.yahrtzeits.utils

import com.kosherjava.zmanim.hebrewcalendar.HebrewDateFormatter
import com.kosherjava.zmanim.hebrewcalendar.JewishDate
import java.text.DateFormat
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.util.Locale

/**
 * [DateUtil]
 *
 * Class for various date-related utility methods.
 */
object DateUtil {

    fun format(date: LocalDate): String? {
        val dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd")
        return date.format(dtf)
    }

    fun format(date: LocalDate, locale : Locale): String? {
        val dtf = DateTimeFormatter.ofLocalizedDate(FormatStyle.LONG).withLocale(Locale.getDefault())
        return date.format(dtf)
    }

    fun format(date: JewishDate): String? {
        val hdf = HebrewDateFormatter()
        hdf.isHebrewFormat = true
        return hdf.format(date)
    }
}