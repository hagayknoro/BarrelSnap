import 'package:flutter/material.dart';
import '/models/wines.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/wineService.dart';
import '/pages/business/wine_card.dart';

class ShopPageBusiness extends StatefulWidget {
  const ShopPageBusiness({Key? key}) : super(key: key);

  @override
  _ShopPageBusinessState createState() => _ShopPageBusinessState();
}

class _ShopPageBusinessState extends State<ShopPageBusiness> {
  late List<WineModel> wines = [];
  late List<WineModel> filteredWines = [];

  @override
  void initState() {
    super.initState();
    fetchWines();
  }

  Future<void> fetchWines() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final String businessId = user?.uid ?? '';
      final List<WineModel> fetchedWines =
          await WineServices.getBusinessWines(businessId);
      setState(() {
        wines = fetchedWines;
        filteredWines = List.from(wines); // Initialize filteredWines with all wines
      });
    } catch (e) {
      print('Error fetching wines: $e');
    }
  }

  void _filterWines(String query) {
    setState(() {
      filteredWines = wines
          .where((wine) =>
              wine.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'My Wines',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: _filterWines,
            decoration: const InputDecoration(
              labelText: 'Search by Wine name',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredWines.length,
            itemBuilder: (context, index) => WineCard(
              wine: filteredWines[index],
              onUpdate: () => fetchWines(),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _showAddWineDialog(context);
            },
            child: const Text('Add New Wine'),
          ),
        ),
      ],
    ),
  );
}


  void _showAddWineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Wine'),
          content: _buildWineForm(context),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWineForm(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _kindOfGrapeController =
        TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();
    final TextEditingController _priceController = TextEditingController();
    final TextEditingController _quantityController = TextEditingController();

    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the name';
                }
                return null;
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: TextFormField(
              controller: _kindOfGrapeController,
              decoration: const InputDecoration(
                hintText: 'Kind of grape',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the kind of grape';
                }
                return null;
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the description';
                }
                return null;
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                hintText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the price';
                }
                return null;
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                hintText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the quantity';
                }
                return null;
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _addWine(
                context,
                _nameController.text,
                _kindOfGrapeController.text,
                _descriptionController.text,
                int.parse(_priceController.text),
                int.parse(_quantityController.text),
              );
            },
            child: const Text('Add Wine'),
          ),
        ],
      ),
    );
  }

  void _addWine(BuildContext context, String name, String kindOfGrape,
      String description, int price, int quantity) {
    final WineModel wine = WineModel(
      id: '',
      name: name,
      kindOfGrape: kindOfGrape,
      description: description,
      price: price,
      quantity: quantity,
    );
    final user = FirebaseAuth.instance.currentUser;
    final String businessId = user?.uid ?? '';
    WineServices.addWine(wine, businessId).then((_) {
      Navigator.of(context).pop();
      fetchWines();
    });
  }
}
