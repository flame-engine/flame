# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html
import docutils
import os
import sys
sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------

project = 'Flame'
copyright = '2021, Blue Fire Team'
author = 'Blue Fire Team'
root_doc = "index"


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'myst_parser',  # Markdown support
    'sphinxcontrib.mermaid',
    'extensions.flutter_app',
]

# Configuration options for MyST:
# https://myst-parser.readthedocs.io/en/latest/syntax/optional.html
myst_enable_extensions = [
    'dollarmath',
    'html_admonition',
    'html_image',
    'linkify',
    'replacements',
    'smartquotes',
]

# Auto-generate link anchors for headers at levels H1 and H2
myst_heading_anchors = 4

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store', 'summary.md']


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.
html_theme = "flames"
html_theme_options = {}
html_title = "Flame"
html_logo = "images/logo_flame.png"
html_favicon = "images/favicon.ico"

# Style for syntax highlighting
pygments_style = 'monokai'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['images', 'scripts', 'theme']
html_js_files = ['versions.js']

# -- Custom setup ------------------------------------------------------------
class TitleCollector(docutils.nodes.SparseNodeVisitor):
    def __init__(self, document):
        self.level = 0
        self.titles = []
        super().__init__(document)

    def visit_section(self, node):
        title_class = docutils.nodes.title
        self.level += 1
        if node.children and isinstance(node.children[0], title_class):
            title = node.children[0].astext()
            node_id = node.get("ids")[0]
            self.titles.append([title, node_id, self.level])

    def depart_section(self, node):
        self.level -= 1



def get_local_toc(document):
    if not document:
        return ""
    visitor = TitleCollector(document)
    document.walkabout(visitor)
    titles = visitor.titles
    if not titles:
        return ""

    levels = sorted(set(item[2] for item in titles))
    if levels.index(titles[0][2]) != 0:
        return document.reporter.error(
            "First title on the page is not <h1/>")
    del titles[0]  # remove the <h1> title

    h1_seen = False
    ul_level = 0
    html_text = "<div id='toc-local' class='list-group'>\n"
    html_text += " <div class='header'><i class='fa fa-list'></i> Contents</div>\n"
    for title, node_id, level in titles:
        if level <= 1:
            return document.reporter.error("More than one <h1> title on the page")
        html_text += f"  <a href='#{node_id}' class='list-group-item level-{level-1}'>{title}</a>\n"
    html_text += "</div>\n"
    return html_text



# Emitted when the HTML builder has created a context dictionary to render
# a template with – this can be used to add custom elements to the context.
def on_html_page_context(app, pagename, templatename, context, doctree):
    context["get_local_toc"] = lambda: get_local_toc(doctree)


def setup(app):
    this_dir = os.path.dirname(__file__)
    theme_dir = os.path.abspath(os.path.join(this_dir, 'theme'))
    app.add_css_file('flames.css')
    app.add_html_theme('flames', theme_dir)
    app.connect("html-page-context", on_html_page_context)
