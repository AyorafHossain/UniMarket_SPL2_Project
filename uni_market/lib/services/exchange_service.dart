import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/exchange_request_model.dart';
import 'notification_service.dart';

class ExchangeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createExchangeRequest(ExchangeRequestModel request) async {
    if (request.productId.isEmpty) throw Exception('Product ID cannot be empty');
    if (request.sellerId.isEmpty) throw Exception('Seller ID cannot be empty');
    if (request.requesterId.isEmpty) throw Exception('Requester ID cannot be empty');

    DocumentReference docRef;
    if (request.requestId.isEmpty) {
      docRef = _firestore.collection('exchangeRequests').doc();
      request = ExchangeRequestModel(
        requestId: docRef.id,
        productId: request.productId,
        productTitle: request.productTitle,
        productImageUrl: request.productImageUrl,
        requesterId: request.requesterId,
        requesterName: request.requesterName,
        sellerId: request.sellerId,
        wantedItem: request.wantedItem,
        message: request.message,
        status: request.status,
        createdAt: request.createdAt,
      );
    } else {
      docRef = _firestore.collection('exchangeRequests').doc(request.requestId);
    }

    await docRef.set(request.toMap());

    // Only notify if it's a new request
    if (request.requestId.isEmpty || request.requestId == docRef.id) {
      try {
        await NotificationService().createNotification(
          userId: request.sellerId,
          type: 'new_exchange_request',
          title: 'New Exchange Request!',
          body: '${request.requesterName} wants to exchange ${request.productTitle}',
          data: {'requestId': docRef.id},
        );
      } catch (e) {
        debugPrint('Error sending exchange request notification: $e');
      }
    }
  }

  Stream<List<ExchangeRequestModel>> getSellerExchangeRequests(String sellerId) {
    if (sellerId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('exchangeRequests')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      var requests = snapshot.docs
          .map((doc) => ExchangeRequestModel.fromMap(doc.data(), doc.id))
          .toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  Stream<List<ExchangeRequestModel>> getMyExchangeRequests(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('exchangeRequests')
        .where('requesterId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      var requests = snapshot.docs
          .map((doc) => ExchangeRequestModel.fromMap(doc.data(), doc.id))
          .toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  Future<void> updateRequestStatus(ExchangeRequestModel request, String status) async {
    await _firestore
        .collection('exchangeRequests')
        .doc(request.requestId)
        .update({'status': status});

    if (status == 'accepted' || status == 'rejected') {
      try {
        await NotificationService().createNotification(
          userId: request.requesterId,
          type: 'exchange_request',
          title: 'Exchange Request ${status == 'accepted' ? 'Accepted' : 'Rejected'}',
          body: 'Your exchange request for ${request.productTitle} has been $status.',
          data: {'requestId': request.requestId},
        );
      } catch (e) {
        debugPrint('Error sending exchange status notification: $e');
      }
    }
  }
}
