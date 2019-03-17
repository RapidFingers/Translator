/// For fetch json from url
public class WebJsonClient : GLib.Object {
  /// No connection to server code
  private const int NO_CONNECTION = 2;

  /// Json parser
  private static Json.Parser _parser;
  private static Json.Parser parser {
    get {
      if (_parser == null) _parser = new Json.Parser();
      return _parser;
    }
  }

  /// Get json from url
  public static Json.Object Get(string request) throws TranslatorError {
    var session = new Soup.Session ();
    session.timeout = GlobalSettings.SERVER_RESPOND_TIMEOUT;
    session.proxy_uri = GlobalSettings.getProxyUri();

    var url = new Soup.URI(request);
    var message = new Soup.Message.from_uri ("GET", url);

    var status = session.send_message(message);
    if (status == NO_CONNECTION) {
      throw new TranslatorError.NoConnection(_("No connection to server"));
    }
    try {
      var mess = (string)message.response_body.data;
      parser.load_from_data (mess);
    }
    catch (GLib.Error error) {
        warning ("%s", error.message);
    }
      return parser.get_root ().get_object ();
  }
}
