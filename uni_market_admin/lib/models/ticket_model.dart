import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String id;
  final String userId;
  final String userName; // For admin convenience
  final String category;
  final String description;
  final String? orderId;
  final String status; // 'pending', 'resolved'
  final String? adminReply;
  final DateTime createdAt;
  final DateTime updatedAt;

  TicketModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.category,
    required this.description,
    this.orderId,
    this.status = 'pending',
    this.adminReply,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TicketModel(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown User',
      category: map['category'] ?? 'Other',
      description: map['description'] ?? '',
      orderId: map['orderId'],
      status: map['status'] ?? 'pending',
      adminReply: map['adminReply'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'category': category,
      'description': description,
      if (orderId != null) 'orderId': orderId,
      'status': status,
      if (adminReply != null) 'adminReply': adminReply,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
