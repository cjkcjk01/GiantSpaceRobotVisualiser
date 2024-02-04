class WordPacks {
  ArrayList<WordPack> words;
  int currentWordPack;
  int wordCount;
  boolean wordsOn;
  color wordColor;
  int alpha;

  WordPacks() {
    words = new ArrayList<WordPack>();
    currentWordPack = 0;
    wordsOn = false;
    wordCount = 0;
    alpha = 150;
    wordColor = color(0);
  }

  void addWords(String[] wp) {
    words.add(new WordPack(wp));
    wordCount = words.size();
  }

  void setCurrentPack(int midiValue) {
    if (midiValue == 127|midiValue==0) {
      unCueWord();
    } else {
      if (midiValue <= wordCount) {
        currentWordPack = midiValue - 1;
        words.get(currentWordPack).reset();
        wordsOn = true;
      }
    }
  }

  void display() {
    if (wordsOn) {
      words.get(currentWordPack).draw(alpha);
    }
  }

  void nextWord() {
    words.get(currentWordPack).cueWord();
  }

  void unCueWord() {
    wordsOn = false;
  }

  void setAlpha(int a) {
    alpha = round(map(a, 0, 127, 0, 255));
  }
}

class WordPack {
  String[] words;
  int      currentWord;
  int      wordCount;

  WordPack(String[] wp) {
    words = wp;
    wordCount = words.length -1;
    currentWord = 0;
  }

  void draw(int a) {

    pushMatrix();
    textAlign(CENTER, CENTER);
    if (myBgPalette.getBlackOrWhite()) {
      fill(0, a);
    } else {
      fill(255, a);
    }
    textFont(font, 200);
    text(words[currentWord], width/2, height/2);
    popMatrix();
  }

  void cueWord() {
    currentWord++;
    if (currentWord > wordCount) {
      currentWord = 0;
    }
  }

  void reset() {
    currentWord = 0;
  }
}
