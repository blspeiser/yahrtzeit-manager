package io.yahrtzeits.ui.manage

import android.icu.text.DateFormat.BooleanAttribute
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.kosherjava.zmanim.hebrewcalendar.HebrewDateFormatter
import com.kosherjava.zmanim.hebrewcalendar.JewishDate
import io.yahrtzeits.R
import io.yahrtzeits.types.Yahrtzeit
import io.yahrtzeits.types.YahrtzeitDate
import io.yahrtzeits.utils.DateUtil
import java.util.Locale

class ManageYahrtzeitsAdapter()
: RecyclerView.Adapter<ManageYahrtzeitsAdapter.ViewHolder>()
{
    private val yahrtzeits: ArrayList<Yahrtzeit> = ArrayList()

    fun setYahrtzeits(list: List<Yahrtzeit>) {
        this.yahrtzeits.clear()
        this.yahrtzeits.addAll(list)
        this.notifyDataSetChanged()
    }

    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val englishName : TextView
        val hebrewName : TextView
        val hebrewDate : TextView
        val englishDate : TextView

        init {
            englishName = view.findViewById(R.id.englishName)
            hebrewName  = view.findViewById(R.id.hebrewName)
            hebrewDate  = view.findViewById(R.id.hebrewDate)
            englishDate = view.findViewById(R.id.englishDate)
        }
    }

    override fun onCreateViewHolder(viewGroup: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(viewGroup.context)
            .inflate(R.layout.yahrtzeit_date, viewGroup, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(viewHolder: ViewHolder, position: Int) {
        with(yahrtzeits[position]) {
            viewHolder.englishName.text = englishName
            viewHolder.hebrewName.text  = hebrewName
            viewHolder.hebrewDate.text  = toDateString(this, true)
            viewHolder.englishDate.text = toDateString(this, false)
        }
    }

    private fun toDateString(yahrtzeit: Yahrtzeit, inHebrew: Boolean): CharSequence? {
        val d = JewishDate()
        d.jewishDayOfMonth = yahrtzeit.day
        d.jewishMonth = yahrtzeit.month
        val hdf = HebrewDateFormatter()
        hdf.isHebrewFormat = inHebrew
        return if(inHebrew) "${hdf.formatHebrewNumber(yahrtzeit.day)} ${hdf.formatMonth(d)}"
               else         "${yahrtzeit.day} ${hdf.formatMonth(d)}"
    }

    override fun getItemCount() = yahrtzeits.size

    override fun getItemViewType(position: Int): Int {
        return R.layout.yahrtzeit_date
    }
}