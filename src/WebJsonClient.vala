public class WebJsonClient : GLib.Object {
  private static Json.Parser _parser;

  private static Json.Parser parser {
    get {
      if (_parser == null) _parser = new Json.Parser();
      return _parser;
    }
  }

  public static Json.Object Get(string request) {
    var session = new Soup.SessionSync ();
    session.timeout = GlobalSettings.SERVER_RESPOND_TIMEOUT;
    session.proxy_uri = GlobalSettings.getProxyUri();

    var url = new Soup.URI(request);
    var message = new Soup.Message.from_uri ("GET", url);

    var status = session.send_message (message);
    var mess = (string)message.response_body.data;
    parser.load_from_data (mess);    
    return parser.get_root ().get_object ();
  }
}
