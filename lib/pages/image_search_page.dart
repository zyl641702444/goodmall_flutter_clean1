import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ImageSearchPage extends StatefulWidget {
  const ImageSearchPage({super.key});
  @override
  State<ImageSearchPage> createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage> {
  final api = ApiService();
  final ctrl = TextEditingController();
  String log = 'taobao_imgsearch_ready\n当前后端已预留 uploadImage + itemImgSearch；本页先用关键词兜底，下一阶段接相机/相册插件。';

  Future<void> run() async {
    final res = await api.imageSearch(keyword: ctrl.text.trim());
    setState(() => log = const JsonEncoder.withIndent('  ').convert(res));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('拍照/图片搜索')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(gradient: const LinearGradient(colors:[Color(0xff2563eb), Color(0xff06b6d4)]), borderRadius: BorderRadius.circular(24)),
        child: Column(children: [
          const Icon(Icons.camera_alt, size: 58, color: Colors.white),
          const SizedBox(height: 12),
          const Text('Image Search Bridge', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('当前先调用新系统 native-api 图片搜索桥接；后续接入相机/相册上传 base64。', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          TextField(controller: ctrl, decoration: const InputDecoration(filled: true, fillColor: Colors.white, hintText: '输入关键词兜底测试', border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(16))))),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: run, child: const Text('搜索相似商品')),
        ]),
      ),
      const SizedBox(height: 20),
      Text(log),
    ]),
  );
}
