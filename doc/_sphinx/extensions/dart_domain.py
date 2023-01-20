import json
import os
import re
import subprocess
import sys
import tempfile
from typing import List, Tuple, Dict, Optional

from docutils import nodes
from docutils.nodes import Element
from docutils.parsers.rst import directives
from sphinx.addnodes import pending_xref
from sphinx.application import Sphinx
from sphinx.builders import Builder
from sphinx.domains import Domain
from sphinx.environment import BuildEnvironment
from sphinx.roles import XRefRole
from sphinx.util.docutils import SphinxDirective
from sphinx.util.fileutil import copy_asset_file
from sphinx.util.nodes import make_refnode


def remove_nulls(items: List):
    """Helper methods for filtering out `None` values from a list."""
    return [item for item in items if item is not None]


class DartdocDirective(SphinxDirective):
    """
    Directive to add auto-generated documentation for a particular symbol in
    a Dart file. The symbol could be a class, mixin, function, etc.

    Example of usage (in a markdown file):

        ```{dartdoc}
        :file: src/components/core/component.dart
        :symbol: Component
        :package: flame
        ```
    """
    has_content = False
    required_arguments = 0
    optional_arguments = 0
    option_spec = {
        "file": directives.unchanged_required,
        "symbol": directives.unchanged_required,
        "package": directives.unchanged,
    }

    def __init__(self, name, arguments, options, content, lineno, content_offset, block_text, state,
                 state_machine):
        super().__init__(name, arguments, options, content, lineno, content_offset, block_text,
                         state, state_machine)
        self.package = None
        self.root = None
        self.source_file = None
        self.symbol = None
        self.record = None

    def run(self):
        self.package = self._parse_option_package()
        self.root = self._get_root_from_config()
        self.source_file = self._parse_option_file()
        self.symbol = self._parse_option_symbol()
        self.record = self._get_data_record()
        self._scan_source_file_if_needed()
        result = nodes.container(
            '',
            self._generate_node_for_declaration(self.record['json'], 1),
            classes=['dartdoc']
        )
        return [result]

    def _parse_option_package(self):
        package = self.options['package']
        if not package:
            data = self.env.domaindata['dart']
            package = data['default_package']
        return package

    def _get_root_from_config(self):
        if self.package:
            roots = self.env.config.dartdoc_roots
            if self.package not in roots:
                raise self.error(
                    f'Unknown package name `{self.package}`: please include it in the '
                    f'`dartdoc_roots` configuration setting.'
                )
            return roots[self.package]
        else:
            return self.env.config.dartdoc_root

    def _parse_option_file(self):
        path = os.path.join(self.root, self.options['file'])
        path = os.path.expanduser(path)
        path = os.path.abspath(path)
        if not os.path.exists(path):
            raise ValueError(f'File `{path}` does not exist')
        if not os.path.isfile(path):
            raise ValueError(f'Path `{path}` is not a file')
        return path

    def _parse_option_symbol(self):
        symbol = self.options['symbol']
        if not re.fullmatch(r'[a-zA-Z_][a-zA-Z0-9_]*', symbol):
            raise ValueError(f'Invalid symbol name `{symbol}`')
        return symbol

    def _get_data_record(self):
        objects = self.env.domaindata['dart']['objects']
        if self.package not in objects:
            objects[self.package] = {}
        if self.symbol not in objects[self.package]:
            objects[self.package][self.symbol] = {
                'json': None,
                'filename': self.source_file,
                'timestamp': 0,
                'docname': self.env.docname,
            }
        return objects[self.package][self.symbol]

    def _scan_source_file_if_needed(self):
        last_scan_time = self.record['timestamp']
        source_last_modified_time = os.path.getmtime(self.source_file)
        if last_scan_time >= source_last_modified_time:
            assert self.record['json']
            return
        json_result = self._scan_source_file()
        self.record['json'] = json_result
        self.record['timestamp'] = source_last_modified_time

    def _scan_source_file(self):
        dart_cmd = 'dart'
        if sys.platform == 'win32':
            dart_cmd = 'dart.exe'
        with tempfile.NamedTemporaryFile(mode='rt', suffix='json') as temp_file:
            try:
                subprocess.run(
                    [dart_cmd, 'run', self.env.config.dartdoc_parser,
                     self.source_file, '--output', temp_file.name],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    check=True,
                )
                json_string = temp_file.read()
                return self._extract_symbol(json_string)
            except subprocess.CalledProcessError as e:
                cmd = ' '.join(e.cmd)
                raise RuntimeError(
                    f'Command `{cmd}` returned with exit status'
                    f' {e.returncode}\n{e.output.decode("utf-8")}'
                )

    def _extract_symbol(self, json_string: str) -> Dict:
        """
        Locates the definition of `self.symbol` within the `json_string` output.
        """
        json_obj = json.loads(json_string)
        if type(json_obj) != list or len(json_obj) != 1:
            string = str(json_obj)
            if len(string) > 100:
                string = string[:97] + '...'
            raise TypeError(
                f'Invalid JSON output: a list of length 1 was expected, '
                f'instead received `{string}`'
            )
        declared_symbols = []
        for declaration in json_obj[0]['declarations']:
            if declaration['name'] == self.symbol:
                return declaration
            declared_symbols.append(declaration['name'])
        file = self.options['file']
        raise ValueError(
            f'Symbol {self.symbol} was not found in file {file}; available '
            f'symbols were: {declared_symbols}'
        )

    # ----------------------------------------------------------------------------------------------
    # Generate documentation nodes
    # ----------------------------------------------------------------------------------------------

    def _generate_node_for_declaration(self, data: Dict, level: int) -> Element:
        """
        Generic method, this will handle the `data` field of arbitrary type,
        and route it to the appropriate generator.
        """
        kind = data['kind']
        result = nodes.container(classes=[kind])
        if kind in {'class', 'mixin', 'extension'}:
            result += self._generate_class_signature_node(data, level)
            result += self._generate_description(data, level)
            result += self._generate_constructors_section(data, level)
            result += self._generate_properties_section(data, level)
            result += self._generate_methods_section(data, level)
        elif kind in {'constructor', 'method', 'function'}:
            result += self._generate_function_signature_node(data, level)
            result += self._generate_description(data, level)
        elif kind in {'field', 'getter', 'setter'}:
            result += self._generate_field_signature_node(data, level)
            result += self._generate_description(data, level)
        else:
            raise self.error(f'Unknown symbol kind: {kind}')
        if level == 1:
            sig_node = result[0]
            self.state.document.note_explicit_target(sig_node)
        return result

    def _generate_class_signature_node(self, data: Dict, level: int) -> Element:
        result = nodes.container(classes=['signature', f'sig{level}'], ids=[data['name']])
        first_line = nodes.container(
            '',  # rawsource
            nodes.inline(text=data['kind'] + ' ', classes=['keyword']),
            nodes.inline(text=data['name'], classes=['name']),
        )
        first_line += self._generate_type_parameters_node(data)
        result += first_line
        for keyword in ['extends', 'on', 'implements', 'with']:
            if keyword not in data:
                continue
            line = nodes.container(
                '',  # rawsource
                nodes.inline(text=keyword, classes=['keyword']),
                nodes.Text(' '),
                classes=['modifier']
            )
            targets = data[keyword]
            if type(targets) != list:
                targets = [targets]
            for i, target in enumerate(targets):
                if i > 0:
                    line += nodes.Text(', ')
                line += nodes.inline(text=target)
            result += line
        return result

    def _generate_function_signature_node(self, data: Dict, level: int) -> Element:
        result = nodes.container(classes=['signature', f'sig{level}'], ids=[data['name']])
        first_line = nodes.container()
        first_line += nodes.inline(text=data['name'], classes=['name'])
        first_line += self._generate_type_parameters_node(data)
        arguments = nodes.inline(classes=['arguments'])
        arguments += nodes.inline(text='(', classes=['punct'])
        if 'parameters' in data:
            parameters = data['parameters']['all']
            n_positional_parameters = data['parameters'].get('positional', 0)
            n_named_parameters = data['parameters'].get('named', 0)
            n_simple_parameters = len(parameters) - n_positional_parameters - n_named_parameters
            brackets = \
                '[]' if n_positional_parameters > 0 else \
                '{}' if n_named_parameters > 0 else \
                ''
            for i, param in enumerate(parameters):
                if i > 0:
                    arguments += nodes.inline(text=', ', classes=['punct'])
                if i == n_simple_parameters:
                    arguments += nodes.inline(text=brackets[0], classes=['punct'])
                argument = nodes.inline(classes=['argument'])
                if 'type' in param:
                    argument += nodes.Text(param['type'])
                    argument += nodes.Text(' ')
                argument += nodes.inline(text=param['name'], classes=['name'])
                if 'default' in param:
                    argument += nodes.inline(text=' = ', classes=['punct'])
                    argument += nodes.inline(text=param['default'], classes=['default'])
                arguments += argument
            if brackets:
                arguments += nodes.inline(text=brackets[1], classes=['punct'])
        arguments += nodes.inline(text=')', classes=['punct'])
        first_line += arguments
        if 'returns' in data:
            return_type = data['returns']
            if return_type != 'void':
                first_line += nodes.inline(text=' → ', classes=['punct'])
                first_line += nodes.Text(return_type)
        result += first_line
        return result

    def _generate_field_signature_node(self, data: Dict, level: int) -> Element:
        result = nodes.container(classes=['signature', f'sig{level}'], ids=[data['name']])
        result += nodes.inline(text=data['name'], classes=['name'])
        if data['kind'] == 'field':
            arrow = ':'
        elif data['kind'] == 'getter':
            arrow = '←→' if data.get('has_setter') else '→'
        elif data['kind'] == 'setter':
            arrow = '←'
        else:
            raise self.error(f'Unexpected field type {data["kind"]}')
        result += nodes.inline(text=f' {arrow} ', classes=['punct'])
        if 'type' in data:
            field_type = data['type']
        elif 'returns' in data:
            field_type = data['returns']
        elif 'parameters' in data:
            field_type = data['parameters']['all'][0]['type']
        else:
            raise self.error(f'Unexpected field data: {data}')
        result += nodes.Text(field_type)
        return result

    def _generate_type_parameters_node(self, data: Dict) -> Optional[Element]:
        if 'typeParameters' not in data:
            return None
        result = nodes.inline(classes=['types'])
        result += nodes.inline(text='<', classes=['punct'])
        for i, type_param in enumerate(data['typeParameters']):
            if i > 0:
                result += nodes.inline(text=', ', classes=['punct'])
            result += nodes.inline(text=type_param['name'], classes=['name'])
            if 'extends' in type_param:
                result += nodes.inline(text=' extends ', classes=['keyword'])
                result += nodes.Text(type_param['extends'])
        result += nodes.inline(text='>', classes=['punct'])
        return result

    def _generate_description(self, data: Dict, level: int) -> Optional[Element]:
        if 'description' not in data:
            return None
        lines = data['description'].split('\n')
        result = nodes.container(classes=['dartdoc', 'description', f'doc{level}'])
        self.state.nested_parse(lines, 0, result)
        return result

    def _generate_constructors_section(self, data: Dict, level: int) -> Optional[Element]:
        if 'members' not in data:
            return None
        constructors = [
            entry
            for entry in data['members']
            if entry['kind'] == 'constructor'
        ]
        if not constructors:
            return None
        # A section needs an id, otherwise Sphinx breaks
        result = nodes.section(ids=['constructors'], classes=['dartdoc'])
        result += nodes.title(text='Constructors')
        for constructor in constructors:
            result += self._generate_node_for_declaration(constructor, level + 1)
        return result

    def _generate_methods_section(self, data: Dict, level: int) -> Optional[Element]:
        methods = [entry for entry in data.get('members', []) if entry['kind'] == 'method']
        if not methods:
            return None
        # A section needs an id, otherwise Sphinx breaks
        result = nodes.section(ids=['methods'])
        result += nodes.title(text='Methods')
        for method in methods:
            result += self._generate_node_for_declaration(method, level + 1)
        return result

    def _generate_properties_section(self, data: Dict, level: int) -> Optional[Element]:
        fields = [
            entry
            for entry in data.get('members', [])
            if entry['kind'] in {'field', 'getter', 'setter'}
        ]
        if not fields:
            return None
        for i, field in enumerate(fields):
            if field is None:
                continue
            if field['kind'] == 'setter':
                name = field['name']
                for j, field2 in enumerate(fields):
                    if field2 is None:
                        continue
                    if field2['kind'] == 'getter' and field2['name'] == name:
                        fields[j]['has_setter'] = True
                        fields[i] = None
        result = nodes.section(ids=['properties'])
        result += nodes.title(text='Properties')
        for i, field in enumerate(fields):
            if field is not None:
                result += self._generate_node_for_declaration(field, level + 1)
        return result


class DartDomain(Domain):
    """
    The domain for describing objects in Dart language.
    """
    name = 'dart'
    label = 'dart'

    roles = {
        'ref': XRefRole(),
    }
    directives = {
        'dartdoc': DartdocDirective,
    }
    initial_data = {
        # Dictionary of all API objects known. The dictionary is keyed by the
        # package name at first level, then by the symbol name, and the values
        # are dictionary of properties for that object.
        'objects': {
            # package: str
            # -> symbol: str
            #    -> object_data: Dict = {
            #         'json': Dict,  # object's raw API data, in JSON format
            #         'source': str,  # file name where the API data came from
            #         'timestamp': int,  # last modified time of [source]
            #         'docname': str,  # doc where the symbol is documented
            #       }
        },
        # Dictionary that provides for each document name the references to
        # all objects that are declared within that document.
        'docs': {
            # docname: str
            # -> doc_data: Dict = {
            #   'symbols': List[str], # names of symbols documented on the page
            #   'package': str  # package declared for that page
            # }
        },
        # The name of the package that should be used if a directive does not
        # specify any.
        'default_package': '',
    }
    data_version = 1

    def merge_domaindata(self, docnames: List[str], other_data: Dict) -> None:
        for package, package_data in other_data['objects'].items():
            for symbol, object_data in package_data.items():
                if object_data['docname'] in docnames:
                    if package not in self.data['objects']:
                        self.data['objects'][package] = {}
                    self.data['objects'][package][symbol] = object_data
        for docname, doc_data in other_data['docs'].items():
            if docname in docnames:
                self.data['docs'][docname] = doc_data

    def resolve_any_xref(self, env: BuildEnvironment, fromdocname: str, builder: Builder,
                         target: str, node: pending_xref, contnode: Element) \
            -> List[Tuple[str, Element]]:
        return []

    def resolve_xref(self, env: BuildEnvironment, fromdocname: str, builder: Builder,
                     typ: str, target: str, node: pending_xref, contnode: Element
                     ) \
            -> Optional[Element]:
        symbol_data = None
        for package, package_data in self.data['objects'].items():
            if target in package_data:
                symbol_data = package_data[target]
                break
        if not symbol_data:
            return None
        return make_refnode(
            builder=builder,
            fromdocname=fromdocname,
            todocname=symbol_data['docname'],
            targetid=target,
            child=contnode,
            title=None,
        )


def copy_asset_files(app, exc):
    assert __file__.endswith('dart_domain.py')
    css_file = __file__[:-2] + 'css'
    if not os.path.isfile(css_file):
        raise FileNotFoundError(f'Missing file `{css_file}`')
    if app.builder.format == 'html' and not exc:
        static_dir = os.path.join(app.builder.outdir, '_static')
        copy_asset_file(css_file, static_dir)


def setup(app: Sphinx):
    app.add_css_file('dart_domain.css')
    app.add_config_value('dartdoc_root', '', 'env', str)
    app.add_config_value('dartdoc_roots', {}, 'env', Dict[str, str])
    app.add_config_value('dartdoc_parser', 'dartdoc_json.dart', '', str)
    app.add_domain(DartDomain)
    app.connect('build-finished', copy_asset_files)
    return {
        'version': '1.0.0',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }
