import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart';

class TicketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new ticket
  Future<void> createTicket(TicketModel ticket) async {
    await _firestore.collection('support_tickets').add(ticket.toMap());
  }

  // Get user's tickets
  Stream<List<TicketModel>> getUserTickets(String userId) {
    return _firestore
        .collection('support_tickets')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final tickets = snapshot.docs
          .map((doc) => TicketModel.fromMap(doc.data(), doc.id))
          .toList();
      tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tickets;
    });
  }
}
