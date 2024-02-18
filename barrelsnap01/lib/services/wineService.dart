import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:BarrelSnap/models/wines.dart';
import 'package:BarrelSnap/models/business.dart';
import '/models/wines.dart';


class WineServices {
  static Future<void> addWine(WineModel wine, String businessId) async {
    try {
      await FirebaseFirestore.instance
          .collection('business')
          .doc(businessId)
          .collection('wines')
          .add({
        'name': wine.name,
        'kindOfGrape': wine.kindOfGrape,
        'description': wine.description,
        'price': wine.price,
        'quantity': wine.quantity,
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateWine(
      WineModel wine, String businessId, String wineId) async {
    try {
      await FirebaseFirestore.instance
          .collection('business')
          .doc(businessId)
          .collection('wines')
          .doc(wineId)
          .update({
        'name': wine.name,
        'kindOfGrape': wine.kindOfGrape,
        'description': wine.description,
        'price': wine.price,
        'quantity': wine.quantity,
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteWine(String businessId, String wineId) async {
    try {
      await FirebaseFirestore.instance
          .collection('business')
          .doc(businessId)
          .collection('wines')
          .doc(wineId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<WineModel>> getBusinessWines(String businessId) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('business')
          .doc(businessId)
          .collection('wines')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return WineModel(
          id: doc.id,
          name: data['name'] ?? '',
          kindOfGrape: data['kindOfGrape'] ?? '',
          description: data['description'] ?? '',
          price: data['price'] ?? 0,
          quantity: data['quantity'] ?? 0,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateWineQuantity(
      String wineId, String businessId, int newQuantity) async {
    try {
      await FirebaseFirestore.instance
          .collection('business')
          .doc(businessId)
          .collection('wines')
          .doc(wineId)
          .update({
        'quantity': newQuantity,
      });
    } catch (e) {
      rethrow;
    }
  }
static Future<List<BusinessModel>> fetchBusinesses() async {
  try {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('business').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (data != null) {
        DateTime? birthdate;
        if (data['birthdate'] is Timestamp) {
          birthdate = (data['birthdate'] as Timestamp).toDate();
        } else if (data['birthdate'] is String) {
          birthdate = DateTime.parse(data['birthdate']);
        }

        return BusinessModel(
          uid: doc.id,
          business_name: data['business_name'] ?? '',
          manager_name: data['manager_name'] ?? '',
          birthdate: birthdate,
          phone_number: data['phone_number'] ?? '',
          city: data['city'] ?? '',
          street: data['street'] ?? '',
          street_number: data['street_number'] ?? '',
        );
      } else {
        throw Exception('Data is null for document ${doc.id}');
      }
    }).toList();
  } catch (e) {
    print('Error fetching businesses: $e');
    throw e;
  }
}


static Future<List<dynamic>> fetchWines(String businessId) async {
  try {
    final businessDoc = await FirebaseFirestore.instance.collection('business').doc(businessId).get();
    final businessData = businessDoc.data();
    if (businessData != null) {
      final business = BusinessModel(
        uid: businessId,
        business_name: businessData['business_name'] ?? '', // Correct the field name here
        manager_name: businessData['manager_name'] ?? '', // Correct the field name here
        birthdate: businessData['birthdate'] != null ? DateTime.parse(businessData['birthdate']) : DateTime.now(),
        phone_number: businessData['phone_number'] ?? '', // Correct the field name here
        city: businessData['city'] ?? '', // Correct the field name here
        street: businessData['street'] ?? '', // Correct the field name here
        street_number: businessData['street_number'] ?? '', // Correct the field name here
      );

      final winesSnapshot = await FirebaseFirestore.instance.collection('business').doc(businessId).collection('wines').get();
      final wines = winesSnapshot.docs.map((doc) {
        final data = doc.data();
        return WineModel(
          id: doc.id,
          name: data['name'] ?? '',
          kindOfGrape: data['kindOfGrape'] ?? '',
          description: data['description'] ?? '',
          price: data['price'] ?? 0,
          quantity: data['quantity'] ?? 0,
        );
      }).toList();

      return [business, wines];
    } else {
      throw 'Business data is null';
    }
  } catch (e) {
    rethrow;
  }
}


}

