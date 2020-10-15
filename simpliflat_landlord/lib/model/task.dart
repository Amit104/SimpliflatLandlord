import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/base_model.dart';

class Task extends BaseModel {
  bool assignedToFlat;
  List<String> assignees;
  bool completed;
  Timestamp due;
  Duration duration;
  List<int> frequency;
  Timestamp nextDueDate;
  String notes;
  String payee;
  double paymentAmount;
  int priority;
  bool remindIssue;
  int repeat;
  bool shouldRemindDaily;
  String title;
  String type;
  String createdByUserId;
  String taskId;

	bool isAssignedToFlat() {
		return this.assignedToFlat;
	}

	void setAssignedToFlat(bool assignedToFlat) {
		this.assignedToFlat = assignedToFlat;
	}

	List<String> getAssignees() {
		return this.assignees;
	}

	void setAssignees(List<String> assignees) {
		this.assignees = assignees;
	}

	bool isCompleted() {
		return this.completed;
	}

	void setCompleted(bool completed) {
		this.completed = completed;
	}

	Timestamp getDue() {
		return this.due;
	}

	void setDue(Timestamp due) {
		this.due = due;
	}

	Duration getDuration() {
		return this.duration;
	}

	void setDuration(Duration duration) {
		this.duration = duration;
	}

	List<int> getFrequency() {
		return this.frequency;
	}

	void setFrequency(List<int> frequency) {
		this.frequency = frequency;
	}

	Timestamp getNextDueDate() {
		return this.nextDueDate;
	}

	void setNextDueDate(Timestamp nextDueDate) {
		this.nextDueDate = nextDueDate;
	}

	String getNotes() {
		return this.notes;
	}

	void setNotes(String notes) {
		this.notes = notes;
	}

	String getPayee() {
		return this.payee;
	}

	void setPayee(String payee) {
		this.payee = payee;
	}

	double getPaymentAmount() {
		return this.paymentAmount;
	}

	void setPaymentAmount(double paymentAmount) {
		this.paymentAmount = paymentAmount;
	}

	int getPriority() {
		return this.priority;
	}

	void setPriority(int priority) {
		this.priority = priority;
	}

	bool isRemindIssue() {
		return this.remindIssue;
	}

	void setRemindIssue(bool remindIssue) {
		this.remindIssue = remindIssue;
	}

	int getRepeat() {
		return this.repeat;
	}

	void setRepeat(int repeat) {
		this.repeat = repeat;
	}

	bool isShouldRemindDaily() {
		return this.shouldRemindDaily;
	}

	void setShouldRemindDaily(bool shouldRemindDaily) {
		this.shouldRemindDaily = shouldRemindDaily;
	}

	String getTitle() {
		return this.title;
	}

	void setTitle(String title) {
		this.title = title;
	}

	String getType() {
		return this.type;
	}

	void setType(String type) {
		this.type = type;
	}

	String getCreatedByUserId() {
		return this.createdByUserId;
	}

	void setCreatedByUserId(String createdByUserId) {
		this.createdByUserId = createdByUserId;
	}

  String getTaskId() {
		return this.taskId;
	}

	void setTaskId(String taskId) {
		this.taskId = taskId;
	}

  static Task fromJson(Map<String, dynamic> data, String documentId) {
    Task task = new Task();
    task.setAssignedToFlat(data['assigned_to_flat']);
    if(data['assignee'] != null && data['assignee'] != '')
      task.setAssignees(data['assignees'].toString().split(',').toList());

    task.setCompleted(data['completed']);
    task.setCreatedByUserId(data['user_id']);
    task.setDue(data['due']);
    task.setDuration(data['duration']);

    if(data['duration'] != null && data['duration'] != '') {
      List<String> durationElements = data['duration'].split(":").toList();
      task.setDuration(new Duration(hours: int.parse(durationElements[0]), minutes: int.parse(durationElements[1])));
    }
    if(data['frequency'] != null && data['frequency'] != '') {
      task.setFrequency(data['frequency'].toString().split(',').map(int.parse).toList());
    }

    task.setNextDueDate(data['nextDueDate']);
    task.setNotes(data['notes']);
    task.setPayee(data['payee']);
    task.setPaymentAmount(data['paymentAmount']);
    task.setPriority(data['priority']);
    task.setRemindIssue(data['remindIssue']);
    task.setRepeat(data['repeat'] as int);
    task.setShouldRemindDaily(data['shouldRemindDaily']);
    task.setTitle(data['title']);
    task.setType(data['type']);
    task.setCreatedAt(data['created_at']);
    task.setUpdatedAt(data['updated_at']);
    task.setTaskId(documentId);
    
    return task;
  }

  static Map<String, dynamic> toUpdateJson({Timestamp nextDueDate, bool completed}) {
    Map<String, dynamic> updateJson = new Map();
    if(nextDueDate != null) updateJson['nextDueDate'] = nextDueDate;
    if(completed != null) updateJson['completed'] = completed;
    updateJson['updated_at'] = Timestamp.now();
    return updateJson;
  }

}