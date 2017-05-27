public class WordTranslation {
  public string Text;
  public string Category;
  public string[] Examples;
  public string[] Synonyms;
  public string[] Means;
}

public class WordCategory {
  public string Category;
  public string Transcription;
  public WordTranslation[] Translations;
}

public class WordInfo {
  public WordCategory[] WordCategories;
}

// Service that get word's info from Yandex dictionary service
public class DictionaryService : AsyncTaskExecuter {
  private const string API_KEY = "dict.1.1.20150726T191533Z.aa2d3a3f5122d94c.aa319cbc89e74736fb2a2ec874c31610796ad862&ui=en";
  private string _word;
  private WordInfo _result;
  private string _sourceLang;
  private string _destLang;

  public signal void result(WordInfo data);

  public DictionaryService() {
    base();
    ExecuteTimeout = 0;
  }

  public static string GetSpeechPart(string s) {
    switch (s) {
      case "noun":        
        return _("Noun");
      case "adverb":
          return _("Adverb");
      case "verb":
        return _("Verb");
      case "adjective":
        return _("Adjective");
      case "pronoun":
        return _("Pronoun");
      case "conjunction":
        return _("Conjunction");
      case "particle":
        return _("Particle");
      case "participle":
        return _("Participle");
      case "adverbial participle":
        return _("AdverbialParticiple");
    }

    return s;
  }

  public override void OnExecute() {
    var word = Soup.URI.encode(_word, null);
    var request = @"https://dictionary.yandex.net/api/v1/dicservice.json/lookup?key=$(API_KEY)&lang=$(_sourceLang)-$(_destLang)&text=$(word)&ui=en";
    var root = WebJsonClient.Get(request);

    if (root != null) {
        var defs = root.get_array_member("def");

        if (defs != null) {
          var cats = new Gee.ArrayList<WordCategory>();
          foreach (var el1 in defs.get_elements()) {
            var obj1 = el1.get_object();
            var cat = new WordCategory();
            cat.Category = obj1.get_string_member("pos");
            cat.Transcription = obj1.get_string_member("ts");

            var trs = obj1.get_array_member("tr");
            if (trs == null) continue;
            var trList = new Gee.ArrayList<WordTranslation>();
            foreach (var el2 in trs.get_elements()) {
              var obj2 = el2.get_object();
              var tr = new WordTranslation();
              tr.Text = obj2.get_string_member("text");
              tr.Category = obj2.get_string_member("pos");
              trList.add(tr);
            }
            cat.Translations = trList.to_array();
            cats.add(cat);
          }

          _result = new WordInfo();
          _result.WordCategories = cats.to_array();
        }
    }
  }

  public override void OnResult() {
    if (_result != null) result(_result);
  }

  public void GetWordInfo(string word, string sourceLang, string destLang) {
    _word = word;
    _sourceLang = sourceLang;
    _destLang = destLang;
    Run();
  }
}
