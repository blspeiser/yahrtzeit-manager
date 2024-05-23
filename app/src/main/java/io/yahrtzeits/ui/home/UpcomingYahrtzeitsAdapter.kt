package io.yahrtzeits.ui.home

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import io.yahrtzeits.R
import io.yahrtzeits.types.YahrtzeitDate
import io.yahrtzeits.utils.DateUtil
import java.util.Locale

class UpcomingYahrtzeitsAdapter()
: RecyclerView.Adapter<UpcomingYahrtzeitsAdapter.ViewHolder>()
{
    private val yahrtzeitDates: ArrayList<YahrtzeitDate> = ArrayList()

    fun setYahrtzeitDates(dates: List<YahrtzeitDate>) {
        this.yahrtzeitDates.clear()
        this.yahrtzeitDates.addAll(dates)
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
        with(yahrtzeitDates[position]) {
            viewHolder.englishName.text = yahrtzeit.englishName
            viewHolder.hebrewName.text  = yahrtzeit.hebrewName
            viewHolder.hebrewDate.text  = DateUtil.format(hebrewDate)
            viewHolder.englishDate.text = DateUtil.format(gregorianDate, Locale.getDefault())
        }
    }

    override fun getItemCount() = yahrtzeitDates.size

    override fun getItemViewType(position: Int): Int {
        return R.layout.yahrtzeit_date
    }
}