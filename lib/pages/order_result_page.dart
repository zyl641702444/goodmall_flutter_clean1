import 'package:flutter/material.dart';

class OrderResultPage extends StatelessWidget {
  final dynamic result;
  const OrderResultPage({super.key, this.result});

  String _pick(Map m, List<String> ks, [String fb='-']) {
    for (final k in ks) { final v = m[k]; if (v != null && v.toString().isNotEmpty) return v.toString(); }
    return fb;
  }

  @override
  Widget build(BuildContext context) {
    final args = result ?? ModalRoute.of(context)?.settings.arguments;
    final map = args is Map ? Map<String, dynamic>.from(args) : <String, dynamic>{};
    final data = map['data'] is Map ? Map<String, dynamic>.from(map['data']) : map;
    final orderNo = _pick(data, ['order_sn','order_no','order_id'], 'GM${DateTime.now().millisecondsSinceEpoch}');
    final goodsStatus = _pick(data, ['goods_status','pay_status'], 'goods_payment_pending');
    final freightStatus = _pick(data, ['freight_status','logistics_status'], '待到仓称重');
    final packageId = _pick(data, ['package_id','parcel_id'], '1');
    return Scaffold(
      appBar: AppBar(title: const Text('订单/包裹')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xff2563eb), Color(0xff7c3aed)]), borderRadius: BorderRadius.circular(22)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.check_circle, color: Colors.white, size: 46),
            SizedBox(height: 18),
            Text('订单已创建', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('商品款先支付；国际运费到金边仓称重后再付。', style: TextStyle(color: Colors.white, fontSize: 15)),
          ]),
        ),
        const SizedBox(height: 20),
        _card('订单号', orderNo),
        _card('包裹 ID', packageId),
        _card('商品状态', goodsStatus),
        _card('国际运费状态', freightStatus),
        const SizedBox(height: 18),
        ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.qr_code), label: const Text('到仓后：支付国际运费 / 生成自提码')),
      ]),
    );
  }

  Widget _card(String k, String v) => Card(child: ListTile(title: Text(k, style: const TextStyle(color: Colors.grey)), trailing: Text(v, style: const TextStyle(fontWeight: FontWeight.bold))));
}
