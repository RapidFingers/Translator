public class Main : Object {
  private static string? source = null;
  private static string? dest = null;

  private const GLib.OptionEntry[] options = {
    { "source", 's', 0, OptionArg.STRING, ref source, "Source language", "SOURCE" },
    { "dest", 'd', 0, OptionArg.STRING, ref dest, "Destination language ", "DESTINATION" },
    { null }
  };

  public static int main (string[] args) {
    try {
        var opt_context = new OptionContext ("- Translator app");
        opt_context.set_help_enabled (true);
        opt_context.add_main_entries (options, null);
        opt_context.parse (ref args);
        var global = GlobalSettings.instance();
        var settings = new Settings ("skyprojects.eos.translator");

        var sourceLang = global.LoadSourceLang();
        var destLang = global.LoadDestLang();

        if (source != null) sourceLang = source;
        if (dest != null) destLang = dest;

        global.setSourceStartLang(sourceLang);
        global.setDestStartLang(destLang);

    } catch (OptionError e) {
      stderr.printf ("error: %s\n", e.message);
      stderr.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
      return 0;
    }

    Gtk.init (ref args);
    var app = new TranslateApplication();
    return app.run (null);
  }
}
