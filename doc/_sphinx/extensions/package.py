#!/usr/bin/env python
import os
import shutil
from docutils import nodes
from sphinx.util.docutils import SphinxDirective


class PackageDirective(SphinxDirective):
    has_content = True
    required_arguments = 1
    optional_arguments = 0

    def run(self):
        pkg_name = self.arguments[0]
        relative_path = self.find_package(pkg_name)
        link = []
        self.state.nested_parse([f"[{pkg_name}]({relative_path})"], 0, link)
        content = []
        self.state.nested_parse(self.content, 0, content)
        return [
            nodes.container('', link[0], nodes.container('', *content), classes=['package'])
        ]

    def find_package(self, pkg_name):
        for root, dirs, files in os.walk('..'):
            if '_build' in root:
                continue
            if os.path.split(root)[-1] == pkg_name:
                if 'index.md' in files:
                    return os.path.join(root, 'index.md')
                elif pkg_name + '.md' in files:
                    return os.path.join(root, pkg_name + '.md')
                elif len(files) == 1:
                    return os.path.join(root, files[0])
                else:
                    return root
        raise self.error('Cannot find package `pkg_name`')


def setup(app):
    base_dir = os.path.dirname(__file__)
    target_dir = os.path.abspath('../_build/html/_static/')
    os.makedirs(target_dir, exist_ok=True)
    shutil.copy(os.path.join(base_dir, 'package.css'), target_dir)

    app.add_directive('package', PackageDirective)
    app.add_css_file('package.css')
    return {
        'parallel_read_safe': True,
        'parallel_write_safe': True,
        'env_version': 1,
    }
