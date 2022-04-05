import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_management/pages/add_task_page.dart';
import 'package:task_management/services/notification_services.dart';
import 'package:task_management/size_config.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../services/theme_services.dart';
import '../theme.dart';
import '../widgets/button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.parse(DateTime.now().toString());
  final _taskController = Get.put(TaskController());
  late NotifyHelper notifyHelper;
  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: _appBar(),
        body: Column(
          children: [
            _addTaskBar(),
            _dateBar(),
            _showTasks(),
          ],
        ));
  }

  _appBar() {
    return AppBar(
        elevation: 0,
        backgroundColor: context.theme.backgroundColor,
        leading: GestureDetector(
          onTap: () {
            ThemeService().switchTheme();
            notifyHelper.displayNotification(
              title: "Theme Changed",
              body: Get.isDarkMode
                  ? "Light theme activated."
                  : "Dark theme activated",
            );

            //notifyHelper.scheduledNotification();
            //notifyHelper.periodicalyNotification();
          },
          child: Icon(
              Get.isDarkMode ? FontAwesomeIcons.sun : FontAwesomeIcons.moon,
              color: Get.isDarkMode ? Colors.white : darkGreyClr),
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

  _addTaskBar() {
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  style: subHeadingTextStyle,
                ),
                Text(
                  "Today",
                  style: headingTextStyle,
                ),
              ],
            ),
            MyButton(
              label: "+ Add Task",
              onTap: () async {
                await Get.to(() => const AddTaskPage());
                _taskController.getTasks();
              },
            ),
          ],
        ));
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        // _taskController.getTasks();
        if (_taskController.taskList.isEmpty) {
          return _noTaskMsg();
        } else {
          return ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _taskController.taskList.length,
              itemBuilder: (context, index) {
                Task task = _taskController.taskList[index];
                if (task.repeat == 'Daily') {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  showBottomSheet(context, task);
                                },
                                child: TaskTile(task)),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                if (task.date == DateFormat.yMd().format(_selectedDate)) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  showBottomSheet(context, task);
                                },
                                child: TaskTile(task)),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              });
        }
      }),
    );
  }

  _dateBar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      child: DatePicker(
        DateTime.now(),
        //height: 100.0,
        initialSelectedDate: DateTime.now(),
        selectionColor: context.theme.backgroundColor,
        selectedTextColor: primaryClr,
        dateTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 10.0,
            color: Colors.grey,
          ),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 10.0,
            color: Colors.grey,
          ),
        ),
        // deactivatedColor: Colors.white,

        onDateChange: (date) {
          // New date selected
          setState(
            () {
              _selectedDate = date;
            },
          );
        },
      ),
    );
  }

  showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height: task.isCompleted == 1
            ? SizeConfig.screenHeight * 0.24
            : SizeConfig.screenHeight * 0.32,
        width: SizeConfig.screenWidth,
        color: Get.isDarkMode ? darkHeaderClr : Colors.white,
        child: Column(children: [
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
          ),
          const Spacer(),
          task.isCompleted == 1
              ? Container()
              : _buildBottomSheetButton(
                  label: "Task Completed",
                  onTap: () {
                    _taskController.markTaskCompleted(task.id!);
                    Get.back();
                  },
                  clr: primaryClr),
          _buildBottomSheetButton(
              label: "Delete Task",
              onTap: () {
                _taskController.deleteTask(task);
                Get.back();
              },
              clr: Colors.red[300]!),
          const SizedBox(
            height: 20,
          ),
          _buildBottomSheetButton(
              label: "Close",
              onTap: () {
                Get.back();
              },
              isClose: true),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }

  _buildBottomSheetButton(
      {String? label,
      Function()? onTap,
      Color clr = Colors.grey,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose
                ? Get.isDarkMode
                    ? const Color(0xFF757575)
                    : const Color(0xFFE0E0E0)
                : clr,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
            child: Text(
          label!,
          style: isClose
              ? titleTextStle
              : titleTextStle.copyWith(color: Colors.white),
        )),
      ),
    );
  }

  _noTaskMsg() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "images/task.svg",
          color: primaryClr.withOpacity(0.5),
          height: 90,
          semanticsLabel: 'Task',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Text(
            "You do not have any tasks yet!\nAdd new tasks to make your days productive.",
            textAlign: TextAlign.center,
            style: subTitleTextStle,
          ),
        ),
        const SizedBox(
          height: 80,
        ),
      ],
    );
  }
}
