#!/usr/bin/env python
import os
import shutil
import subprocess
from docutils import nodes
from docutils.parsers.rst import directives
from sphinx.util.docutils import SphinxDirective
from sphinx.util.logging import getLogger


# ------------------------------------------------------------------------------
# Parameter validators
# ------------------------------------------------------------------------------

def valid_sources(argument):
    """Validator for the `sources` parameter of the flutter-app directive."""
    if argument is None:
        raise ValueError('Missing required argument :sources:')
    else:
        abspath = os.path.abspath(argument)
        if os.path.isdir(abspath):
            assert not abspath.endswith('/')
            return abspath
        else:
            raise ValueError(f'{abspath} does not exist or is not a directory')


def show_choices(argument):
    """Validator for the `show` parameter of the flutter-app directive."""
    if argument:
        values = argument.split()
        for value in values:
            if value not in ['widget', 'run', 'code']:
                raise ValueError('Invalid :show: value ' + value)
        return values
    else:
        return ['widget']


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
# Directives
# ------------------------------------------------------------------------------

class FlutterAppDirective(SphinxDirective):
    has_content = False
    required_arguments = 0
    optional_arguments = 0
    option_spec = {
        'sources': valid_sources,
        'page': directives.unchanged,
        'show': show_choices,
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
        self.modes = self.options['show']
        self.source_dir = self.options['sources']
        self.source_build_dir = os.path.join(self.source_dir, 'build', 'web')
        self.app_name = os.path.basename(self.source_dir)
        self.html_dir = '_static/apps/' + self.app_name
        self.target_dir = os.path.abspath(
            os.path.join('..', '_build', 'html', self.html_dir))
        self._ensure_compiled()

        page = self.options['page']
        iframe_url = self.html_dir + '/index.html?' + page
        result = []
        if 'run' in self.modes:
            result.append(Button(
                '',
                nodes.Text('Run'),
                classes=['flutter-app-button', 'run'],
                onclick=f'run_flutter_app("{iframe_url}")',
            ))
        if 'code' in self.modes:
            pass
        if 'widget' in self.modes:
            result.append(IFrame(src=iframe_url))
        return result

    def _ensure_compiled(self):
        need_compiling = (
            ('run' in self.modes or 'widget' in self.modes) and
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
# Extension setup
# ------------------------------------------------------------------------------

def setup(app):
    basedir = os.path.dirname(__file__)
    app.add_node(IFrame, html=(visit_iframe, depart_iframe))
    app.add_node(Button, html=(visit_button, depart_button))
    app.add_directive('flutter-app', FlutterAppDirective)
    app.add_js_file('flutter_app.js')
    app.add_css_file('flutter_app.css')
    for file in ['flutter_app.js', 'flutter_app.css']:
        shutil.copy(os.path.join(basedir, file), '../_build/html/_static/')
    return {
        'parallel_read_safe': False,
        'parallel_write_safe': False,
        'env_version': 1,
    }
