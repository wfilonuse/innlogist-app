import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/order.dart';
import '../models/document.dart';
import '../providers/document_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/order_progress_widget.dart';

class ActiveOrderScreen extends StatefulWidget {
  final Order order;

  const ActiveOrderScreen({super.key, required this.order});

  @override
  _ActiveOrderScreenState createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Document> _documents = [];
  bool _isLoadingDocs = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoadingDocs = true;
    });
    try {
      await Provider.of<DocumentProvider>(context, listen: false).fetchItems();
      _documents = Provider.of<DocumentProvider>(context, listen: false)
          .items
          .where((d) => d.scope == 'order')
          .toList();
    } catch (_) {}
    setState(() {
      _isLoadingDocs = false;
    });
  }

  Widget _documentIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return SvgPicture.asset('assets/svg/doc_pdf.svg',
            width: 32, height: 32);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return SvgPicture.asset('assets/svg/doc_image.svg',
            width: 32, height: 32);
      case 'doc':
      case 'docx':
        return SvgPicture.asset('assets/svg/doc_word.svg',
            width: 32, height: 32);
      case 'xls':
      case 'xlsx':
        return SvgPicture.asset('assets/svg/doc_excel.svg',
            width: 32, height: 32);
      default:
        return SvgPicture.asset('assets/svg/doc_unknown.svg',
            width: 32, height: 32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final order = widget.order;
    final addresses = order.addresses;
    final cargo = order.cargo;
    final clientName = order.clientName;
    final progressList = order.progress ?? [];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.translate('orders')),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: loc.translate('info')),
              Tab(text: loc.translate('map')),
              Tab(text: loc.translate('documents')),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Інфо
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text('${loc.translate('orderStatus')}: ${order.status}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...addresses.map((address) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.type == 'pickup'
                                  ? loc.translate('pickup')
                                  : loc.translate('delivery'),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: address.type == 'pickup'
                                      ? Colors.blue
                                      : Colors.green),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              address.dateAt,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                address.address,
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                  Text(
                      '${loc.translate('orderCargo')}: ${cargo.name} (${cargo.weight} кг | ${cargo.volume} м³)'),
                  const SizedBox(height: 8),
                  Text(
                      '${loc.translate('orderStage')}: ${progressList.isNotEmpty ? progressList.first.name : '-'}'),
                  const SizedBox(height: 8),
                  Text('${loc.translate('client')}: $clientName'),
                  const SizedBox(height: 16),
                  OrderProgressWidget(orderId: order.id),
                ],
              ),
            ),
            // Мапа
            Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(addresses.first.lat, addresses.first.lng),
                    zoom: 12,
                  ),
                  markers: addresses
                      .map((address) => Marker(
                            markerId: MarkerId(address.address),
                            position: LatLng(address.lat, address.lng),
                            infoWindow: InfoWindow(title: address.address),
                          ))
                      .toSet(),
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points:
                          addresses.map((a) => LatLng(a.lat, a.lng)).toList(),
                      color: Colors.blue,
                      width: 5,
                    ),
                  },
                ),
              ],
            ),
            // Документи
            _isLoadingDocs
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _documents.length,
                    itemBuilder: (context, index) {
                      final doc = _documents[index];
                      return ListTile(
                        leading: _documentIcon(doc.fileName),
                        title: Text(doc.name),
                        subtitle: Text(doc.fileName),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () {
                            // TODO: реалізувати завантаження
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
        floatingActionButton: _tabController.index == 2
            ? FloatingActionButton(
                onPressed: () {
                  // TODO: реалізувати додавання документа
                },
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
