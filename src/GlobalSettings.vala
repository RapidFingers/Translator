// Global settings
public class GlobalSettings : Object {
    /// No proxy mode
    public static int PROXY_MODE_NONE = 0;

    /// Timeout for server respond
    public static int SERVER_RESPOND_TIMEOUT = 10;

    /// Name of settings schema
    public static string SCHEMA_NAME = "com.github.rapidfingers.translator";

    /// Path of translator
    /// TODO: remove
    private string TRANSLATOR_PATH = "/usr/share/com.github.rapidfingers.translator";

    /// Source lang
    private string _sourceStartLang = "en";

    /// Destination lang
    private string _destStartLang = "ru";

    /// Possible languages
    private Gee.ArrayList<LangInfo> _langs;

    /// Settings of app
    private Settings _settings;

    /// Instance
    private static GlobalSettings _instance;

    /// Add language to list
    private void addLang(string id, string name) {
        _langs.add(new LangInfo() {
            id = id,
            name = _(name)
        });
    }

    /// Init languages
    private void initLanguages() {
        _langs = new Gee.ArrayList<LangInfo>();
        addLang("en", _("English"));
		addLang("ar", _("Arabic"));
		addLang("zh", _("Chinese"));
		addLang("fr", _("French"));
		addLang("de", _("German"));
		addLang("hi", _("Hindi"));
		addLang("ga", _("Irish"));
		addLang("it", _("Italian"));
		addLang("ja", _("Japanese"));
		addLang("ko", _("Korean"));
		addLang("pt", _("Portuguese"));
		addLang("ru", _("Russian"));
        addLang("es", _("Spanish"));
		//Added from Yandex Arabic Hindi, Irish
		//Langages lost from Yandex :
        /*addLang("uk", _("Ukrainian"));
        addLang("pl", _("Polish"));
        addLang("nl", _("Dutch"));
        addLang("la", _("Latin"));
        addLang("el", _("Greek"));
        addLang("fi", _("Finnish"));
        addLang("sv", _("Swedish"));
        addLang("tr", _("Turkish"));
        addLang("cs", _("Czech"));
        addLang("et", _("Estonian"));
        addLang("sr", _("Serbian"));
        addLang("sk", _("Slovak")); */

        _langs.sort ((e1, e2) => {
            if (e1.name > e2.name) return 1;
            if (e1.name == e2.name) return 0;
            return -1;
        });
    }

    /// Private constructor
    private GlobalSettings() {
      _settings = new Settings (SCHEMA_NAME);
      initLanguages();
    }

    /// Get instance of global settings
    public static GlobalSettings instance() {
      if (_instance != null) return _instance;
      _instance = new GlobalSettings();
      return _instance;
    }

    /// Set start language for source
    public void setSourceStartLang(string e) {
      var lngs = getLangs();
      foreach (var l in lngs) {
        if (l.id == e) {
          _sourceStartLang = e;
          break;
        }
      }
    }

    /// Return start source language
    public string getSourceStartLang() {
      return _sourceStartLang;
    }

    /// Set destination start language
    public void setDestStartLang(string e) {
      var lngs = getLangs();
      foreach (var l in lngs) {
        if (l.id == e) {
          _destStartLang = e;
          break;
        }
      }
    }

    /// Return destination start language
    public string getDestStartLang() {
      return _destStartLang;
    }

    /// Return uri for proxy
    /// Get proxy settings from system
    public static Soup.URI getProxyUri() {
        var settings = new Settings("org.gnome.system.proxy");
        var mode = settings.get_enum("mode");
        if (mode == PROXY_MODE_NONE) {
            var proxyUri = new Soup.URI(@"");
            return proxyUri;
        }

        settings = new Settings("org.gnome.system.proxy.http");
        var host = settings.get_string("host");
        var port = settings.get_int("port");
        var proxyUri = new Soup.URI(@"http://$host:$port");
        return proxyUri;
    }

    /// Return possible lang array
    public LangInfo[] getLangs() {
        return _langs.to_array();
    }

    /// Return language index
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

    /// TODO: Remove?
    public string getPath(string name) {
        string path = @"$(TRANSLATOR_PATH)/$(name)";
        return path;
    }

    /// Get source lang from settings
    public string LoadSourceLang() {
      return _settings.get_string("source-lang");
    }

    /// Get destination lang from settings
    public string LoadDestLang() {
      return _settings.get_string("dest-lang");
    }

    /// Save source lang to settings
    public void SaveSourceLang(string s) {
      _settings.set_string("source-lang", s);
    }

    /// Save destination lang to settings
    public void SaveDestLang(string s) {
      _settings.set_string("dest-lang", s);
    }
}
