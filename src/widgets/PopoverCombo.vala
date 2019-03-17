// Language data for lang dictionary
class LangData {

    // Language info
    public LangInfo info;

    // Button
    public Gtk.Widget widget;

    // Constructor
    public LangData (LangInfo info, Gtk.Widget widget) {
        this.info = info;
        this.widget = widget;
    }
}

// Combobox with popover
public class PopoverCombo : Gtk.ToggleButton {

    // Box for widgets
    private Gtk.Box box;

    // Combo label
    private new Gtk.Label label;

    // Image for combo
    private new Gtk.Image image;

    // Popover for combo
    private Gtk.Popover popover;

    // box for popover
    private Gtk.Box popBox;

    // Scroll for langs
    private Gtk.ScrolledWindow langScroll;

    // Flow for languages
    private Gtk.FlowBox langBox;

    // Dictionary with lang id
    private Gee.HashMap<string, LangData> langMap;

    // Active language
    private LangData activeLang;

    // On combo value change
    public signal void changed (LangInfo info);

    // Constructor
    public PopoverCombo () {
        box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        label = new Gtk.Label ("");

        label.halign = Gtk.Align.START;
        image = new Gtk.Image.from_icon_name("pan-down-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        image.margin_end = 4;
        box.pack_start(label, true, true);
        box.pack_start(image, false, false);
        get_style_context().add_class("button");
        get_style_context().add_class("the-button-in-the-combobox");
        add (box);

        popBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        langBox = new Gtk.FlowBox ();
        langBox.set_selection_mode (Gtk.SelectionMode.SINGLE);
        langScroll = new Gtk.ScrolledWindow (null, null);
        langScroll.add (langBox);
        popBox.pack_start (langScroll);

        popover = new Gtk.Popover (this);
        popover.position = Gtk.PositionType.BOTTOM;
        popover.set_size_request (320, 220);
        popover.add (popBox);

        popover.hide ();

        popover.closed.connect (() => {
            active = false;
        });

        toggled.connect (() => {
            if (active) {
                popover.show_all ();
                setActive (activeLang.info.id);
            } else {
                popover.hide ();
            }
        });

        langBox.child_activated.connect ((child) => {
            popover.hide ();
            child.forall ((c) => {
                var widget = c as Gtk.Widget;
                var langdata = widget.get_data<LangData> ("lang");
                setActive (langdata.info.id);
                changed (langdata.info);
            });
        });
    }

    // Set languages
    public void setLanguages (LangInfo[] langs) {
        langMap = new Gee.HashMap<string, LangData> ();

        foreach (var lang in langs) {
            var widget = new Gtk.Label (lang.name);
            widget.has_focus = false;
            widget.set_size_request (70, 30);
            langBox.add (widget);
            widget.parent.can_focus = false;
            var data = new LangData (lang, widget);
            widget.set_data ("lang", data);
            langMap[lang.id] = data;
        }
    }

    // Set active language by id
    public void setActive (string id) {
        activeLang = langMap.@get (id);
        label.label = activeLang.info.name;
        var p = activeLang.widget.parent as Gtk.FlowBoxChild;
        langBox.select_child (p);
        changed (activeLang.info);
    }

    // Get active language info
    public LangInfo getActive () {
        if (activeLang == null) return null;
        return activeLang.info;
    }
}
