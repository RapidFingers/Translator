internal class TranslateApplication : Granite.Application {
    public TranslateWindow mainWindow;

    public TranslateApplication() {
        GLib.Object(application_id: "skyprojects.eos.translate", flags: ApplicationFlags.HANDLES_OPEN);
    }

    public override void activate () {
        if (this.get_windows() == null) {
            this.mainWindow = new TranslateWindow();
            this.mainWindow.set_application(this);
        }

        this.mainWindow.show_all();
    }
}
