package io.yahrtzeits.ui.manage

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.kosherjava.zmanim.hebrewcalendar.JewishDate
import io.yahrtzeits.R
import io.yahrtzeits.api.YahrtzeitsManager
import io.yahrtzeits.databinding.FragmentManageYahrtzeitsBinding
import io.yahrtzeits.types.Yahrtzeit
import io.yahrtzeits.ui.home.UpcomingYahrtzeitsAdapter
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class ManageYahrtzeitsFragment : Fragment() {
    private var _binding: FragmentManageYahrtzeitsBinding? = null
    private var listView : RecyclerView? = null
    private val scope = CoroutineScope(Dispatchers.IO)
    private val binding get() = _binding!!
    private val adapter = ManageYahrtzeitsAdapter()

    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View {
        _binding = FragmentManageYahrtzeitsBinding.inflate(inflater, container, false)
        val root: View = binding.root
        listView = root.findViewById<RecyclerView>(R.id.manage_yahrtzeits).also { view ->
            view.setHasFixedSize(true)
            view.layoutManager = LinearLayoutManager(view.context);
            view.adapter = adapter
        }
        scope.launch {
            val manager = YahrtzeitsManager.getInstance(root.context)
            var yahrtzeits = manager.getAllYahrtzeits()
            //Temporary:
            if(yahrtzeits.isEmpty()) {
                yahrtzeits = listOf(
                    Yahrtzeit("David Norkin", "דוד בן אברהם", 1, JewishDate.SHEVAT),
                    Yahrtzeit("Lita Norkin", "זלאטע בת משה הלוי", 2, JewishDate.SHEVAT)
                )
            }
            adapter.setYahrtzeits(yahrtzeits)
        }
        return root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}