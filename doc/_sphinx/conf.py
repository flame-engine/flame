# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html


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
myst_heading_anchors = 2

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store', 'summary.md']


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.
html_theme = "sphinx_book_theme"

# See https://sphinx-book-theme.readthedocs.io/en/latest/customize/index.html
html_theme_options = {
    "logo_only": True,
    "path_to_docs": "doc",
    "repository_branch": "main",
    "repository_url": "https://github.com/flame-engine/flame",
    "use_edit_page_button": True,
    "use_repository_button": True,
}
html_title = "Flame"
html_logo = "images/logo_flame.png"
html_favicon = "images/favicon.ico"

# Style for syntax highlighting
pygments_style = 'monokai'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['images', 'styles', 'scripts']
html_css_files = ['custom.css']
html_js_files = ['versions.js']
