
// Main translator window
public class TranslateWindow : Gtk.ApplicationWindow {
    /// Timeout before translate in milliseconds
    const int TIMEOUT_BEFOR_TRANSLATE = 500;

    /// Service for translating
    private TranslateService _translateService;
    /// Dictionary service
    private DictionaryService _dictService;

    private GlobalSettings global = GlobalSettings.instance();

    //  Header layout
    private Gtk.Box _headerPane;

    private Gtk.HeaderBar _leftHeader;
    private Gtk.Button changeButton;
    private PopoverCombo leftLangCombo;
    private PopoverCombo rightLangCombo;
    //private Gtk.ListStore langStore;
    private Gtk.ToggleButton voiceButton;
    private Gtk.ToggleButton dictButton;
    //private Gtk.ToggleButton settingsButton;

    private Gtk.Separator _headerSeparator;
    private Gtk.HeaderBar _rightHeader;
    private Gtk.Entry _wordInput;
    private Gtk.Button _searchWordButton;
    private Gtk.Button _cleanButton;

    private Gtk.Box _contentBox;
    private Gtk.Box _leftBox;
    private Gtk.Box _clbuttonBox;
    private Gtk.Separator _contentSeparator;
    private Gtk.TextView topText;
    private Gtk.TextView bottomText;
    /// Translate progress spinner
    private Gtk.Spinner _progressSpinner;

    private Gtk.Label topLabelLen;
    private Gtk.Label topLabelLang;
    private Gtk.Label bottomLabelLang;

    private Gtk.Box _rightBox;
    private Gtk.TextView _dictText;
    private Gtk.TextTag _headerTag;
    private Gtk.TextTag _normalTag;
    private Gtk.Label _dictLangLabel;

    /// Toast for messages
    private Granite.Widgets.Toast _toast;

    private static int DEFAULT_WIDTH = 0;
    private static int DEFAULT_HEIGHT = 640;

    // Max size of translating text
    private const int MAX_CHARS = 500;

    private LangInfo[] langs;

    // Left language info
    private LangInfo leftLang;

    // Right language info
    private LangInfo rightLang;

    // Id of timeout
    private uint? _timeoutId = null;

    /// Text that is translating
    private string _translatingText;

    /// Is translate in progress
    private bool _isTranslating = false;

    // Create language combos
    private void languageCombo () {
        leftLangCombo = new PopoverCombo ();

        rightLangCombo = new PopoverCombo ();
        rightLangCombo.set_margin_end(10);
    }

    // Apply styles
    private void styleWindow() {
        var style = @"
            GtkTextView {
                background-color: RGBA(255,0,0,0);
            }
            GtkTextView:selected {
                background-color: #3689e6;
            }
            .dark-separator {
                color: #888;
            }
            .popovercombo {
                border: 1px solid #AAA;
                box-shadow: 1px 1px 1px #DDD;
                border-radius: 3px;
            }
        ";
        Granite.Widgets.Utils.set_theming_for_screen (this.get_screen (), style, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    /// On service error
    private void onServiceError(TranslatorError error) {
        _isTranslating = false;
        _progressSpinner.active = false;

        _toast.title = _(error.message);
        _toast.send_notification();
    }

    // Constructor
    // TODO: separate to methods
    public TranslateWindow() {
        langs = global.getLangs();

        _translateService = new TranslateService();
        _translateService.result.connect(onTranslate);
        _translateService.error.connect(onServiceError);

        _dictService = new DictionaryService();
        _dictService.result.connect(onDictResult);
        _dictService.error.connect(onServiceError);

        this.window_position = Gtk.WindowPosition.CENTER;
        this.set_gravity(Gdk.Gravity.CENTER);
        this.set_resizable(false);

        _headerPane = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        // Left header
        _leftHeader = new Gtk.HeaderBar ();
        _leftHeader.set_show_close_button (true);

        // Create language combo
        languageCombo ();

        changeButton = new Gtk.Button.from_icon_name("media-playlist-repeat-symbolic");
        changeButton.set_tooltip_text(_("Switch language"));
        changeButton.clicked.connect(onSwap);

        voiceButton = new Gtk.ToggleButton();
        voiceButton.set_tooltip_text(_("Dictation"));

        dictButton = new Gtk.ToggleButton();
        dictButton.set_image(new Gtk.Image.from_icon_name("accessories-dictionary-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
        dictButton.set_tooltip_text(_("Dictionary"));
        dictButton.toggled.connect(onDictToggle);

        //settingsButton = new Gtk.ToggleButton();
        //settingsButton.set_image (new Gtk.Image.from_icon_name("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
        //settingsButton.set_tooltip_text(_("Settings"));

        _leftHeader.pack_start(leftLangCombo);
        _leftHeader.pack_start(changeButton);
        _leftHeader.pack_start(rightLangCombo);
        _leftHeader.set_custom_title(new Gtk.Label(""));
        //_leftHeader.pack_start(voiceButton);
        _leftHeader.pack_start(dictButton);
        //_leftHeader.pack_start(settingsButton);

        // Right dictionary header
        _rightHeader = new Gtk.HeaderBar ();
        _rightHeader.set_show_close_button (false);
        _rightHeader.set_custom_title(new Gtk.Label(""));
        _wordInput = new Gtk.Entry();
        _wordInput.set_size_request(200,20);
        _wordInput.activate.connect(onDictSearch);
        _searchWordButton = new Gtk.Button.from_icon_name("edit-find-symbolic");
        _searchWordButton.set_tooltip_text(_("Search"));
        _searchWordButton.clicked.connect(onDictSearch);
        _searchWordButton.margin_end = 6;

        _rightHeader.pack_start(new Gtk.Label(_("Dictionary")));
        _rightHeader.pack_end(_searchWordButton);
        _rightHeader.pack_end(_wordInput);

        _headerSeparator = new Gtk.Separator(Gtk.Orientation.VERTICAL);
        _headerSeparator.get_style_context().add_class("dark-separator");

        _headerPane.pack_start (_leftHeader, true, true, 0);
        _headerPane.pack_start (_headerSeparator, false, false, 0);
        _headerPane.pack_start (_rightHeader, true, true, 0);
        _leftHeader.margin_start = 6;
        _leftHeader.margin_top = 6;
        _leftHeader.margin_bottom = 6;

        this.set_titlebar (_headerPane);
        this.set_size_request (DEFAULT_WIDTH, DEFAULT_HEIGHT);
        rightLangCombo.set_size_request (110, 30);
        leftLangCombo.set_size_request (110, 30);

        var fd = new Pango.FontDescription();
        fd.set_size(10000);

        // Content
        _contentBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        _leftBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        _rightBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        _clbuttonBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        _cleanButton = new Gtk.Button();
        _cleanButton.set_label(_("Clean"));
        _cleanButton.clicked.connect(onCleanList);
        _cleanButton.set_size_request(50, 0);
        _clbuttonBox.pack_start(_cleanButton, true, true);
        _contentSeparator = new Gtk.Separator(Gtk.Orientation.VERTICAL);
        _contentSeparator.get_style_context().add_class("dark-separator");
        _leftBox.set_size_request(350, 0);

        _contentBox.pack_start(_clbuttonBox, false, true);
        _contentBox.pack_start(_leftBox, false, true);
        _contentBox.pack_start(_contentSeparator, false, false);
        _contentBox.pack_start(_rightBox, true, true);

        var paned = new Gtk.Paned(Gtk.Orientation.VERTICAL);
        _leftBox.pack_start(paned);

        var topOverlay = new Gtk.Overlay();

        topText = new Gtk.TextView();
        topText.set_margin_start(7);
        topText.set_margin_top(7);
        topText.set_margin_end(7);
        //topText.override_font(fd);
        topText.set_wrap_mode(Gtk.WrapMode.WORD_CHAR);
        topText.buffer.changed.connect(onTextChange);
        var topScroll = new Gtk.ScrolledWindow (null, null);
        topScroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        topScroll.add (topText);

        _toast = new Granite.Widgets.Toast("");
        topOverlay.add(topScroll);
        topOverlay.add_overlay(_toast);

        /// Translate destination
        var bottomOverlay = new Gtk.Overlay();

        bottomText = new Gtk.TextView();
        bottomText.set_editable(false);
        bottomText.set_margin_top(7);
        bottomText.set_margin_end(7);
        bottomText.set_margin_start(7);
        //bottomText.override_font(fd);
        bottomText.set_cursor_visible(false);
        bottomText.set_wrap_mode(Gtk.WrapMode.WORD_CHAR);

        var bottomScroll = new Gtk.ScrolledWindow (null, null);
        bottomScroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        bottomScroll.add (bottomText);

        _progressSpinner = new Gtk.Spinner ();
        _progressSpinner.active = false;
        _progressSpinner.margin = 70;


        bottomOverlay.add(bottomScroll);
        bottomOverlay.add_overlay(_progressSpinner);

        var topBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        var topLabelBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        topLabelLang = new Gtk.Label("");
        topLabelLang.set_margin_bottom(3);

        topLabelLen = new Gtk.Label("");
        topLabelLen.set_markup(@"<span size=\"small\">0/$MAX_CHARS</span>");
        topLabelLen.set_margin_bottom(3);

        topLabelBox.pack_start(topLabelLang, false, true, 5);
        topLabelBox.pack_end(topLabelLen, false, true, 5);

        topBox.pack_start(topOverlay);
        topBox.pack_start(topLabelBox, false, true, 0);

        var bottomBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        var bottomLabelBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        bottomLabelLang = new Gtk.Label("");
        bottomLabelLang.set_margin_bottom(3);
        bottomLabelBox.pack_start(bottomLabelLang, false, true, 5);

        bottomBox.pack_start(bottomOverlay);
        bottomBox.pack_start(bottomLabelBox, false, true, 0);

        paned.pack1(topBox, true, true);
        paned.pack2(bottomBox, true, true);

        var dictBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        var dictLabelBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

        _dictText = new Gtk.TextView();
        _dictText.set_editable(false);
        _dictText.set_margin_top(7);
        _dictText.set_margin_end(7);
        _dictText.set_margin_start(7);
        _dictText.set_wrap_mode(Gtk.WrapMode.WORD);
        _dictText.set_cursor_visible(false);
        var dictScroll = new Gtk.ScrolledWindow (null, null);
        dictScroll.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        dictScroll.add (_dictText);

        _dictLangLabel = new Gtk.Label("");
        _dictLangLabel.set_markup(@"<span size=\"small\">en-ru</span>");
        _dictLangLabel.set_margin_bottom(3);
        dictLabelBox.pack_start(_dictLangLabel, false, true, 5);

        dictBox.pack_start(dictScroll);
        dictBox.pack_start(dictLabelBox, false, true, 0);
        _rightBox.pack_start(dictBox);
        _headerTag = _dictText.buffer.create_tag("h", null);
        _headerTag.size_points = 10;
        _headerTag.weight = 700;
        _normalTag = _dictText.buffer.create_tag("n", null);

        this.add(_contentBox);

        populateLangs();
        refreshLangLabels();

        hideDictionary();

        styleWindow();

        this.destroy.connect(onWindowDestroy);
    }

    /// On toggle dictionary panel
    private void onDictToggle() {
      if (!dictButton.active) {
        hideDictionary();
      } else {
        showDictionary();
      }
    }

    /// Show dictionary
    private void showDictionary() {
      _rightHeader.no_show_all = false;
      _rightHeader.show_all();
      _rightBox.no_show_all = false;
      _rightBox.show_all();
      _contentSeparator.no_show_all = false;
      _contentSeparator.show_all();
    }

    private void hideDictionary() {
      _rightHeader.no_show_all = true;
      _rightHeader.hide();
      _rightBox.no_show_all = true;
      _rightBox.hide();
      _contentSeparator.no_show_all = true;
      _contentSeparator.hide();
    }

    // Populate combo with languages
    private void populateLangs() {
        rightLangCombo.setLanguages (langs);
        rightLangCombo.setActive (global.getDestStartLang());
        rightLangCombo.changed.connect(onRightComboChange);

        leftLangCombo.setLanguages (langs);
        leftLangCombo.setActive (global.getSourceStartLang());
        leftLangCombo.changed.connect(onLeftComboChange);

        leftLang = getLeftLang();
        rightLang = getRightLang();
    }

    // Clear dictionary text
    private void clearDictText() {
      _wordInput.set_text("");
      _dictText.buffer.text = "";
    }

    // Clear translate text
    private void onCleanList() {
      topText.buffer.text = "";
    }


    private void refreshLangLabels() {
        var llang = getLeftLang().name;
        var rlang = getRightLang().name;
        topLabelLang.set_markup(@"<span size=\"small\">$llang</span>");
        bottomLabelLang.set_markup(@"<span size=\"small\">$rlang</span>");
        _dictLangLabel.set_markup(@"<span size=\"small\">$llang - $rlang</span>");
    }

    // Get language id from left combobox
    private LangInfo getLeftLang() {
        return leftLangCombo.getActive ();
    }

    // Get right language name
    private LangInfo getRightLang() {
        return rightLangCombo.getActive ();
    }

    // On language change
    private void onLangChange(bool isRight) {
        var leftLa = getLeftLang();
        var rightLa = getRightLang();

        var needUpdate = true;

        if (leftLa == rightLa) {
            needUpdate = false;
            if (isRight) {
                leftLang = rightLang;
                leftLangCombo.setActive(rightLang.id);
            } else {
                rightLang = leftLang;
                rightLangCombo.setActive(leftLang.id);
            }

            topText.buffer.text = bottomText.buffer.text;
        }

        if (rightLa == rightLang)
            needUpdate = false;

        if (needUpdate) {
            leftLang = leftLa;
            rightLang = rightLa;
            clearDictText();
            refreshLangLabels();
            onTextChange();
        }
    }

    /// On change value in left combobox
    private void onLeftComboChange() {
        onLangChange(false);
    }

    /// On change value in right combobox
    private void onRightComboChange(LangInfo info) {

        onLangChange(true);
    }

    // Swap languages
    private void onSwap() {
        var lang = getLeftLang();
        rightLangCombo.setActive (lang.id);
    }

    /// Start translate service
    private bool startTranslate() {
        Source.remove(_timeoutId);
        _timeoutId = null;
        if (topText.buffer.text.length < 1) {
            bottomText.buffer.text = "";
            topLabelLen.set_markup(@"<span size=\"small\">0/$MAX_CHARS</span>");
            return true;
        }

        if ((leftLang == null) || (rightLang == null)) return true;
        var len = topText.buffer.text.length;
        if (len > MAX_CHARS) {
            var txt = topText.buffer.text.slice(0, MAX_CHARS);
            topText.buffer.set_text(txt, MAX_CHARS);
            return true;
        }
        topLabelLen.set_markup(@"<span size=\"small\">$len/$MAX_CHARS</span>");

        _isTranslating = true;
        _progressSpinner.active = true;
        _translatingText = topText.buffer.text;
        _translateService.Translate(leftLang.id, rightLang.id, _translatingText);
        return true;
    }

    /// On text change in text edit
    private void onTextChange() {
        if (_isTranslating) return;

        // Stop timer
        if (_timeoutId != null) {
            Source.remove(_timeoutId);
            _timeoutId = null;
        }

        // Start new timer
        _timeoutId = Timeout.add(TIMEOUT_BEFOR_TRANSLATE, startTranslate);
    }

    /// On translate complete
    private void onTranslate(string[] text) {
        _isTranslating = false;
        _progressSpinner.active = false;

        if ((text == null) || (text.length < 1)) return;
        if (topText.buffer.text.length < 1) {
            bottomText.buffer.text = "";
            return;
        }
        bottomText.buffer.text = string.joinv("", text);

        if (_translatingText != topText.buffer.text)
            onTextChange();
    }

    // Search in dictionary
    private void onDictSearch() {
      var text = _wordInput.get_text();
      _dictService.GetWordInfo(text, leftLang.id, rightLang.id);
    }

    private void onDictResult(WordInfo data) {
      _dictText.buffer.text = "";
      Gtk.TextIter iter;
      _dictText.buffer.get_end_iter(out iter);

      foreach (var c in data.WordCategories) {
        string txt = DictionaryService.GetSpeechPart(c.Category) + "\n";

        _dictText.buffer.insert_with_tags(ref iter, txt, txt.length, _headerTag, null);
        _dictText.buffer.insert_with_tags(ref iter, "\n", 1, _normalTag, null);

        for (var i =0; i<c.Translations.length;i++) {
          var tr = c.Translations[i];
          txt = @"$(i+1). $(tr.Text)\n";
          _dictText.buffer.insert_with_tags(ref iter, txt, txt.length, _normalTag, null);
        }
        _dictText.buffer.insert_with_tags(ref iter, "\n", 1, _normalTag, null);
      }
    }

    /// On window destroy
    private void onWindowDestroy() {
      var global = GlobalSettings.instance();
      global.SaveSourceLang(leftLang.id);
      global.SaveDestLang(rightLang.id);
      base.destroy();
    }
}
