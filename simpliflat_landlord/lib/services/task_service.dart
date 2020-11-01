import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class TaskService {
  static DateTime getNextDueDateTime(
      DateTime due, int repeat, String frequency) {
    DateTime now = DateTime.now();
    int nowTime = now.hour * 60 + now.minute;
    int dueTime = due.hour * 60 + due.minute;
    DateTime dueToday = DateTime(now.year, now.month, now.day, due.hour, due.minute);
    List<int> frequencies = frequency == null || frequency == ''?List():frequency.split(',').map(int.parse).toSet().toList();
    frequencies.sort();
    switch (repeat) {
      case -1:  //once
        {
          return due;
        }
      case 0: //daily
        {


          if (nowTime > dueTime) {
            dueToday = dueToday.add(Duration(days: 1));
          }

          return dueToday;
        }
      case 1: //always available
        {
          return now.add(new Duration(minutes: 1));
        }
      case 2: //weekly
        {
          if (nowTime > dueTime) {
            return dueToday.add(new Duration(days: 7));
          }

          return dueToday;
        }
      case 3: //weekly on particular days
        {
          int taskDay = -1;
          for (int i = 0; i < frequencies.length; i++) {
            if ((frequencies[i] == now.weekday && nowTime < dueTime) ||
                frequencies[i] > now.weekday) {
              taskDay = frequencies[i];
              break;
            }
          }

          if (taskDay == -1) {
            taskDay = frequencies[0];
          }


          while (dueToday.weekday != taskDay) {
            dueToday = dueToday.add(new Duration(days: 1));
          }

          return dueToday;
        }
      case 4: //monthly
        {
          if (nowTime < dueTime) {
            return dueToday;
          }

          int month = now.month;
          int year = now.year;
          if (month == 12) {
            month = 1;
            year++;
          } else {
            month++;
          }

          return new DateTime(
              year, month, now.day, due.hour, due.minute);
        }
      case 5: //monthly on particular dates
        {
          int taskDay = -1;
          for (int i = 0; i < frequencies.length; i++) {
            if ((frequencies[i] == now.day && nowTime < dueTime) ||
                frequencies[i] > now.day) {
              taskDay = frequencies[i];
              break;
            }
          }

          int month = now.month;
          int year = now.year;

          if (taskDay == -1) {
            taskDay = frequencies[0];
            if (month == 12) {
              month = 1;
              year++;
            } else {
              month++;
            }
          }

          return new DateTime(
              year, month, taskDay, now.hour, now.minute);
        }
    }

    return now;
  }

  static Future<List> getTasksWithConflicts(String ownerTenantId, List tasksWithConflicts, int repeat, Set<int> selectedFrequencies, String taskId, Duration duration, DateTime duedatetime) async {

    tasksWithConflicts = new List();
    return _getAllTasks(ownerTenantId).then((tasksList) {
      if (tasksList == null) return null;
      DateTime toduedatetime;
      if (duration != null) {
        toduedatetime = duedatetime.add(duration);
      } else {
        toduedatetime = duedatetime.add(new Duration(hours: 0, minutes: 1));
      }
      for (int i = 0; i < tasksList.length; i++) {
        if (tasksList[i].documentID == taskId) {
          continue;
        }
       

        DateTime existingduedatetime =
            (tasksList[i].data['due'] as Timestamp).toDate();
        DateTime existingtoduedatetime =
            existingduedatetime.add(new Duration(hours: 0, minutes: 1));
        DateTime relativeExistingToDueDateTime = new DateTime(
                duedatetime.year,
                duedatetime.month,
                duedatetime.day,
                existingduedatetime.hour,
                existingduedatetime.minute)
            .add(new Duration(hours: 0, minutes: 1));

        DateTime relativeExistingDateTime = new DateTime(
            duedatetime.year,
            duedatetime.month,
            duedatetime.day,
            existingduedatetime.hour,
            existingduedatetime.minute);
        if (tasksList[i].data['duration'] != '') {
          int hours = int.parse(tasksList[i].data['duration'].split(':')[0]);
          int minutes = int.parse(tasksList[i].data['duration'].split(':')[1]);
          existingtoduedatetime = existingduedatetime
              .add(new Duration(hours: hours, minutes: minutes));
          relativeExistingToDueDateTime = new DateTime(
                  duedatetime.year,
                  duedatetime.month,
                  duedatetime.day,
                  existingduedatetime.hour,
                  existingduedatetime.minute)
              .add(new Duration(hours: hours, minutes: minutes));
        }

        int taskRepeat = tasksList[i].data['repeat'];
        if (taskRepeat == 3 && repeat == 2) {
          List<int> frequency =
              tasksList[i].data['frequency'].split(',').map(int.parse).toList();
          if (frequency.contains(duedatetime.weekday) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 2 && repeat == 3) {
          List<int> frequency = selectedFrequencies.toList();
          if (frequency.contains(existingduedatetime.weekday) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 5 && repeat == 4) {
          List<int> frequency =
              tasksList[i].data['frequency'].split(',').map(int.parse).toList();
          if (frequency.contains(duedatetime.day) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 4 && repeat == 5) {
          List<int> frequency = selectedFrequencies.toList();

          if (frequency.contains(existingduedatetime.day) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 2 && repeat == 2) {
          if (duedatetime.weekday == existingduedatetime.weekday &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 4 && repeat == 4) {
          if (duedatetime.day == existingduedatetime.day &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 3 && repeat == 3) {
          Set<int> frequency1 = (tasksList[i].data['frequency'] as String)
              .split(',')
              .map(int.parse)
              .toList()
              .toSet();

          if (frequency1.intersection(selectedFrequencies).isNotEmpty &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 5 && repeat == 5) {
          Set<int> frequency1 = tasksList[i]
              .data['frequency']
              .split(',')
              .map(int.parse)
              .toList()
              .toSet();
          if (frequency1.intersection(selectedFrequencies).isNotEmpty &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == -1 && repeat == 2) {
          if (duedatetime.weekday == existingduedatetime.weekday &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == -1 && repeat == 3) {
          if (selectedFrequencies.contains(existingduedatetime.weekday) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == -1 && repeat == 4) {
          if (duedatetime.day == existingduedatetime.day &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == -1 && repeat == 5) {
          if (selectedFrequencies.contains(existingduedatetime.day) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 2 && repeat == -1) {
          if (duedatetime.weekday == existingduedatetime.weekday &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 3 && repeat == -1) {
          Set<int> frequency1 = tasksList[i]
              .data['frequency']
              .split(',')
              .map(int.parse)
              .toList()
              .toSet();

          if (frequency1.contains(duedatetime.weekday) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 4 && repeat == -1) {
          if (duedatetime.day == existingduedatetime.day &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 5 && repeat == -1) {
          Set<int> frequency1 = tasksList[i]
              .data['frequency']
              .split(',')
              .map(int.parse)
              .toList()
              .toSet();

          if (frequency1.contains(duedatetime.day) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 1) {
          tasksWithConflicts.add(tasksList[i].data);
        } else if (taskRepeat == -1 &&
            repeat == -1 &&
            _overlap(duedatetime, toduedatetime, existingduedatetime,
                existingtoduedatetime)) {
          tasksWithConflicts.add(tasksList[i].data);
        } else if (_overlap(duedatetime, toduedatetime,
            relativeExistingDateTime, relativeExistingToDueDateTime)) {
          tasksWithConflicts.add(tasksList[i].data);
        }
      }

      return tasksWithConflicts;
    }).catchError((e) => print("error while fetching data: $e"));
  }

    ///check if the two tasks overlap with respect to time
  static bool _overlap(DateTime newTaskFrom, DateTime newTaskTo,
      DateTime existingTaskFrom, DateTime existingTaskTo) {
    return !(newTaskFrom.isAfter(existingTaskTo) ||
            existingTaskFrom.isAfter(newTaskTo)) ||
        newTaskFrom.compareTo(existingTaskFrom) == 0 ||
        newTaskFrom.compareTo(existingTaskTo) == 0 ||
        newTaskTo.compareTo(existingTaskFrom) == 0 ||
        newTaskTo.compareTo(existingTaskTo) == 0;
  }

  ///get all tasks to check conflicts
  static Future<List<DocumentSnapshot>> _getAllTasks(String ownerTenantId) async {
    QuerySnapshot tasks = await Firestore.instance
        .collection(globals.ownerTenantFlat)
        .document(ownerTenantId)
        .collection(globals.tasksLandlord)
        .where("completed", isEqualTo: false)
        .getDocuments();

    if (tasks.documents.isNotEmpty)
      return tasks.documents;
    else
      return null;
  }

}