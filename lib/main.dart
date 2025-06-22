import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/item.dart';

void main() async {
  // Flutter 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();
  Hive.registerAdapter(ItemAdapter());

  // Box 열기
  await Hive.openBox<Item>('items');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'aVocaDo PWA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box<Item> itemBox;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    itemBox = Hive.box<Item>('items');
  }

  void _addItem() {
    if (_controller.text.isNotEmpty) {
      final item = Item(title: _controller.text);
      itemBox.add(item);
      _controller.clear();
      setState(() {});
    }
  }

  void _toggleItem(int index) {
    final item = itemBox.getAt(index);
    if (item != null) {
      item.isCompleted = !item.isCompleted;
      item.save();
      setState(() {});
    }
  }

  void _deleteItem(int index) {
    itemBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('aVocaDo PWA'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 입력 필드
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '새 항목 입력',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addItem, child: const Text('추가')),
              ],
            ),
          ),

          // 아이템 목록
          Expanded(
            child: ListView.builder(
              itemCount: itemBox.length,
              itemBuilder: (context, index) {
                final item = itemBox.getAt(index);
                if (item == null) return const SizedBox();

                return ListTile(
                  leading: Checkbox(
                    value: item.isCompleted,
                    onChanged: (_) => _toggleItem(index),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    '생성: ${item.createdAt.toString().substring(0, 16)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteItem(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        tooltip: '항목 추가',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
