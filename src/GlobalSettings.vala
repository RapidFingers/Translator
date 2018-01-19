
// Global settings
public class GlobalSettings : Object {
    public static int PROXY_MODE_NONE = 0;
    public static int SERVER_RESPOND_TIMEOUT = 10;
    public static string SCHEMA_NAME = "com.github.rapidfingers.translator";
    private string TRANSLATOR_PATH = "/usr/share/com.github.rapidfingers.translator";
    private string _sourceStartLang = "en";
    private string _destStartLang = "ru";
    private LangInfo[] _langs;
    private static GlobalSettings _instance;
    private Settings _settings;

    private GlobalSettings() {
      _settings = new Settings (SCHEMA_NAME);
    }

    public static GlobalSettings instance() {
      if (_instance != null) return _instance;
      _instance = new GlobalSettings();
      return _instance;
    }

    public void setSourceStartLang(string e) {
      var lngs = getLangs();
      foreach (var l in lngs) {
        if (l.id == e) {
          _sourceStartLang = e;
          break;
        }
      }
    }

    public string getSourceStartLang() {
      return _sourceStartLang;
    }

    public void setDestStartLang(string e) {
      var lngs = getLangs();
      foreach (var l in lngs) {
        if (l.id == e) {
          _destStartLang = e;
          break;
        }
      }
    }

    public string getDestStartLang() {
      return _destStartLang;
    }

    public static Soup.URI getProxyUri() {
        var settings = new Settings("org.gnome.system.proxy");
        var mode = settings.get_enum("mode");
        if (mode == PROXY_MODE_NONE) {
            return null;
        }

        settings = new Settings("org.gnome.system.proxy.http");
        var host = settings.get_string("host");
        var port = settings.get_int("port");
        var proxyUri = new Soup.URI(@"http://$host:$port");
        return proxyUri;
    }

    public LangInfo[] getLangs() {
        if (_langs != null) return _langs;

        var res = new Gee.ArrayList<LangInfo>();
        res.add(new LangInfo() {
            id = "en",
            name = _("English")
        });

        res.add(new LangInfo() {
            id = "ru",
            name = _("Russian")
        });

        res.add(new LangInfo() {
            id = "uk",
            name = _("Ukrainian")
        });

        res.add(new LangInfo() {
            id = "de",
            name = _("German")
        });

        res.add(new LangInfo() {
            id = "pl",
            name = _("Polish")
        });

        res.add(new LangInfo() {
            id = "fr",
            name = _("French")
        });

        res.add(new LangInfo() {
            id = "es",
            name = _("Spanish")
        });

        res.add(new LangInfo() {
            id = "nl",
            name = _("Dutch")
        });

        res.add(new LangInfo() {
            id = "it",
            name = _("Italian")
        });

        res.add(new LangInfo() {
            id = "la",
            name = _("Latin")
        });

        res.add(new LangInfo() {
            id = "el",
            name = _("Greek")
        });

        res.add(new LangInfo() {
            id = "fi",
            name = _("Finnish")
        });

        res.add(new LangInfo() {
            id = "sv",
            name = _("Swedish")
        });

        res.add(new LangInfo() {
            id = "tr",
            name = _("Turkish")
        });

        res.add(new LangInfo() {
            id = "zh",
            name = _("Chinese")
        });

        res.add(new LangInfo() {
            id = "ko",
            name = _("Korean")
        });

        res.add(new LangInfo() {
            id = "ja",
            name = _("Japanese")
        });

        res.add(new LangInfo() {
            id = "pt",
            name = _("Portuguese")
        });

        res.add(new LangInfo() {
            id = "cs",
            name = _("Czech")
        });

        res.add(new LangInfo() {
            id = "et",
            name = _("Estonian")
        });

        res.add(new LangInfo() {
            id = "sr",
            name = _("Serbian")
        });

        res.sort ((e1, e2) => {
            if (e1.name > e2.name) return 1;
            if (e1.name == e2.name) return 0;
            return -1;
        });

        _langs = res.to_array();

        return _langs;
    }

    public int getLangIndex(string langId) {
      var lngs = getLangs();
      for (var i=0; i < lngs.length; i++) {
        var l = lngs[i];
        if (l.id == langId) {          
          return i;
        }
      }
      return -1;
    }

    public string getPath(string name) {
        string path = @"$(TRANSLATOR_PATH)/$(name)";
        return path;
    }

    public string LoadSourceLang() {
      return _settings.get_string("source-lang");
    }

    public string LoadDestLang() {
      return _settings.get_string("dest-lang");
    }

    public void SaveSourceLang(string s) {
      _settings.set_string("source-lang", s);
    }

    public void SaveDestLang(string s) {
      _settings.set_string("dest-lang", s);
    }
}
