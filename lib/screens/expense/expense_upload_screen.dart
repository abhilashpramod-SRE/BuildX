import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/client.dart';
import '../../models/expense.dart';
import '../../viewmodels/app_view_model.dart';

class ExpenseUploadScreen extends StatefulWidget {
  const ExpenseUploadScreen({super.key});

  @override
  State<ExpenseUploadScreen> createState() => _ExpenseUploadScreenState();
}

class _ExpenseUploadScreenState extends State<ExpenseUploadScreen> {
  final _itemController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _projectController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _imagePath;
  Client? _selectedClient;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();
    final user = vm.currentUser!;
    final clients = vm.allClients();

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Expense Bill')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (clients.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'No clients found. Please ask Supervisor/Owner to add a client before uploading expenses.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          const SizedBox(height: 8),
          DropdownButtonFormField<Client>(
            value: _selectedClient,
            items: clients
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
            onChanged: clients.isEmpty ? null : (v) => setState(() => _selectedClient = v),
            decoration: const InputDecoration(labelText: 'Client *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _itemController,
            decoration: const InputDecoration(labelText: 'Item / Description'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _projectController,
            decoration: const InputDecoration(
              labelText: 'Project (Optional)',
              helperText: 'Used for contractor-side filtering',
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Date: ${_selectedDate.toLocal().toString().split(' ').first}'),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDate: _selectedDate,
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: Text(_imagePath == null ? 'Upload Bill Image' : 'Image Selected'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Optional Notes / Remarks'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: clients.isEmpty
                ? null
                : () async {
                    if (_selectedClient == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a client.')),
                      );
                      return;
                    }

                    final expense = Expense(
                      id: const Uuid().v4(),
                      item: _itemController.text.trim(),
                      amount: double.tryParse(_amountController.text) ?? 0,
                      date: _selectedDate,
                      clientId: _selectedClient!.id,
                      clientName: _selectedClient!.name,
                      submitter: user,
                      project: _projectController.text.trim().isEmpty
                          ? null
                          : _projectController.text.trim(),
                      billImagePath: _imagePath,
                      notes: _notesController.text.trim(),
                    );

                    await vm.submitExpense(expense);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Submitted for supervisor approval.')),
                    );
                    Navigator.pop(context);
                  },
            child: const Text('Submit Expense'),
          ),
        ],
      ),
    );
  }
}
