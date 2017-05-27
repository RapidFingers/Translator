public class Assets : GLib.Object {    
    public static Gtk.Image getImage(string name) {
        var global = GlobalSettings.instance();
        return new Gtk.Image.from_file(global.getPath(name));
    }
}
