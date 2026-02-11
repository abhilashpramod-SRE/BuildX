import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/app_view_model.dart';

class InvoiceHistoryScreen extends StatelessWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final invoices = vm.invoiceHistory();

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice History')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (invoices.isEmpty)
            const Center(child: Text('No invoices found.'))
          else
            ...invoices.map(
              (inv) => Card(
                child: ListTile(
                  title: Text(inv.invoiceNumber),
                  subtitle: Text(
                    '${inv.client.name} • ${DateFormat('dd MMM yyyy').format(inv.date)}\n₹${inv.totalAmount.toStringAsFixed(2)}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () async {
                      final file = await vm.createInvoicePdf(inv);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloaded: ${file.path}')),
                        );
                      }
                    },
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
