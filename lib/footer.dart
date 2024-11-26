import 'package:flutter/material.dart';
import 'companion_search.dart';

class AppFooter extends StatefulWidget {
  @override
  _AppFooterState createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  int _selectedIndex = 0;

  final Map<int, List<Map<String, String>>> _dropdownItems = {
    0: [
      {'label': '募集登録', 'image': 'https://haratetsuo.com/wp/wp-content/uploads/2023/02/bonoron.jpg'},
      {'label': '募集の検索', 'image': 'https://haratetsuo.com/wp/wp-content/uploads/2023/02/bonoron.jpg'},
      {'label': '募集の編集', 'image': 'https://haratetsuo.com/wp/wp-content/uploads/2023/02/bonoron.jpg'},
    ],
    1: [
      {'label': 'チケット販売', 'image': 'https://haratetsuo.com/wp/wp-content/uploads/2023/02/bonoron.jpg'},
      {'label': 'チケット購入', 'image': 'https://haratetsuo.com/wp/wp-content/uploads/2023/02/bonoron.jpg'},
      {'label': '所持チケット', 'image': 'https://haratetsuo.com/wp/wp-content/uploads/2023/02/bonoron.jpg'},
    ],
    2: [
      {'label': 'レポート作成', 'image': 'https://haratetsuo.com/wp/wp-content/uploads/2023/02/bonoron.jpg'},
      {'label': 'レポート編集', 'image': 'https://haratetsuo.com/wp/wp-content/uploads/2023/02/bonoron.jpg'},
    ],
    3: [
      {'label': 'メッセージ一覧', 'image': 'https://haratetsuo.com/wp/wp-content/uploads/2023/02/bonoron.jpg'},
    ],
  };
void _onItemTapped(int index) async {
  final items = _dropdownItems[index];
  if (items != null) {
    await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 画像を均等に配置
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(items.length, (int index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () {
                    // アイテムに応じた遷移処理
                    if (item['label'] == '募集の検索') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CompanionSearchApp()), // ここで遷移先の画面を設定
                      );
                    } else {
                      // その他のアイテムはボトムシートを閉じる
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 画像を収めるContainer
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width / 3.5, // 親幅に対して最大幅を設定
                            maxHeight: 100, // 高さも最大値を設定
                          ),
                          child: Image.network(
                            item['image']!,
                            fit: BoxFit.cover, // アスペクト比を保ちつつ枠内に収める
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ラベル
                        Text(
                          item['label']!,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  setState(() {
    _selectedIndex = index;
  });
}


  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.people),
              onPressed: () {
                _onItemTapped(0); // 同行者タブ
              },
            ),
            IconButton(
              icon: Icon(Icons.confirmation_number),
              onPressed: () {
                _onItemTapped(1); // チケットタブ
              },
            ),
            IconButton(
              icon: Icon(Icons.pending_actions),
              onPressed: () {
                _onItemTapped(2); // レポートタブ
              },
            ),
            IconButton(
              icon: Icon(Icons.chat),
              onPressed: () {
                _onItemTapped(3); // チャットタブ
              },
            ),
          ],
        ),
      ),
    );
  }
}
