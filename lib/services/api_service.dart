import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://api-test.khmail.cn/native-api/index.php';

  Future<Map<String, dynamic>> get(String path, [Map<String, dynamic>? params]) async {
    final q = <String, String>{'path': path, 'token': 'khmail_admin'};
    (params ?? {}).forEach((k, v) { if (v != null) q[k] = v.toString(); });
    final uri = Uri.parse(baseUrl).replace(queryParameters: q);
    final res = await http.get(uri).timeout(const Duration(seconds: 20));
    final body = utf8.decode(res.bodyBytes);
    final data = jsonDecode(body);
    return data is Map<String, dynamic> ? data : {'code': 500, 'msg': 'bad_json', 'raw': body};
  }

  Future<Map<String, dynamic>> searchGoods(String keyword, {int page = 1, int pageSize = 20}) => get('v25/search-auto', {'keyword': keyword, 'page': page, 'pageSize': pageSize});
  Future<Map<String, dynamic>> goodsDetail(String id) => get('v26/goods-detail-full', {'id': id});
  Future<Map<String, dynamic>> goodsRichDetail(String id) => get('v43/goods-rich-detail', {'id': id});
  Future<Map<String, dynamic>> cartAdd(String goodsId, {String skuId = 'default', int qty = 1}) => get('v44/cart/add', {'goods_id': goodsId, 'sku_id': skuId, 'qty': qty});
  Future<Map<String, dynamic>> createOrder({required String goodsId, String skuId = 'default', int qty = 1}) => get('v28/order/create', {'goods_id': goodsId, 'sku_id': skuId, 'qty': qty});
  Future<Map<String, dynamic>> walletFull() => get('v55/wallet/full');
  Future<Map<String, dynamic>> imageSearch({String keyword = '', String? imageBase64}) => get('v25/image-search', {'keyword': keyword, if (imageBase64 != null) 'image_base64': imageBase64});
}
