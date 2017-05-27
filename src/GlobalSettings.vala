public class LangInfo : Object {
    public string id { get; set; }
    public string name { get; set; }
}

public class GlobalSettings : Object {
    public static int PROXY_MODE_NONE = 0;
    public static int SERVER_RESPOND_TIMEOUT = 10;
    private string TRANSLATOR_PATH = "/usr/share/translator";
    private string _sourceStartLang = "en";
    private string _destStartLang = "ru";
    private LangInfo[] _langs;
    private static GlobalSettings _instance;
    private Settings _settings;

    private GlobalSettings() {
      _settings = new Settings ("skyprojects.eos.translator");
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
            name = _("Deutsch")
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
