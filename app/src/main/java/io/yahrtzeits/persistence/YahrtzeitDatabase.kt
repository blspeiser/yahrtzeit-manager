package io.yahrtzeits.persistence

import androidx.room.Database
import androidx.room.RoomDatabase
import io.yahrtzeits.types.Yahrtzeit

/**
 * [YahrtzeitDatabase]
 *
 * Android Room factory to store yahrtzeit information.
 */
@Database(entities = [Yahrtzeit::class], version = 1, exportSchema = false)
abstract class YahrtzeitDatabase : RoomDatabase() {
    abstract fun yahrtzeitRepository() : YahrtzeitRepository
}