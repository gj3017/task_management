import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../theme.dart';
import '../widgets/button.dart';
import '../widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.find<TaskController>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _startTime = "8:30 AM";
  String _endTime = "9:30 AM";
  int _selectedRemind = 5;
  int _selectedColor = 0;
  List<int> remindList = [
    5,
    10,
    15,
    20,
  ];

  String _selectedRepeat = 'None';
  List<String> repeatList = [
    'None',
    'Daily',
    'Weekly',
    'Monthly',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _appBar(),
        body: Container(
            child: SingleChildScrollView(
                child: Column(
          children: [
            Text(
              "Add Task",
              style: headingTextStyle,
            ),
            const SizedBox(
              height: 8,
            ),
            InputField(
              title: "Title",
              hint: "Enter title here.",
              controller: _titleController,
            ),
            InputField(
                title: "Note",
                hint: "Enter note here.",
                controller: _noteController),
            InputField(
              title: "Date",
              hint: DateFormat.yMd().format(_selectedDate),
              widget: IconButton(
                icon: (const Icon(
                  FontAwesomeIcons.calendar,
                  color: Colors.grey,
                )),
                onPressed: () {
                  //_showDatePicker(context);
                  _getDateFromUser();
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    title: "Start Time",
                    hint: _startTime,
                    widget: IconButton(
                      icon: (const Icon(
                        FontAwesomeIcons.clock,
                        color: Colors.grey,
                      )),
                      onPressed: () {
                        _getTimeFromUser(isStartTime: true);
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: InputField(
                    title: "End Time",
                    hint: _endTime,
                    widget: IconButton(
                      icon: (const Icon(
                        FontAwesomeIcons.clock,
                        color: Colors.grey,
                      )),
                      onPressed: () {
                        _getTimeFromUser(isStartTime: false);
                      },
                    ),
                  ),
                )
              ],
            ),
            InputField(
              title: "Remind",
              hint: "$_selectedRemind minutes early",
              widget: Row(
                children: [
                  DropdownButton<String>(
                      //value: _selectedRemind.toString(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      iconSize: 32,
                      elevation: 4,
                      style: subTitleTextStle,
                      underline: Container(height: 0),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRemind = int.parse(newValue!);
                        });
                      },
                      items:
                          remindList.map<DropdownMenuItem<String>>((int value) {
                        return DropdownMenuItem<String>(
                          value: value.toString(),
                          child: Text(value.toString()),
                        );
                      }).toList()),
                  const SizedBox(width: 6),
                ],
              ),
            ),
            InputField(
              title: "Repeat",
              hint: _selectedRepeat,
              widget: Row(
                children: [
                  DropdownButton<String>(
                      //value: _selectedRemind.toString(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      iconSize: 32,
                      elevation: 4,
                      style: subTitleTextStle,
                      underline: Container(height: 0),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRepeat = newValue!;
                        });
                      },
                      items: repeatList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList()),
                  const SizedBox(width: 6),
                ],
              ),
            ),
            const SizedBox(
              height: 18.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _colorChips(),
                MyButton(
                  label: "Create Task",
                  onTap: () {
                    _validateInputs();
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 30.0,
            ),
          ],
        ))));
  }

  _validateInputs() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTaskToDB();
      Get.back();
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar(
        "Required",
        "All fields are required.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      print("############ SOMETHING BAD HAPPENED #################");
    }
  }

  _addTaskToDB() async {
    await _taskController.addTask(
      task: Task(
        note: _noteController.text,
        title: _titleController.text,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: _startTime,
        endTime: _endTime,
        remind: _selectedRemind,
        repeat: _selectedRepeat,
        color: _selectedColor,
        isCompleted: 0,
      ),
    );
  }

  _colorChips() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Color",
        style: titleTextStle,
      ),
      const SizedBox(
        height: 8,
      ),
      Wrap(
        children: List<Widget>.generate(
          3,
          (int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: index == 0
                      ? primaryClr
                      : index == 1
                          ? pinkClr
                          : yellowClr,
                  child: index == _selectedColor
                      ? const Center(
                          child: Icon(
                            Icons.done,
                            color: Colors.white,
                            size: 18,
                          ),
                        )
                      : Container(),
                ),
              ),
            );
          },
        ).toList(),
      ),
    ]);
  }

  _appBar() {
    return AppBar(
        elevation: 0,
        backgroundColor: context.theme.backgroundColor,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(Icons.arrow_back_ios, size: 24, color: primaryClr),
        ),
        actions: const [
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage("images/girl.jpg"),
          ),
          SizedBox(
            width: 20,
          ),
        ]);
  }

  _getDateFromUser() async {
    final DateTime? _pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (_pickedDate != null) {
      setState(() {
        _selectedDate = _pickedDate;
      });
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    var _pickedTime = await _showTimePicker();
    print(_pickedTime.format(context));
    String _formatedTime = _pickedTime.format(context);
    print(_formatedTime);
    if (_pickedTime == null) {
      print("time canceld");
    } else if (isStartTime) {
      setState(() {
        _startTime = _formatedTime;
      });
    } else if (!isStartTime) {
      setState(() {
        _endTime = _formatedTime;
      });
      //_compareTime();
    }
  }

  _showTimePicker() async {
    return showTimePicker(
      initialTime: const TimeOfDay(hour: 8, minute: 30),
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
    );
  }
}
