import 'dart:math';

distance(num x1, num y1, num x2, num y2) {
  return (x1 - x2).abs() + (y1 - y2).abs();
}

weightedAverage(List<num> weights, List<num> values) {
  num temp = 0;
  for (var k = 0; k < weights.length; k++) {
    temp += weights[k] * values[k];
  }

  if (temp < 0 || temp > 1) {
    print("Error: " + values.toString());
  }

  return temp;
}

computeScore1(num connections, String word) {
  return connections / (word.length / 2);
}

computeScore2(num rows, num cols, num i, num j) {
  return 1 - distance(rows / 2, cols / 2, i, j) / (rows / 2 + cols / 2);
}

computeScore3(num a, num b, num verticalCount, num totalCount) {
  if (verticalCount > totalCount / 2) {
    return a;
  } else if (verticalCount < totalCount / 2) {
    return b;
  } else {
    return 0.5;
  }
}

computeScore4(num val, String word) {
  return word.length / val;
}

addWord(List<dynamic> best, List<dynamic> words, List<List<String>> table) {
  num bestScore = best[0];
  String word = best[1];
  int index = best[2];
  int bestI = best[3];
  int bestJ = best[4];
  int bestO = best[5];

  words[index]['startx'] = bestJ + 1;
  words[index]['starty'] = bestI + 1;

  if (bestO == 0) {
    for (var k = 0; k < word.length; k++) {
      table[bestI][bestJ + k] = word[k];
    }
    words[index]['orientation'] = "across";
  } else {
    for (var k = 0; k < word.length; k++) {
      table[bestI + k][bestJ] = word[k];
    }
    words[index]['orientation'] = "down";
  }
  // print('$word, $bestScore');
}

void assignPositions(List<dynamic> words) {
  var positions = {};
  for (var index in words.asMap().keys) {
    var word = words[index];
    if (word['orientation'] != "none") {
      var tempStr = '${word['starty']},${word['startx']}';
      if (positions.containsKey(tempStr)) {
        word['position'] = positions[tempStr];
      } else {
        positions[tempStr] = positions.length + 1;
        word['position'] = positions[tempStr];
      }
    }
  }
}

computeDimension(words, factor) {
  num temp = 0;
  for (int i = 0; i < words.length; i++) {
    if (temp < words[i]["answer"]!.length) {
      temp = words[i]["answer"]!.length;
    }
  }
  return temp * factor;
}

initTable(int rows, int cols) {
  List<List<String>> table = [];
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (j == 0) {
        table.add(["-"]);
      } else {
        table[i].add("-");
      }
    }
  }
  return table;
}

bool isConflict(
    List<List<String>> table, bool isVertical, String character, int i, int j) {
  if (character != table[i][j] && table[i][j] != "-") {
    return true;
  } else if (table[i][j] == "-" &&
      !isVertical &&
      i + 1 < table.length &&
      table[i + 1][j] != "-") {
    return true;
  } else if (table[i][j] == "-" &&
      !isVertical &&
      i - 1 >= 0 &&
      table[i - 1][j] != "-") {
    return true;
  } else if (table[i][j] == "-" &&
      isVertical &&
      j + 1 < table[i].length &&
      table[i][j + 1] != "-") {
    return true;
  } else if (table[i][j] == "-" &&
      isVertical &&
      j - 1 >= 0 &&
      table[i][j - 1] != "-") {
    return true;
  } else {
    return false;
  }
}

isIn(key, obj) {
  bool ret = true;
  try {
    ret = obj[key] != null;
  } catch (e) {
    ret = false;
  }
  return ret;
}

attemptToInsert(num rows, num cols, List<List<String>> table, List<num> weights,
    num verticalCount, num totalCount, String word, num index) {
  var bestI = 0;
  var bestJ = 0;
  var bestO = 0;
  var bestScore = -1.0;

  for (var i = 0; i < rows; i++) {
    for (var j = 0; j < cols - word.length + 1; j++) {
      bool isValid = true;
      bool atleastOne = false;
      var connections = 0;
      bool prevFlag = false;

      for (var k = 0; k < word.length; k++) {
        if (isConflict(table, false, word[k], i, j + k)) {
          isValid = false;
          break;
        } else if (table[i][j + k] == "-") {
          prevFlag = false;
          atleastOne = true;
        } else {
          if (prevFlag) {
            isValid = false;
            break;
          } else {
            prevFlag = true;
            connections += 1;
          }
        }
      }

      if (isIn((j - 1), table[i]) && table[i][j - 1] != "-") {
        isValid = false;
      } else if (j + word.length < cols && table[i][j + word.length] != "-") {
        isValid = false;
      }

      if (isValid && atleastOne && word.length > 1) {
        var tempScore1 = computeScore1(connections, word);
        var tempScore2 = computeScore2(rows, cols, i, j + word.length / 2);
        var tempScore3 = computeScore3(1, 0, verticalCount, totalCount);
        var tempScore4 = computeScore4(rows, word);
        var tempScore = weightedAverage(
            weights, [tempScore1, tempScore2, tempScore3, tempScore4]);

        if (tempScore > bestScore) {
          bestScore = tempScore;
          bestI = i;
          bestJ = j;
          bestO = 0;
        }
      }
    }
  }

  for (int i = 0; i < rows - word.length + 1; i++) {
    for (int j = 0; j < cols; j++) {
      bool isValid = true;
      bool atleastOne = false;
      int connections = 0;
      bool prevFlag = false;

      for (int k = 0; k < word.length; k++) {
        if (isConflict(table, true, word[k], i + k, j)) {
          isValid = false;
          break;
        } else if (table[i + k][j] == "-") {
          prevFlag = false;
          atleastOne = true;
        } else {
          if (prevFlag) {
            isValid = false;
            break;
          } else {
            prevFlag = true;
            connections += 1;
          }
        }
      }

      if ((i - 1) >= 0 && table[i - 1][j] != "-") {
        isValid = false;
      } else if ((i + word.length) < table.length &&
          table[i + word.length][j] != "-") {
        isValid = false;
      }

      if (isValid && atleastOne && word.length > 1) {
        var tempScore1 = computeScore1(connections, word);
        var tempScore2 =
            computeScore2(rows, cols, i + (word.length / 2).floor(), j);
        var tempScore3 = computeScore3(0, 1, verticalCount, totalCount);
        var tempScore4 = computeScore4(rows, word);
        var tempScore = weightedAverage(
            weights, [tempScore1, tempScore2, tempScore3, tempScore4]);

        if (tempScore > bestScore) {
          bestScore = tempScore;
          bestI = i;
          bestJ = j;
          bestO = 1;
        }
      }
    }
  }
  if (bestScore > -1) {
    return [bestScore, word, index, bestI, bestJ, bestO];
  } else {
    return [-1];
  }
}

generateTable(List<List<String>> table, int rows, int cols,
    List<Map<String, dynamic>> words, weights) {
  var verticalCount = 0;
  var totalCount = 0;

  for (var outerIndex = 0; outerIndex < words.length; outerIndex++) {
    List best = [-1];
    for (var innerIndex = 0; innerIndex < words.length; innerIndex++) {
      if (words[innerIndex].containsKey("answer") &&
          !words[innerIndex].containsKey("startx")) {
        var temp = attemptToInsert(rows, cols, table, weights, verticalCount,
            totalCount, words[innerIndex]["answer"], innerIndex);
        if (temp[0] > best[0]) {
          best = temp;
        }
      }
    }

    if (best[0] == -1) {
      break;
    } else {
      addWord(best, words, table);
      if (best[5] == 1) {
        verticalCount += 1;
      }
      totalCount += 1;
    }
  }

  for (var index = 0; index < words.length; index++) {
    if (!words[index].containsKey("startx")) {
      words[index]["orientation"] = "none";
    }
  }

  return {"table": table, "result": words};
}

removeIsolatedWords(data) {
  var oldTable = data['table'];
  var words = data['result'];
  int rows = oldTable.length;
  int cols = oldTable[0].length;
  var newTable = initTable(rows, cols);

  for (int wordIndex = 0; wordIndex < words.length; wordIndex++) {
    var word = words[wordIndex];
    if (word['orientation'] == 'across') {
      int i = word['starty'] - 1;
      int j = word['startx'] - 1;
      for (int k = 0; k < word['answer'].length; k++) {
        if (newTable[i][j + k] == '-') {
          newTable[i][j + k] = 'O';
        } else if (newTable[i][j + k] == 'O') {
          newTable[i][j + k] = 'X';
        }
      }
    } else if (word['orientation'] == 'down') {
      int i = word['starty'] - 1;
      int j = word['startx'] - 1;
      for (int k = 0; k < word['answer'].length; k++) {
        if (newTable[i + k][j] == '-') {
          newTable[i + k][j] = 'O';
        } else if (newTable[i + k][j] == 'O') {
          newTable[i + k][j] = 'X';
        }
      }
    }
  }

  for (int wordIndex = 0; wordIndex < words.length; wordIndex++) {
    Map<String, dynamic> word = words[wordIndex];
    bool isIsolated = true;
    if (word['orientation'] == 'across') {
      int i = word['starty'] - 1;
      int j = word['startx'] - 1;
      for (int k = 0; k < word['answer'].length; k++) {
        if (newTable[i][j + k] == 'X') {
          isIsolated = false;
          break;
        }
      }
    } else if (word['orientation'] == 'down') {
      int i = word['starty'] - 1;
      int j = word['startx'] - 1;
      for (int k = 0; k < word['answer'].length; k++) {
        if (newTable[i + k][j] == 'X') {
          isIsolated = false;
          break;
        }
      }
    }
    if (word['orientation'] != 'none' && isIsolated) {
      words[wordIndex].remove('startx');
      words[wordIndex].remove('starty');
      words[wordIndex].remove('position');
      words[wordIndex]['orientation'] = 'none';
    }
  }

  newTable = initTable(rows, cols);
  for (var wordIndex = 0; wordIndex < words.length; wordIndex++) {
    var word = words[wordIndex];
    if (word['orientation'] == "across") {
      var i = word['starty'] - 1;
      var j = word['startx'] - 1;
      for (var k = 0; k < word['answer'].length; k++) {
        newTable[i][j + k] = word['answer'][k];
      }
    } else if (word['orientation'] == "down") {
      var i = word['starty'] - 1;
      var j = word['startx'] - 1;
      for (var k = 0; k < word['answer'].length; k++) {
        newTable[i + k][j] = word['answer'][k];
      }
    }
  }

  return {'table': newTable, 'result': words};
}

trimTable(data) {
  List<List<String>> table = data['table'];
  int rows = table.length;
  int cols = table[0].length;

  int leftMost = cols;
  int topMost = rows;
  int rightMost = -1;
  int bottomMost = -1;

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (table[i][j] != "-") {
        int x = j;
        int y = i;

        if (x < leftMost) {
          leftMost = x;
        }
        if (x > rightMost) {
          rightMost = x;
        }
        if (y < topMost) {
          topMost = y;
        }
        if (y > bottomMost) {
          bottomMost = y;
        }
      }
    }
  }

  var trimmedTable =
      initTable(bottomMost - topMost + 1, rightMost - leftMost + 1);
  for (int i = topMost; i < bottomMost + 1; i++) {
    for (int j = leftMost; j < rightMost + 1; j++) {
      trimmedTable[i - topMost][j - leftMost] = table[i][j];
    }
  }

  var words = data['result'];
  for (var word in words) {
    if (isIn("startx", word)) {
      word["startx"] -= leftMost;
      word["starty"] -= topMost;
    }
  }

  return {
    "table": trimmedTable,
    "result": words,
    "rows": max(bottomMost - topMost + 1, 0),
    "cols": max(rightMost - leftMost + 1, 0)
  };
}

String tableToString(List<List<String>> table, String delim) {
  int rows = table.length;
  if (rows >= 1) {
    int cols = table[0].length;
    String output = "";
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        output += table[i][j];
      }
      output += delim;
    }
    return output;
  } else {
    return "";
  }
}

generateSimpleTable(words) {
  var rows = computeDimension(words, 3);
  var cols = rows;
  var blankTable = initTable(rows, cols);
  var table =
      generateTable(blankTable, rows, cols, words, [0.7, 0.15, 0.1, 0.05]);
  var newTable = removeIsolatedWords(table);
  var finalTable = trimTable(newTable);
  assignPositions(finalTable['result']);
  return finalTable;
}

generateLayout(List<Map<String, dynamic>> wordsJson) {
  Map<String, dynamic> layout = generateSimpleTable(wordsJson);
  layout['table_string'] = tableToString(layout['table'], '<br>');
  return layout;
}

inverse_str(String str) {
  return str.split("").reversed.join("");
}

void main(List<String> args) {
  var w = [
    "chat",
    "chien",
    "oiseau",
    "maison",
    "voiture",
  ];
  ;
  var words = w
      .map((e) => ({
            "answer": Random().nextDouble() > 0.5 ? e : inverse_str(e),
            "clue": "",
          }))
      .toList();

  var gn = generateLayout(words)["table"];

  print("${gn[0].length}x${gn.length}");
  for (var row in gn) {
    print(row);
  }
}
