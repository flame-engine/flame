import sys

if sys.version_info < (3,8):
    print('Error: Python 3.8+ is required')
    sys.exit(2)