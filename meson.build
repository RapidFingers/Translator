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

#Translate and install our .desktop file
i18n.merge_file(
    input: join_paths('data', meson.project_name() + '.desktop.in'),
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

#Translate and install our .appdata file
i18n.merge_file(
    input: join_paths('data', meson.project_name() + '.appdata.xml.in'),
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

# Install schema
install_data (
    join_paths ('data', meson.project_name () + '.gschema.xml'),
    install_dir: join_paths (get_option ('datadir'), 'glib-2.0', 'schemas'),
    rename: meson.project_name () + '.gschema.xml'
)

subdir('po')
subdir('data')

meson.add_install_script('meson/post_install.py')