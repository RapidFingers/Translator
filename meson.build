project('com.github.rapidfingers.translator', 'vala', 'c')

i18n = import('i18n')
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

executable(
    meson.project_name(),
    'src/Main.vala',
    'src/utils/TranslatorError.vala',
    'src/LangInfo.vala',
    'src/widgets/PopoverCombo.vala',
    'src/TranslatorApplication.vala',
    'src/TranslatorWindow.vala',
    'src/GlobalSettings.vala',
    'src/AsyncTaskExecuter.vala',
    'src/TranslatorService.vala',
    'src/DictionaryService.vala',
    'src/WebJsonClient.vala',
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('gdk-3.0'),
        dependency('json-glib-1.0'),
        dependency('libsoup-2.4'),
        dependency('granite')
    ],
    install: true
)

subdir('po')
subdir('data')

meson.add_install_script('meson/post_install.py')