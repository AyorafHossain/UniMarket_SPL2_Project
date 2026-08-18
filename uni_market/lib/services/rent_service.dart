import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/rent_request_model.dart';
import 'notification_service.dart';

class RentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _rentCollection =>
      _firestore.collection('rentRequests');

  // Create a new rent request
  Future<void> createRentRequest(RentRequestModel request) async {
    try {
      final docRef = _rentCollection.doc();
      final requestData = request.toMap();
      requestData['rentRequestId'] = docRef.id;
      
      await docRef.set(requestData);

      // Notify the seller about the new rent request
      try {
        await NotificationService().createNotification(
          userId: request.sellerId,
          type: 'new_rent_request',
          title: 'New Rent Request!',
          body: '${request.renterName} requested to rent ${request.productTitle}',
          data: {'requestId': docRef.id},
        );
      } catch (e) {
        debugPrint('Error sending rent request notification: $e');
      }
    } catch (e) {
      debugPrint('RentService: createRentRequest error: $e');
      rethrow;
    }
  }

  // Get stream of rent requests for a specific seller
  Stream<List<RentRequestModel>> getSellerRentRequests(String sellerId) {
    return _rentCollection
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs
          .map((doc) => RentRequestModel.fromMap(doc.data(), doc.id))
          .toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  // Get stream of rent requests made by a specific renter
  Stream<List<RentRequestModel>> getRenterRequests(String renterId) {
    return _rentCollection
        .where('renterId', isEqualTo: renterId)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs
          .map((doc) => RentRequestModel.fromMap(doc.data(), doc.id))
          .toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  // Update status of a rent request
  Future<void> updateRequestStatus(RentRequestModel request, String status) async {
    try {
      await _rentCollection.doc(request.rentRequestId).update({'status': status});

      if (status == 'accepted' || status == 'rejected') {
        try {
          await NotificationService().createNotification(
            userId: request.renterId,
            type: 'rent_request',
            title: 'Rent Request ${status == 'accepted' ? 'Accepted' : 'Rejected'}',
            body: 'Your rent request for ${request.productTitle} has been $status.',
            data: {'requestId': request.rentRequestId},
          );
        } catch (e) {
          debugPrint('Error sending rent status notification: $e');
        }
      }
    } catch (e) {
      debugPrint('RentService: updateRequestStatus error: $e');
      rethrow;
    }
  }
}
