# Copyright (c) 2016, Philip Xu <pyx@xrefactor.com>
# License: BSD New, see LICENSE for details.
"""Hyoid - Forum in Hy"""

__version__ = (0, 1)
__release__ = '.dev0'

VERSION = '%d.%d' % __version__ + __release__

try:
    # make .hy file importable
    import hy  # noqa
except ImportError:
    # ignore import error, need this for setup.py: import .version
    pass
