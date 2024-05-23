package io.yahrtzeits.persistence

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update
import io.yahrtzeits.types.Yahrtzeit

/**
 * [YahrtzeitRepository]
 *
 * Android Room repository implementation.
 */
@Dao
abstract class YahrtzeitRepository {

    @Insert
    abstract fun add(yahrtzeit: Yahrtzeit)

    @Query("SELECT * FROM Yahrtzeit")
    abstract fun fetchAll() : List<Yahrtzeit>

    @Update
    abstract fun update(yahrtzeit: Yahrtzeit)

    @Delete
    abstract fun remove(yahrtzeit: Yahrtzeit)

}
