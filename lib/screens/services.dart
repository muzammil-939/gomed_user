import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_user/providers/product_services.dart';
import 'package:gomed_user/providers/getservice.dart';
import 'package:gomed_user/providers/loader.dart';
import 'package:gomed_user/screens/mybookedservices.dart';
import 'package:gomed_user/screens/service_details.dart';
import 'package:gomed_user/model/service.dart' as service_model;
import 'package:gomed_user/model/getservices.dart' as product_model;

class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({super.key});

  @override
  ServicesPageState createState() => ServicesPageState();
}

class ServicesPageState extends ConsumerState<ServicesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productserviceprovider.notifier).getproductSevices();
      ref.read(serviceProvider.notifier).getSevices();
    });
  }

  Future<void> _loadProducts() async {
    await ref.read(productserviceprovider.notifier).getproductSevices();
    await ref.read(serviceProvider.notifier).getSevices();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productserviceprovider);
    final serviceState = ref.watch(serviceProvider);
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyServicesPage()),
              );
            },
            child: const Text(
              "My Services",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: isLoading || productState.data == null || serviceState.data == null
            ? const Center(child: CircularProgressIndicator())
            : Builder(
                builder: (context) {
                  final filteredProducts = productState.data!.where((product) {
                    return serviceState.data!.any(
                      (service) => service.productIds!.contains(product.productId),
                    );
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: const [
                        Center(child: Text("No services available for any product.")),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final productServices = serviceState.data!
                          .where((service) => service.productIds!.contains(product.productId))
                          .toList();

                      return ProductCard(
                        product: product,
                        services: productServices,
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final product_model.Data product;
  final List<service_model.Data> services;

  const ProductCard({super.key, required this.product, required this.services});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.productName ?? 'Unnamed Product',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...services.map(
              (service) => ServiceItem(
                service: service,
                productId: product.productId ?? '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceItem extends StatelessWidget {
  final service_model.Data service;
  final String productId;

  const ServiceItem({super.key, required this.service, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(
          service.name ?? 'Unnamed Service',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Price: ₹${service.price}"),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward, color: Colors.blue),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceDetailsPage(
                  service: service,
                  productId: productId,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}





