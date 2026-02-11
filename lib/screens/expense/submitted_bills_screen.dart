import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../models/expense.dart';
import '../../viewmodels/app_view_model.dart';

class SubmittedBillsScreen extends StatefulWidget {
  const SubmittedBillsScreen({super.key});

  @override
  State<SubmittedBillsScreen> createState() => _SubmittedBillsScreenState();
}

class _SubmittedBillsScreenState extends State<SubmittedBillsScreen> {
  String? _clientId;
  ExpenseStatus? _status;
  String? _project;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final clients = vm.allClients();
    final projects = vm.myProjects();
    final expenses = vm.myExpenses(clientId: _clientId, status: _status, project: _project);

    return Scaffold(
      appBar: AppBar(title: const Text('My Submitted Bills')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String?>(
            value: _clientId,
            decoration: const InputDecoration(labelText: 'Filter by Client'),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('All Clients')),
              ...clients.map(
                (Client c) => DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
              ),
            ],
            onChanged: (v) => setState(() => _clientId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ExpenseStatus?>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Filter by Status'),
            items: [
              const DropdownMenuItem<ExpenseStatus?>(value: null, child: Text('All Statuses')),
              ...ExpenseStatus.values.map(
                (s) => DropdownMenuItem<ExpenseStatus?>(value: s, child: Text(s.name.toUpperCase())),
              ),
            ],
            onChanged: (v) => setState(() => _status = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: _project,
            decoration: const InputDecoration(labelText: 'Filter by Project'),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('All Projects')),
              ...projects.map(
                (p) => DropdownMenuItem<String?>(value: p, child: Text(p)),
              ),
            ],
            onChanged: (v) => setState(() => _project = v),
          ),
          const SizedBox(height: 16),
          if (expenses.isEmpty)
            const Center(child: Text('No submitted bills found for selected filters.'))
          else
            ...expenses.map(
              (e) => Card(
                child: ListTile(
                  title: Text('${e.item} • ₹${e.amount.toStringAsFixed(2)}'),
                  subtitle: Text(
                    '${e.clientName} • ${DateFormat('dd MMM yyyy').format(e.date)}\nProject: ${e.project ?? '-'}',
                  ),
                  isThreeLine: true,
                  trailing: Chip(label: Text(e.status.name.toUpperCase())),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
