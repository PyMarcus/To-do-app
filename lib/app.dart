import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  List<dynamic> tasks = [];
  Map<String, dynamic> _lastRemoved = Map();
  final TextEditingController _inputController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async{
    final fileContent = await _getFile();
    if (fileContent.isNotEmpty) {
      setState(() {
        tasks = jsonDecode(fileContent);
      });
    }
  }

  Future<File> _getFilePath()async{
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  void _saveFile() async{
    String task = _inputController.text;
    if (task.isNotEmpty){
      Map<String, dynamic> taskSchema = {};
      taskSchema["title"] = task;
      taskSchema["status"] = false;

      setState(() {
        tasks.add(taskSchema);
      });
    }

    _inputController.text = "";
    File file = await _getFilePath();
    String data = json.encode(tasks);
    file.writeAsString(data);
  }

  Future<String> _getFile() async{
    try{
      File file = await _getFilePath();
      return file.readAsString();
    }catch(e){
      print("Failed");
      return "";
    }
  }

  Future<void> _addTask()async{
    return showDialog(
      context: context,
      builder: (context){
        return  AlertDialog(
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(onPressed: (){
              Navigator.pop(context);
              _saveFile();
            }, child: const Text("Add")),
          ],
          title: const Text("Add task"),
          content: TextField(
            controller: _inputController,
            decoration: const InputDecoration(
              labelText: "Write your task",
            ),
          ),
        );
      }
    );
  }

  Widget _itemList(BuildContext context, int index){
    String taskName = tasks[index]["title"];
    return Dismissible(
      onDismissed: (direction){
        if(direction == DismissDirection.endToStart){
          setState(() {
            _lastRemoved = tasks[index];
            tasks.removeAt(index);
          });
          final snackBar =  SnackBar(
            duration:const Duration(seconds: 5),
            action: SnackBarAction(label: "Undo", onPressed: (){
             setState(() {
               tasks.insert(index, _lastRemoved);
             });
            }),
            content: const Text("Are u sure ?", style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.purpleAccent,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          _saveFile();
        }
      },
      direction: DismissDirection.endToStart,
        background: Container(
          padding: EdgeInsets.all(16),
          color: Colors.red,
          child:const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
               Icon(Icons.delete, color: Colors.white,)
            ],
          )
          ,
        ),
        key: Key(taskName),
        child:CheckboxListTile(
          title: Text(taskName, style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold)
            ,),
          value: tasks[index]["status"],
          onChanged: (changedValue){
            setState(() {
              tasks[index]["status"] = changedValue;
            });

            _saveFile();
          },
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        title: const Text("To-do List",style: TextStyle(
            color: Colors.white,fontWeight: FontWeight.bold),),
      ),

      body: Column(
        children: [
          Expanded(child:
            ListView.separated(
                separatorBuilder: (context, index) => Divider(height: 2, color: Colors.purpleAccent,),
                itemCount: tasks.length,
                itemBuilder: (context, index){
                  /*
                  return ListTile(
                    title: Text(tasks[index]["title"], style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold)
                      ,),);*/
                  return _itemList(context, index);

                }
            )
          )
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        shape: const CircleBorder(),
        foregroundColor: Colors.white,
        elevation: 10,
        onPressed: _addTask,
        child: const Icon(Icons.add, color: Colors.white,),
      ),

      bottomNavigationBar:const BottomAppBar(
        color: Colors.deepPurpleAccent,
        shape: CircularNotchedRectangle(),
      ),
    );
  }
}
