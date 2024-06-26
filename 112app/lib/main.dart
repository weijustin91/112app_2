import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GuessNumber(),
    );
  }
}

class GuessNumber extends StatefulWidget {
  @override
  _GuessNumberState createState() => _GuessNumberState();
}

class _GuessNumberState extends State<GuessNumber> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  late String _targetNumber;
  String _message = '';
  int _attempts = 0;
  List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  String _generateTargetNumber() {
    Random random = Random();
    Set<int> digits = {};
    while (digits.length < 4) {
      digits.add(random.nextInt(10));
    }
    return digits.join();
  }

  bool _isValidInput(String guess) {
    if (guess.length != 4) {
      _message = '請輸入一個4位數字';
      return false;
    }
    if (guess.contains(RegExp(r'[^0-9]'))) {
      _message = '請輸入數字';
      return false;
    }
    Set<String> uniqueDigits = guess.split('').toSet();
    if (uniqueDigits.length != 4) {
      _message = '請輸入4個不同的數字';
      return false;
    }
    return true;
  }

  void _checkGuess() {
    final guess = _controller.text;
    if (!_isValidInput(guess)) {
      setState(() {});
      return;
    }

    setState(() {
      _attempts++;
      int a = 0, b = 0;
      for (int i = 0; i < 4; i++) {
        if (guess[i] == _targetNumber[i]) {
          a++;
        } else if (_targetNumber.contains(guess[i])) {
          b++;
        }
      }

      if (a == 4) {
        _message = '恭喜你！你猜對了。總共嘗試了$_attempts次';
        if (_isInTopFive(_attempts)) {
          _showNameDialog();
        } else {
          _showEndDialog();
        }
      } else {
        _message = '$a A $b B';
      }
    });
  }

  bool _isInTopFive(int attempts) {
    if (_leaderboard.length < 5) {
      return true;
    } else {
      return attempts < _leaderboard.last['attempts'];
    }
  }

  void _updateLeaderboard(String name, int attempts) {
    setState(() {
      _leaderboard.add({'name': name, 'attempts': attempts});
      _leaderboard.sort((a, b) => a['attempts'].compareTo(b['attempts']));
      if (_leaderboard.length > 5) {
        _leaderboard.removeLast();
      }
    });
  }

  void _resetGame() {
    setState(() {
      _controller.clear();
      _targetNumber = _generateTargetNumber();
      _message = '';
      _attempts = 0;
    });
  }

  void _showNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("遊戲結束"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("恭喜你！你猜對了。總共嘗試了$_attempts次"),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "請輸入你的名字"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  _updateLeaderboard(_nameController.text, _attempts);
                  _nameController.clear();
                  Navigator.of(context).pop();
                  _showLeaderboard();
                }
              },
              child: Text("提交"),
            ),
          ],
        );
      },
    );
  }

  void _showEndDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("遊戲結束"),
          content: Text("恭喜你！你猜對了。總共嘗試了$_attempts次"),
          actions: [
            TextButton(
              onPressed: () {
                _resetGame();
                Navigator.of(context).pop();
              },
              child: Text("再玩一次"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showLeaderboard();
              },
              child: Text("查看排行榜"),
            ),
          ],
        );
      },
    );
  }

  void _showLeaderboard() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("排行榜"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _leaderboard
                .map((entry) => Text("${entry['name']}: ${entry['attempts']} 次"))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _resetGame();
                Navigator.of(context).pop();
              },
              child: Text("再玩一次"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('1A2B 猜數字遊戲'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '請猜一個4位不重複的數字',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '你的猜測',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkGuess,
              child: Text('提交'),
            ),
            SizedBox(height: 20),
            Text(
              _message,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '已經猜了 $_attempts 次',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              child: Text('重啟遊戲'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showLeaderboard,
              child: Text('查看排行榜'),
            ),
          ],
        ),
      ),
    );
  }
}
