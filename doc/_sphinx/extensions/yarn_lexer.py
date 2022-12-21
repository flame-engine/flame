import os
import shutil
from pygments.lexer import RegexLexer, bygroups, default, include, words
from pygments.token import *


class YarnLexer(RegexLexer):
    name = 'YarnSpinner'
    aliases = ['yarn', 'jenny']
    filenames = ['*.yarn']
    mimetypes = ['text/yarn']

    CONSTANTS = [
        'Bool',
        'Numeric',
        'String',
        'false',
        'true',
    ]
    OPERATORS = [
        'and',
        'as',
        'eq',
        'ge',
        'gt',
        'gte',
        'is',
        'le',
        'lt',
        'lte',
        'ne',
        'neq',
        'not',
        'or',
        'to',
        'xor',
    ]
    BUILTIN_COMMANDS = [
        'character',
        'declare',
        'else',
        'elseif',
        'embed',
        'endif',
        'if',
        'jump',
        'local',
        'set',
        'stop',
        'visit',
        'wait',
    ]
    BUILTIN_FUNCTIONS = [
        'bool',
        'ceil',
        'dec',
        'decimal',
        'dice',
        'floor',
        'inc',
        'int',
        'number',
        'plural',
        'random',
        'random_range',
        'round',
        'round_places',
        'string',
        'visit_count',
        'visited',
    ]

    tokens = {
        'root': [
            include('<whitespace>'),
            include('<commands>'),
            (r'#[^\n]*\n', Comment.Hashbang),
            (r'---+\n', Punctuation, 'node_header'),
            default('node_header'),
        ],

        '<whitespace>': [
            (r'\s+', Whitespace),
            (r'//.*\n', Comment),
        ],

        'node_header': [
            include('<whitespace>'),
            (r'---+\n', Punctuation, 'node_body'),
            (r'(title)(:)(.*?\n)', bygroups(Name.Builtin, Punctuation, Name.Variable)),
            (r'(\w+)(:)(.*?\n)', bygroups(Name, Punctuation, Text)),
            default('node_body'),
        ],
        'node_body': [
            (r'===+\n', Punctuation, '#pop:2'),
            include('<whitespace>'),
            default('line_start'),
        ],

        'line_start': [
            (r'\s+', Whitespace),
            (r'->', Punctuation),
            (r'(\w+)(\s*:\s*)', bygroups(Name.Tag, Punctuation)),
            default('line_continue'),
        ],
        'line_continue': [
            (r'\n', Whitespace, '#pop:2'),
            (r'\s+', Whitespace),
            (r'//[^\n]*', Comment),
            (r'\\[\[\]\\{}<>/:#]', String.Escape),
            (r'\\\n\s*', String.Escape),
            (r'\\.', Error),
            (r'\{', Punctuation, 'curly_expression'),
            include('<commands>'),
            include('<markup>'),
            (r'#[^\s]+', Comment.Hashbang),
            (r'[<>/]', Text),
            (r'[^\n\\\[\]{}<>/#]+', Text),
            (r'.', Text),  # just in case
        ],

        '<commands>': [
            (r'<<', Punctuation, 'command_name'),
        ],
        'command_name': [
            (words(BUILTIN_COMMANDS, suffix=r'\b'), Keyword, 'command_body'),
            (r'\w+', Name.Class, 'command_custom'),
        ],
        'command_body': [
            include('<whitespace>'),
            (r'\{', Punctuation, 'curly_expression'),
            (r'>>', Punctuation, '#pop:2'),
            (r'>', Text),
            default('command_expression'),
        ],
        'command_custom': [
            include('<whitespace>'),
            (r'>>', Punctuation, '#pop:2'),
            (r'\{', Punctuation, 'curly_expression'),
            (r'[^>{\n]+', Text),
            ('.', Text),
        ],

        '<expression>': [
            (r'\n', Error),
            (r'\s+', Whitespace),
            (r'(//.*)(\n)', bygroups(Comment, Error)),
            (words(BUILTIN_FUNCTIONS, suffix=r'\b'), Name.Builtin),
            (words(CONSTANTS, suffix=r'\b'), Name.Builtin),
            (words(OPERATORS, suffix=r'\b'), Operator),
            (r'\$\w+', Name.Variable),
            (r'([+\-*/%><=]=?)', Operator),
            (r'\d+(?:\.\d+)?(?:[eE][+\-]?\d+)?', Number),
            (r'[(),]', Punctuation),
            (r'"', String.Delimeter, 'string'),
            (r'\w+', Name.Function),
            (r'.', Error),
        ],
        'command_expression': [
            (r'>>', Punctuation, '#pop:3'),
            include('<expression>'),
        ],
        'curly_expression': [
            (r'\}', Punctuation, '#pop'),
            include('<expression>'),
        ],
        'string_expression': [
            (r'\}', String.Interpol, '#pop'),
            include('<expression>'),
        ],

        '<markup>': [
            (r'\[', String.Backtick, 'markup_start'),
        ],
        'markup_start': [
            (r'/?\w+', String.Backtick, 'markup_body'),
            (r'/?\]', String.Backtick, '#pop'),
        ],
        'markup_body': [
            (r'/?\]', String.Backtick, '#pop:2'),
            (r'[^/\]]+', String.Backtick),
        ],

        'string': [
            (r'"', String.Delimeter, '#pop'),
            (r'{', String.Interpol, 'string_expression'),
            (r'[^"{\n\\]+', String),
            (r'\\[nt"{}]', String.Escape),
            (r'\n', Error),
        ],
    }


def setup(app):
    base_dir = os.path.dirname(__file__)
    target_dir = os.path.abspath('../_build/html/_static/')
    os.makedirs(target_dir, exist_ok=True)
    shutil.copy(os.path.join(base_dir, 'yarn_lexer.css'), target_dir)

    app.add_css_file('yarn_lexer.css')
    app.add_lexer('yarn', YarnLexer)
    return {
        'parallel_read_safe': True,
        'parallel_write_safe': True,
        'env_version': 1,
    }
