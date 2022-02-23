#!/usr/bin/env python
import os
import shutil
import subprocess
from docutils import nodes
from docutils.parsers.rst import directives
from sphinx.util.docutils import SphinxDirective
from sphinx.util.logging import getLogger


# ------------------------------------------------------------------------------
# `.. flutter-app::` directive
# ------------------------------------------------------------------------------

class FlutterAppDirective(SphinxDirective):
    """
    Embed Flutter apps into documentation pages.

    This extension allows inserting precompiled Flutter apps into the
    generated documentation. The app to be inserted has to be configured for
    compiling in 'web' mode.

    Example of usage in Markdown:

        ```{flutter-app}
        :sources: ../../tetris-tutorial
        :page: page3
        :show: popup
        ```

    The following arguments are supported:
      :sources: - the directory where the app is located, i.e. the directory
        with the pubspec.yaml file of the app. The path should be relative to
        the `doc/_sphinx` folder.

      :page: - an additional parameter that will be appended to the URL of the
        app. The app can retrieve this parameter by checking the property
        `window.location.search` (where `window` is from `dart:html`), and then
        display the content based on that. Thus, this parameter allows bundling
        multiple separate Flutter widgets into one compiled app.
        In addition, the "code" run mode will try to locate a file or a folder
        with the matching name.

      :show: - a list of one or more run modes, which could include "widget",
        "popup", and "code". Each of these modes produces a different output:
          "widget" - an iframe shown directly inside the docs page;
          "popup" - a [Run] button which opens the app to (almost) fullscreen;
          "code" - (NYI) opens a popup showing the code that was compiled.
    """
    has_content = False
    required_arguments = 0
    optional_arguments = 0
    option_spec = {
        'sources': directives.unchanged,
        'page': directives.unchanged,
        'show': directives.unchanged,
    }
    # Static list of targets that were already compiled during the build
    COMPILED = []

    def __init__(self, *args, **kwds):
        super().__init__(*args, **kwds)
        self.modes = None
        self.logger = None
        self.app_name = None
        self.source_dir = None
        self.source_build_dir = None
        self.target_dir = None
        self.html_dir = None

    def run(self):
        self.logger = getLogger('flutter-app')
        self._process_show_option()
        self._process_sources_option()
        self.source_build_dir = os.path.join(self.source_dir, 'build', 'web')
        self.app_name = os.path.basename(self.source_dir)
        self.html_dir = '_static/apps/' + self.app_name
        self.target_dir = os.path.abspath(
            os.path.join('..', '_build', 'html', self.html_dir))
        self._ensure_compiled()

        page = self.options.get('page', '')
        iframe_url = self.html_dir + '/index.html?' + page
        result = []
        if 'popup' in self.modes:
            result.append(Button(
                '',
                nodes.Text('Run'),
                classes=['flutter-app-button', 'popup'],
                onclick=f'run_flutter_app("{iframe_url}")',
            ))
        if 'code' in self.modes:
            pass
        if 'widget' in self.modes:
            result.append(IFrame(src=iframe_url))
        return result

    def _process_show_option(self):
        argument = self.options.get('show')
        if argument:
            values = argument.split()
            for value in values:
                if value not in ['widget', 'popup', 'code']:
                    raise self.error('Invalid :show: value ' + value)
            self.modes = values
        else:
            self.modes = ['widget']

    def _process_sources_option(self):
        argument = self.options.get('sources', '')
        abspath = os.path.abspath(argument)
        if not argument:
            raise self.error('Missing required argument :sources:')
        if not os.path.isdir(abspath):
            raise self.error(
                f'sources=`{abspath}` does not exist or is not a directory')
        assert not abspath.endswith('/')
        self.source_dir = abspath

    def _ensure_compiled(self):
        need_compiling = (
            ('popup' in self.modes or 'widget' in self.modes) and
            self.source_dir not in FlutterAppDirective.COMPILED
        )
        if not need_compiling:
            return
        self.logger.info('Compiling Flutter app ' + self.app_name)
        self._compile_source()
        self._copy_compiled()
        self._create_index()
        self.logger.info('  + copied into ' + self.target_dir)
        assert os.path.isfile(self.target_dir + '/main.dart.js')
        assert os.path.isfile(self.target_dir + '/index.html')
        FlutterAppDirective.COMPILED.append(self.source_dir)

    def _compile_source(self):
        try:
            subprocess.run(
                ['flutter', 'build', 'web', '--web-renderer', 'html'],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                cwd=self.source_dir,
                check=True,
            )
        except subprocess.CalledProcessError as e:
            cmd = e.cmd.join(' ')
            raise self.severe(
                f'Command `{cmd}` returned with exit status {e.returncode}\n' +
                e.output.decode('utf-8'),
            )

    def _copy_compiled(self):
        assert os.path.isdir(self.source_build_dir)
        main_js = os.path.join(self.source_build_dir, 'main.dart.js')
        assets_dir = os.path.join(self.source_build_dir, 'assets')
        os.makedirs(self.target_dir, exist_ok=True)
        shutil.copy2(main_js, self.target_dir)
        if os.path.exists(assets_dir):
            shutil.copytree(
                src=assets_dir,
                dst=os.path.join(self.target_dir, 'assets'),
                dirs_exist_ok=True,
            )

    def _create_index(self):
        target_file = os.path.join(self.target_dir, 'index.html')
        with open(target_file, 'wt') as out:
            out.write('<!DOCTYPE html>\n')
            out.write('<html>\n<head>\n')
            out.write('<base href="/%s/">\n' % self.html_dir)
            out.write('<title>%s</title>\n' % self.app_name)
            out.write('</head>\n<body>\n')
            out.write('<script src="main.dart.js"></script>\n')
            out.write('</body>\n</html>\n')


# ------------------------------------------------------------------------------
# Nodes
# ------------------------------------------------------------------------------

class IFrame(nodes.Element, nodes.General):
    pass


def visit_iframe(self, node):
    self.body.append(self.starttag(node, 'iframe', src=node.attributes['src']))


def depart_iframe(self, _):
    self.body.append('</iframe>')


class Button(nodes.Element, nodes.General):
    pass


def visit_button(self, node):
    attrs = {}
    if 'onclick' in node.attributes:
        attrs['onclick'] = node.attributes['onclick']
    self.body.append(self.starttag(node, 'button', **attrs).strip())


def depart_button(self, _):
    self.body.append('</button>')


# ------------------------------------------------------------------------------
# Extension setup
# ------------------------------------------------------------------------------

def setup(app):
    base_dir = os.path.dirname(__file__)
    target_dir = os.path.abspath('../_build/html/_static/')
    os.makedirs(target_dir, exist_ok=True)
    shutil.copy(os.path.join(base_dir, 'flutter_app.js'), target_dir)
    shutil.copy(os.path.join(base_dir, 'flutter_app.css'), target_dir)

    app.add_node(IFrame, html=(visit_iframe, depart_iframe))
    app.add_node(Button, html=(visit_button, depart_button))
    app.add_directive('flutter-app', FlutterAppDirective)
    app.add_js_file('flutter_app.js')
    app.add_css_file('flutter_app.css')
    return {
        'parallel_read_safe': False,
        'parallel_write_safe': False,
        'env_version': 1,
    }
