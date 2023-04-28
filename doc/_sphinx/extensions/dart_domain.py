import json
import os
import re
import subprocess
import tempfile
from typing import List, Tuple, Dict, Optional, Set, Any

from docutils import nodes
from docutils.nodes import Element
from docutils.parsers.rst import directives
from docutils.parsers.rst.states import Inliner
from sphinx.addnodes import pending_xref
from sphinx.application import Sphinx
from sphinx.builders import Builder
from sphinx.domains import Domain
from sphinx.environment import BuildEnvironment
from sphinx.roles import XRefRole
from sphinx.util.docutils import SphinxDirective
from sphinx.util.fileutil import copy_asset_file
from sphinx.util.nodes import make_refnode


class DartdocDirective(SphinxDirective):
    """
    Directive to add auto-generated documentation for a particular symbol in
    a Dart file. The symbol could be a class, mixin, function, etc.

    Example of usage (in a markdown file):

        # Component
        ```{dartdoc}
        :file: src/components/core/component.dart
        :symbol: Component
        :package: flame

        [Link1]: url1
        ...
        [LinkN]: urlN
        ```

    We recommend documenting only one such symbol per page; however, it is
    possible to add extra content on the page after the {dartdoc} directive.
    Such content may include additional examples, see-also section, etc.
    """
    has_content = True
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
        self.package: str = ''
        self.root = None
        self.source_file = None
        self.symbol = None
        self.record = None
        # Explicit reference targets provided to the directive within its content. These are
        # references in double-square brackets.
        self.links: Dict[str, str] = {}
        # Names of members (fields/methods) of the current class/mixin/enum. Within the body of
        # this directive, references to these members may be given as plain text in square
        # brackets.
        self.member_set: Set[str] = set()
        # Names of parameters to the current method. This set is populated only when processing
        # some method/constructor within the class. Within the description of the method, the names
        # of these parameters can be mentioned in square brackets, which will be converted into a
        # special :param: role.
        self.param_set: Set[str] = set()

    def run(self):
        self.package = self._parse_option_package()
        self.root = self._get_root_from_config()
        self.source_file = self._parse_option_file()
        self.symbol = self._parse_option_symbol()
        self.record = self._get_data_record()
        self.links = self._parse_links()
        self._scan_source_file_if_needed()
        for member in self.record['json'].get('members', {}):
            self.member_set.add(member['name'])
        result = nodes.container(
            '',
            self._generate_node_for_declaration(self.record['json'], 1),
            classes=['dartdoc']
        )
        return [result]

    def _parse_option_package(self) -> str:
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
                    f'`dartdoc_roots` configuration setting (file conf.py).'
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

    def _parse_links(self) -> Dict[str, str]:
        rx_reference_line = re.compile(r'^\[(.*?)]:\s+(.*)$')
        links = {}
        for line in self.content:
            line = line.strip()
            if not line:
                continue
            match = re.fullmatch(rx_reference_line, line)
            if match:
                links[match.group(1)] = match.group(2)
            else:
                raise self.error(
                    f'Invalid reference definition: `{line}`; expected the '
                    f'following format: `[[NAME]]: TARGET`'
                )
        return links

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
        with tempfile.NamedTemporaryFile(mode='rt', suffix='.json', delete=False) as temp_file:
            # Note: on Windows, a temporary file cannot be opened in another
            # process if it is already open in this process. Thus, we need to
            # close the file handle first before handing the file name to
            # `subprocess.run()`.
            temp_file.close()
            try:
                executable = 'dartdoc_json'
                if os.name == 'nt':  # Windows
                    executable = 'dartdoc_json.bat'
                subprocess.run(
                    [executable, self.source_file, '--output', temp_file.name],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    check=True,
                )
                with open(temp_file.name, 'r') as t:
                    json_string = t.read()
                return self._extract_symbol(json_string)
            except subprocess.CalledProcessError as e:
                cmd = ' '.join(e.cmd)
                raise RuntimeError(
                    f'Command `{cmd}` returned with exit status'
                    f' {e.returncode}\n{e.output.decode("utf-8")}'
                )
            finally:
                os.remove(temp_file.name)

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
            for param in data.get('parameters', {}).get('all', []):
                self.param_set.add(param['name'])
            result += self._generate_function_signature_node(data, level)
            result += self._generate_description(data, level)
            self.param_set.clear()
        elif kind in {'field', 'getter', 'setter'}:
            result += self._generate_field_signature_node(data, level)
            result += self._generate_description(data, level)
        else:
            raise self.error(f'Unknown symbol kind: {kind}')
        self.state.document.note_explicit_target(result[0])
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
        node_id = data['name']
        if level >= 2:
            node_id = f'{self.symbol}-{node_id}'
        result = nodes.container(classes=['signature', f'sig{level}'], ids=[node_id])
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
                if 'required' in param:
                    argument += nodes.inline(text='required ', classes=['keyword'])
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
        node_id = data['name']
        if level >= 2:
            node_id = f'{self.symbol}-{node_id}'
        result = nodes.container(classes=['signature', f'sig{level}'], ids=[node_id])
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
        if not data.get('description'):
            return None
        lines = self._augment_comment(data['description']).split('\n')
        result = nodes.container(classes=['description', f'doc{level}'])
        self.state.nested_parse(lines, 0, result)
        return result

    def _generate_constructors_section(self, data: Dict, level: int) -> Optional[Element]:
        constructors = self._select_class_members(data, ['constructor'])
        if not constructors:
            return None
        # A section needs an id, otherwise Sphinx breaks
        result = nodes.section(ids=['constructors'])
        result += nodes.title(text='Constructors')
        for constructor in constructors:
            result += self._generate_node_for_declaration(constructor, level + 1)
        return result

    def _generate_methods_section(self, data: Dict, level: int) -> Optional[Element]:
        methods = self._select_class_members(data, ['method'])
        if not methods:
            return None
        # A section needs an id, otherwise Sphinx breaks
        result = nodes.section(ids=['methods'])
        result += nodes.title(text='Methods')
        for method in methods:
            result += self._generate_node_for_declaration(method, level + 1)
        return result

    def _generate_properties_section(self, data: Dict, level: int) -> Optional[Element]:
        fields = self._select_class_members(data, ['field', 'getter', 'setter'])
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

    def _select_class_members(self, data: Dict, kinds: List[str]) -> List[Dict]:
        """
        Given the JSON object [data] which describes a single Dart object such
        as class/mixin/etc, this method returns all entries in `data.members`
        whose "kind" property is among the provided [kinds].
        """
        filter_overrides = not self.env.config.dartdoc_show_overrides
        result = []
        for entry in data.get('members', []):
            if entry['kind'] not in kinds:
                continue
            if filter_overrides:
                annotations = [
                    annotation['name']
                    for annotation in entry.get('annotations', [])
                ]
                if '@override' in annotations:
                    continue
            result.append(entry)
        return result

    def _augment_comment(self, text: str) -> str:
        rx_escape = re.compile(r'([<>`*])')

        def escape(text: str) -> str:
            return re.sub(rx_escape, r'\\\1', text)

        def count(char, text, j):
            n = 0
            while j < len(text):
                if text[j] == char:
                    n += 1
                else:
                    break
                j += 1
            return n

        parts: List[str] = []
        i = 0
        i0 = 0
        while i < len(text):
            ch = text[i]
            if ch == '`':
                # Skip any backtick-escaped text
                num_backticks = count('`', text, i)
                i += num_backticks
                assert num_backticks > 0
                while i < len(text):
                    if count('`', text, i) >= num_backticks:
                        i += num_backticks
                        break
                    i += 1
            elif ch == '[':
                parts.append(text[i0:i])
                num_brackets = count('[', text, i)
                i += num_brackets
                assert num_brackets > 0
                start = i
                while i < len(text):
                    if count(']', text, i) >= num_brackets:
                        i += num_brackets
                        break
                    i += 1
                target = text[start:i - num_brackets]
                i0 = i
                if num_brackets >= 2:
                    # Links of the form `[[NAME]]` are converted into `[NAME](URL)`. The
                    # `NAME` must be listed beforehand within the directive's content.
                    if target in self.links:
                        url = self.links[target]
                        parts.append(f'[{escape(target)}]({url})')
                    else:
                        raise self.error(
                            f'Unexpected link {target}, please specify its '
                            f'target URL within the content section of the '
                            f'directive.'
                        )
                else:
                    # Links of the form `[NAME]` are converted into "{ref}`NAME`", so that
                    # they can be resolved later by the domain.
                    if target in self.param_set:
                        parts.append(f'{{param}}`{target}`')
                    elif target in self.member_set:
                        parts.append(f'{{ref}}`{target} <{self.symbol}-{target}>`')
                    elif target in self.links:
                        url = self.links[target]
                        parts.append(f'[{escape(target)}]({url})')
                    else:
                        parts.append(f'{{ref}}`{escape(target)}`')
            else:
                i += 1
        parts.append(text[i0:])
        return ''.join(parts)


def ParamRole(name: str, rawtext: str, text: str, lineno: int, inliner: Inliner,
              options: Dict[str, Any], content: List[str]) \
        -> Tuple[List[nodes.Node], List[nodes.system_message]]:
    return [nodes.inline(text=text, classes=['param'])], []


class DartDomain(Domain):
    """
    The domain for describing objects in Dart language.
    """
    name = 'dart'
    label = 'dart'

    roles = {
        'ref': XRefRole(),
        'param': ParamRole,
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
            #         'timestamp': float,  # last modified time of [source]
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
        target_id = target
        if '-' in target:
            target, suffix = target.split('-', 2)
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
            targetid=target_id,
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


# Emitted when the environment determines which source files have changed and should be re-read.
# `added`, `changed` and `removed` are sets of docnames that the environment has determined. You
# can return a list of docnames to re-read in addition to these.
#
# https://www.sphinx-doc.org/en/master/extdev/appapi.html#event-env-get-outdated
def on_env_get_outdated(_: Sphinx, env: BuildEnvironment, added: Set[str], changed: Set[str],
                        removed: Set[str]) -> List[str]:
    existing = added | changed | removed
    modified = set()
    for package, package_data in env.domaindata['dart']['objects'].items():
        for symbol, record in package_data.items():
            docname = record['docname']
            if docname in existing or docname in modified:
                continue
            last_scan_time = record['timestamp']
            last_modified_time = os.path.getmtime(record['filename'])
            if last_scan_time < last_modified_time:
                modified.add(docname)
    return list(modified)


# Emitted when all traces of a source file should be cleaned from the environment, that is, if the
# source file is removed or before it is freshly read. This is for extensions that keep their own
# caches in attributes of the environment.
#
# https://www.sphinx-doc.org/en/master/extdev/appapi.html#event-env-purge-doc
def on_env_purge_doc(_: Sphinx, env: BuildEnvironment, docname: str) -> None:
    for package, package_data in env.domaindata['dart']['objects'].items():
        symbols_to_remove = []
        for symbol, record in package_data.items():
            if record['docname'] == docname:
                symbols_to_remove.append(symbol)
        for symbol in symbols_to_remove:
            del package_data[symbol]


# Emitted after the environment has determined the list of all added and changed files and just
# before it reads them. It allows extension authors to reorder the list of docnames (inplace)
# before processing, or add more docnames that Sphinx did not consider changed.
#
# https://www.sphinx-doc.org/en/master/extdev/appapi.html#event-env-before-read-docs
def on_env_before_read_docs(_: Sphinx, __: BuildEnvironment, docnames: List[str]) -> None:
    # This ensures that within each directory, the 'index.md' document is processed first.
    def key(docname: str) -> str:
        basename = os.path.basename(docname)
        if docname == 'index':
            return '_index'
        return basename

    docnames.sort(key=key)


def setup(app: Sphinx):
    app.add_css_file('dart_domain.css')
    app.add_config_value('dartdoc_root', '', 'env', str)
    app.add_config_value('dartdoc_roots', {}, 'env', Dict[str, str])
    app.add_config_value('dartdoc_show_overrides', False, 'env', bool)
    app.add_domain(DartDomain)
    app.connect('build-finished', copy_asset_files)
    app.connect('env-get-outdated', on_env_get_outdated)
    app.connect('env-purge-doc', on_env_purge_doc)
    app.connect('env-before-read-docs', on_env_before_read_docs)
    return {
        'version': '1.0.0',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }
