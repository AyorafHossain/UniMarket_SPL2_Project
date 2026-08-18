import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ticket_model.dart';
import '../services/ticket_service.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportTicketsScreen extends StatelessWidget {
  const SupportTicketsScreen({super.key});

  void _showTicketDetails(BuildContext context, TicketModel ticket) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ticket Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User: ${ticket.userName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Category: ${ticket.category}'),
              if (ticket.orderId != null) ...[
                const SizedBox(height: 4),
                Text('Order ID: ${ticket.orderId}'),
              ],
              const SizedBox(height: 12),
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(ticket.description),
              
              if (ticket.status == 'pending') ...[
                const SizedBox(height: 24),
                const Text('Admin Reply:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: replyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter your reply to resolve the issue...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else if (ticket.adminReply != null) ...[
                const SizedBox(height: 24),
                const Text('Your Reply:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 4),
                Text(ticket.adminReply!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (ticket.status == 'pending')
            ElevatedButton(
              onPressed: () async {
                final reply = replyController.text.trim();
                if (reply.isEmpty) return;
                
                try {
                  await TicketService().resolveTicket(ticket.id, ticket.userId, reply);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Mark as Resolved'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Tickets'),
      ),
      body: StreamBuilder<List<TicketModel>>(
        stream: TicketService().getAllTicketsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading tickets. (Check Index)'));
          }

          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) {
            return const Center(child: Text('No support tickets found.'));
          }

          // Sort so pending is at the top
          tickets.sort((a, b) {
            if (a.status == 'pending' && b.status != 'pending') return -1;
            if (a.status != 'pending' && b.status == 'pending') return 1;
            return b.createdAt.compareTo(a.createdAt);
          });

          final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final isResolved = ticket.status == 'resolved';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(ticket.category, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('By: ${ticket.userName}', style: const TextStyle(color: Colors.grey)),
                      Text(dateFormat.format(ticket.createdAt), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isResolved ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isResolved ? 'Resolved' : 'Pending',
                      style: GoogleFonts.inter(
                        color: isResolved ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => _showTicketDetails(context, ticket),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
