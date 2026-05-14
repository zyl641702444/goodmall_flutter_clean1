import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DetailPage extends StatefulWidget {
  final dynamic goods;
  const DetailPage({super.key, required this.goods});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ApiService api = ApiService();
  bool loading = true;
  Map<String, dynamic> detail = {};
  Map<String, dynamic> goods = {};
  List<Map<String, dynamic>> pics = [];
  List<Map<String, dynamic>> skus = [];
  Map<String, dynamic>? selectedSku;
  double displayPrice = 0;
  String debugSource = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _get(dynamic obj, List<String> keys, [String fallback = '']) {
    if (obj is Map) {
      for (final k in keys) {
        final v = obj[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
    }
    try {
      for (final k in keys) {
        final v = (obj as dynamic).toJson?[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
    } catch (_) {}
    return fallback;
  }

  double _price(dynamic v) {
    final p = double.tryParse(v?.toString() ?? '') ?? 0;
    if (p <= 0) return 0;
    if (p > 1000) return double.parse((p / 7.2).toStringAsFixed(2));
    return double.parse(p.toStringAsFixed(2));
  }

  String _imageFrom(dynamic item) {
    final v = _get(item, ['url', 'pic_url', 'img_url', 'image', 'cover', 'thumb_url']);
    if (v.startsWith('//')) return 'https:$v';
    if (v.startsWith('http')) return v;
    return '';
  }

  Future<void> _load() async {
    final id = _get(widget.goods, ['id', 'goods_id', 'old_id'], '');
    try {
      final res = await api.goodsDetail(id);
      final data = (res['data'] is Map) ? Map<String, dynamic>.from(res['data']) : <String, dynamic>{};
      final g = (data['goods'] is Map) ? Map<String, dynamic>.from(data['goods']) : data;
      final rawPics = (data['pics'] ?? data['images'] ?? g['pics'] ?? []) as dynamic;
      final rawSkus = (data['skus'] ?? data['sku'] ?? g['skus'] ?? []) as dynamic;
      final pList = <Map<String, dynamic>>[];
      if (rawPics is List) {
        for (final p in rawPics) {
          if (p is Map) pList.add(Map<String, dynamic>.from(p));
          if (p is String) pList.add({'url': p});
        }
      }
      final sList = <Map<String, dynamic>>[];
      if (rawSkus is List) {
        for (final s in rawSkus) {
          if (s is Map) sList.add(Map<String, dynamic>.from(s));
        }
      }
      final basePrice = _price(g['final_price_usd'] ?? g['price_usd'] ?? g['price'] ?? g['shop_price']);
      setState(() {
        detail = data;
        goods = g;
        pics = pList;
        skus = sList;
        selectedSku = skus.isNotEmpty ? skus.first : null;
        displayPrice = selectedSku != null ? _price(selectedSku!['price'] ?? selectedSku!['shop_price'] ?? basePrice) : basePrice;
        debugSource = (data['debug_source'] ?? g['debug_source'] ?? '').toString();
        loading = false;
      });
    } catch (e) {
      setState(() {
        goods = widget.goods is Map ? Map<String, dynamic>.from(widget.goods) : {};
        debugSource = 'detail_load_error: $e';
        loading = false;
      });
    }
  }

  Future<void> _cart() async {
    final gid = _get(goods, ['id', 'goods_id'], _get(widget.goods, ['id', 'goods_id']));
    final sid = _get(selectedSku ?? {}, ['sku_id', 'id'], 'default');
    final res = await api.cartAdd(gid, skuId: sid, qty: 1);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['msg']?.toString() ?? '已加入购物车')));
  }

  Future<void> _buy() async {
    final gid = _get(goods, ['id', 'goods_id'], _get(widget.goods, ['id', 'goods_id']));
    final sid = _get(selectedSku ?? {}, ['sku_id', 'id'], 'default');
    final res = await api.createOrder(goodsId: gid, skuId: sid, qty: 1);
    if (!mounted) return;
    Navigator.pushNamed(context, '/order-result', arguments: res);
  }

  @override
  Widget build(BuildContext context) {
    final title = _get(goods, ['title', 'goods_name', 'name'], _get(widget.goods, ['title', 'goods_name', 'name'], '商品详情'));
    final mainImage = pics.isNotEmpty ? _imageFrom(pics.first) : _imageFrom(goods);
    return Scaffold(
      appBar: AppBar(title: const Text('商品详情')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                if (mainImage.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(mainImage, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _emptyImage()),
                  )
                else
                  _emptyImage(height: 220),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Text('\$${displayPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 34, color: Color(0xff2563eb), fontWeight: FontWeight.w900)),
                      const Spacer(),
                      Text(debugSource, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 18),
                    const Text('SKU / 规格', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: skus.isEmpty
                          ? [const Chip(label: Text('默认规格'))]
                          : skus.map((s) {
                              final title = _get(s, ['title', 'name', 'specs', 'spec'], '规格');
                              final active = identical(s, selectedSku) || _get(s, ['id', 'sku_id']) == _get(selectedSku ?? {}, ['id', 'sku_id']);
                              return ChoiceChip(
                                label: Text(title),
                                selected: active,
                                onSelected: (_) => setState(() {
                                  selectedSku = s;
                                  displayPrice = _price(s['price'] ?? s['shop_price'] ?? goods['price'] ?? displayPrice);
                                }),
                              );
                            }).toList(),
                    ),
                    const SizedBox(height: 18),
                    const Text('商品图片', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...pics.skip(1).map((p) {
                      final u = _imageFrom(p);
                      if (u.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Image.network(u, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _emptyImage(height: 160)),
                      );
                    }),
                  ]),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: _cart, icon: const Icon(Icons.add_shopping_cart), label: const Text('加购物车'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(onPressed: _buy, icon: const Icon(Icons.shopping_bag), label: const Text('立即购买'))),
          ]),
        ),
      ),
    );
  }

  Widget _emptyImage({double height = 240}) => Container(height: height, color: const Color(0xffeef2f7), alignment: Alignment.center, child: const Icon(Icons.image, size: 64, color: Colors.blueGrey));
}
