package io.yahrtzeits.types

import com.kosherjava.zmanim.hebrewcalendar.JewishDate
import java.time.LocalDate

data class YahrtzeitDate(
    val yahrtzeit: Yahrtzeit,
    val gregorianDate : LocalDate,
    val hebrewDate : JewishDate
)