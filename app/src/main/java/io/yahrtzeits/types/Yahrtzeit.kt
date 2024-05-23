package io.yahrtzeits.types

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * [Yahrtzeit]
 *
 * Class that is used to store basic information about a yahrtzeit (Jewish anniversary of death).
 */
@Entity
data class Yahrtzeit(
    @ColumnInfo val englishName : String,
    @ColumnInfo val hebrewName: String,
    @ColumnInfo val day : Int,
    @ColumnInfo val month : Int,
    @PrimaryKey(autoGenerate = true) val id : Long? = null
)
