import 'user.dart';

enum ExpenseStatus { pending, approved, rejected }

class Expense {
  Expense({
    required this.id,
    required this.item,
    required this.amount,
    required this.date,
    required this.clientId,
    required this.clientName,
    required this.submitter,
    this.project,
    this.billImagePath,
    this.notes,
    this.status = ExpenseStatus.pending,
    this.rejectionReason,
  });

  final String id;
  final String item;
  final double amount;
  final DateTime date;
  final String clientId;
  final String clientName;
  final AppUser submitter;
  final String? project;
  final String? billImagePath;
  final String? notes;
  ExpenseStatus status;
  String? rejectionReason;
}
