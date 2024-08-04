import 'package:flutter/material.dart';
import '../localizations/app_localizations.dart';
import '../models/yahrtzeit.dart';
import '../services/yahrtzeits_manager.dart';
import 'add_yahrtzeit.dart';

class ManageYahrtzeits extends StatefulWidget {
  @override
  _ManageYahrtzeitsState createState() => _ManageYahrtzeitsState();
}

class _ManageYahrtzeitsState extends State<ManageYahrtzeits> {
  final YahrtzeitsManager manager = YahrtzeitsManager();
  List<Yahrtzeit> yahrtzeits = [];
  bool isLoading = true; // משתנה לבדוק אם הדאטה בטעינה
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    fetchYahrtzeits();
  }

  Future<void> fetchYahrtzeits() async {
    try {
      final fetchedYahrtzeits = await manager.getAllYahrtzeits();
      setState(() {
        yahrtzeits = fetchedYahrtzeits;
        isLoading = false; // הגדרת המשתנה ל-false לאחר שהדאטה התקבלה
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (var i = 0; i < yahrtzeits.length; i++) {
          if (_listKey.currentState != null && i < yahrtzeits.length) {
            _listKey.currentState?.insertItem(i);
          }
        }
      });
    } catch (e) {
      print('Error fetching yahrtzeits: $e');
      setState(() {
        isLoading = false; // הגדרת המשתנה ל-false גם במקרה של שגיאה
      });
    }
  }

  void _editYahrtzeit(Yahrtzeit yahrtzeit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddYahrtzeitPage(
          yahrtzeit: yahrtzeit,
          isEditing: true,
        ),
      ),
    );
    if (result != null && result is Yahrtzeit) {
      await manager.deleteYahrtzeit(yahrtzeit); // מחיקת הישן
      await manager.addYahrtzeit(result); // הוספת החדש
      fetchYahrtzeits();
    }
  }

  void _deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(AppLocalizations.of(context)!.translate('confirm_deletion')),
        content: Text(
            AppLocalizations.of(context)!.translate('delete_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.translate('delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final index = yahrtzeits.indexOf(yahrtzeit);
        if (index >= 0 && index < yahrtzeits.length) {
          setState(() {
            yahrtzeits.removeAt(index);
            _listKey.currentState?.removeItem(index, (context, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: _buildYahrtzeitTile(yahrtzeit),
              );
            }, duration: Duration(milliseconds: 300));
          });
          await manager.deleteYahrtzeit(yahrtzeit);
        }
      } catch (e) {
        print('Error deleting yahrtzeit: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.translate('deletion_failed')),
          ),
        );
      }
    }
  }

  Widget _buildYahrtzeitTile(Yahrtzeit yahrtzeit) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  yahrtzeit.englishName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  yahrtzeit.hebrewName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.deepPurple),
              onPressed: () => _editYahrtzeit(yahrtzeit),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteYahrtzeit(yahrtzeit),
            ),
          ],
        ),
      ),
    );
  }

  // void _deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
  //   await manager.deleteYahrtzeit(yahrtzeit);
  //   fetchYahrtzeits();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('manage_yahrzeits'),
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 50, 4, 129),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddYahrtzeitPage()),
              ).then((result) {
                if (result == true) {
                  fetchYahrtzeits();
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: isLoading // בדיקה אם הדאטה עדיין בטעינה
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              )
            : yahrtzeits.isEmpty // בדיקה אם הרשימה ריקה
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('you_have_not_added_any_yahrtzeits_yet.'),
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : AnimatedList(
                    key: _listKey,
                    initialItemCount: yahrtzeits.length,
                    itemBuilder: (context, index, animation) {
                      if (index >= yahrtzeits.length) {
                        return SizedBox.shrink();
                      }
                      return FadeTransition(
                        opacity: animation,
                        child: _buildYahrtzeitTile(yahrtzeits[index]),
                      );
                    },
                  ),
      ),
    );
  }
}
