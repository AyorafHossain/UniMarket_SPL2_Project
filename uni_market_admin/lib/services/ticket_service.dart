import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart';

class TicketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of all tickets
  Stream<List<TicketModel>> getAllTicketsStream() {
    return _firestore
        .collection('support_tickets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TicketModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Resolve a ticket and send notification
  Future<void> resolveTicket(String ticketId, String userId, String replyMsg) async {
    final batch = _firestore.batch();
    
    // Update ticket
    final ticketRef = _firestore.collection('support_tickets').doc(ticketId);
    batch.update(ticketRef, {
      'status': 'resolved',
      'adminReply': replyMsg,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Create Notification
    final notifRef = _firestore.collection('notifications').doc();
    batch.set(notifRef, {
      'id': notifRef.id,
      'userId': userId,
      'title': 'Support Ticket Resolved',
      'body': 'An admin has replied to your support ticket.',
      'type': 'support_reply',
      'data': {'ticketId': ticketId},
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
