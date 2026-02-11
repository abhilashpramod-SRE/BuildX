import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../viewmodels/app_view_model.dart';

class InvoiceGenerationScreen extends StatefulWidget {
  const InvoiceGenerationScreen({super.key});

  @override
  State<InvoiceGenerationScreen> createState() => _InvoiceGenerationScreenState();
}

class _InvoiceGenerationScreenState extends State<InvoiceGenerationScreen> {
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();

  Client? _selectedClient;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final clients = vm.searchClients(_searchController.text);
    final approved = vm
        .approvedExpenses()
        .where((e) => _selectedClient == null || e.clientId == _selectedClient!.id)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Invoice')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            decoration:
                const InputDecoration(labelText: 'Search client by name or phone'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          if (clients.isNotEmpty)
            ...clients.map(
              (c) => RadioListTile<Client>(
                value: c,
                groupValue: _selectedClient,
                title: Text(c.name),
                subtitle: Text('${c.phone} • ${c.address}'),
                onChanged: (v) => setState(() => _selectedClient = v),
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Optional Notes'),
          ),
          const SizedBox(height: 12),
          Text('Approved Expense Items (${approved.length})'),
          ...approved.map((e) => CheckboxListTile(
                value: true,
                onChanged: null,
                title: Text(e.item),
                subtitle:
                    Text('₹${e.amount.toStringAsFixed(2)} • ${e.clientName}'),
              )),
          ElevatedButton(
            onPressed: _selectedClient == null || approved.isEmpty
                ? null
                : () async {
                    final invoice = vm.createInvoice(
                      client: _selectedClient!,
                      items: approved,
                      notes: _notesController.text.trim(),
                    );

                    final pdfFile = await vm.createInvoicePdf(invoice);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invoice saved at ${pdfFile.path}')),
                    );
                  },
            child: const Text('Generate & Download PDF'),
          ),
        ],
      ),
    );
  }
}
