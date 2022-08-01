#!/usr/bin/env python
import glob
import os
import re
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
        "popup", "code", and "infobox". Each of these modes produces a different
        output:
          "widget" - an iframe shown directly inside the docs page;
          "popup" - a [Run] button which opens the app to (almost) fullscreen;
          "code" - a [Code] button which opens a popup with the code that was
              compiled.
          "infobox" - the content will be displayed as an infobox floating on
              the right-hand side of the page.

      :width: - override the default width of an iframe in widget/infobox modes.

      :height: - override the default height of an iframe in widget/infobox
        modes.
    """
    has_content = True
    required_arguments = 0
    optional_arguments = 0
    option_spec = {
        'sources': directives.unchanged,
        'page': directives.unchanged,
        'show': directives.unchanged,
        'width': directives.unchanged,
        'height': directives.unchanged,
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
        self.app_name = self._get_app_name()
        self.html_dir = '_static/apps/' + self.app_name
        self.target_dir = os.path.abspath(
            os.path.join('..', '_build', 'html', self.html_dir))
        self._ensure_compiled()

        page = self.options.get('page', '')
        iframe_url = _doc_root() + self.html_dir + '/index.html?' + page
        result = []
        if 'widget' in self.modes:
            iframe = IFrame(src=iframe_url, classes=['flutter-app-iframe'])
            result.append(iframe)
            styles = []
            if self.options.get('width'):
                width = self.options.get('width')
                if width.isdigit():
                    width += 'px'
                styles.append("width: " + width)
            if self.options.get('height'):
                height = self.options.get('height')
                if height.isdigit():
                    height += 'px'
                styles.append("height: " + height)
            if styles:
                iframe.attributes['style'] = '; '.join(styles)
        if 'popup' in self.modes:
            result.append(Button(
                '',
                nodes.Text('Run'),
                classes=['flutter-app-button', 'popup'],
                onclick=f'run_flutter_app("{iframe_url}")',
            ))
        if 'code' in self.modes:
            code_id = self.app_name + "-source-" + page
            result.append(self._generate_code_listings(code_id))
            result.append(Button(
                '',
                nodes.Text('Code'),
                classes=['flutter-app-button', 'code'],
                onclick=f'open_code_listings("{code_id}")',
            ))
        if 'infobox' in self.modes:
            self.state.nested_parse(self.content, 0, result)
            result = [
                nodes.container('', *result, classes=['flutter-app-infobox'])
            ]
        return result

    def _process_show_option(self):
        argument = self.options.get('show')
        if argument:
            values = argument.split()
            for value in values:
                if value not in ['widget', 'popup', 'code', 'infobox']:
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

    def _get_app_name(self):
        src = os.path.relpath(self.source_dir)
        return '-'.join(word for word in re.split(r'\W', src) if word)

    def _ensure_compiled(self):
        need_compiling = (
            ('popup' in self.modes or 'widget' in self.modes) and
            self.source_dir not in FlutterAppDirective.COMPILED
        )
        if not need_compiling:
            return
        self.logger.info('Compiling Flutter app [%s]' % self.app_name)
        self._compile_source()
        self._copy_compiled()
        self._create_index_html()
        self.logger.info('  + copied into ' + self.target_dir)
        assert os.path.isfile(self.target_dir + '/main.dart.js')
        assert os.path.isfile(self.target_dir + '/index.html')
        FlutterAppDirective.COMPILED.append(self.source_dir)

    def _compile_source(self):
        try:
            subprocess.run(
                ['flutter', 'build', 'web'],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                cwd=self.source_dir,
                check=True,
            )
        except subprocess.CalledProcessError as e:
            cmd = ' '.join(e.cmd)
            raise self.error(
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

    def _create_index_html(self):
        target_file = os.path.join(self.target_dir, 'index.html')
        with open(target_file, 'wt') as out:
            out.write('<!DOCTYPE html>\n')
            out.write('<html>\n<head>\n')
            out.write('<base href="%s%s/">\n' % (_doc_root(), self.html_dir))
            out.write('<title>%s</title>\n' % self.app_name)
            out.write('<style>body { background: black; }</style>\n')
            out.write('</head>\n<body>\n')
            out.write('<script src="main.dart.js"></script>\n')
            out.write('</body>\n</html>\n')

    def _generate_code_listings(self, code_id):
        code_dir = self.source_dir + '/lib/' + self.options.get('page', '')
        if os.path.isdir(code_dir):
            files = glob.glob(code_dir + '/**', recursive=True)
        elif os.path.isfile(code_dir + '.dart'):
            files = [code_dir + '.dart']
            code_dir += '/..'
        else:
            raise self.error(f'Cannot find source directory {code_dir} or '
                             f'source file {code_dir}.dart')

        result = nodes.container(classes=['flutter-app-code'], ids=[code_id])
        for filename in sorted(files):
            if os.path.isfile(filename):
                simple_filename = os.path.relpath(filename, code_dir)
                result += nodes.container(
                    '', nodes.Text(simple_filename), classes=['filename']
                )
                with open(filename, 'rt') as f:
                    self.state.nested_parse(
                        ['``````{code-block} dart\n:lineno-start: 1\n'] +
                        [line.rstrip() for line in f] +
                        ['``````\n'], 0, result)
        return result


def _doc_root():
    root = os.environ.get('PUBLISH_PATH', '')
    if not root.startswith('/'):
        root = '/' + root
    if not root.endswith('/'):
        root = root + '/'
    return root


# ------------------------------------------------------------------------------
# Nodes
# ------------------------------------------------------------------------------

class IFrame(nodes.Element, nodes.General):
    def visit(self, node):
        attrs = {'src': node.attributes['src']}
        if 'style' in node.attributes:
            attrs['style'] = node.attributes['style']
        self.body.append(self.starttag(node, 'iframe', **attrs).strip())

    def depart(self, _):
        self.body.append('</iframe>')


class Button(nodes.Element, nodes.General):
    def visit(self, node):
        attrs = {}
        if 'onclick' in node.attributes:
            attrs['onclick'] = node.attributes['onclick']
        self.body.append(self.starttag(node, 'button', **attrs).strip())

    def depart(self, _):
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

    app.add_node(IFrame, html=(IFrame.visit, IFrame.depart))
    app.add_node(Button, html=(Button.visit, Button.depart))
    app.add_directive('flutter-app', FlutterAppDirective)
    app.add_js_file('flutter_app.js')
    app.add_css_file('flutter_app.css')
    return {
        'parallel_read_safe': False,
        'parallel_write_safe': False,
        'env_version': 1,
    }
