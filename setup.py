# -*- coding: utf-8 -*-
import sys
from os import path
from distutils.core import setup

if sys.version_info < (2, 7):
    sys.exit('hyoid requires Python 2.7 or higher')

ROOT_DIR = path.abspath(path.dirname(__file__))
sys.path.insert(0, ROOT_DIR)

from hyoid import VERSION  # noqa
from hyoid import __doc__ as DESCRIPTION  # noqa
LONG_DESCRIPTION = open(path.join(ROOT_DIR, 'README.rst')).read()

HYSRC = ['**.hy']

setup(
    name='hyoid',
    version=VERSION,
    description=DESCRIPTION,
    long_description=LONG_DESCRIPTION,
    author='Philip Xu',
    author_email='pyx@xrefactor.com',
    url='https://github.com/pyx/hyoid/',
    download_url=(
        'https://bitbucket.org/pyx/hyoid/get/%s.tar.bz2' % VERSION),
    classifiers=[
        'Development Status :: 4 - Beta',
        'Framework :: Flask',
        'Intended Audience :: End Users/Desktop',
        'License :: OSI Approved :: BSD License',
        'Operating System :: OS Independent',
        'Programming Language :: Lisp',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Topic :: Communications :: BBS',
    ],
    install_requires=[
        'bleach>=1.4.3',
        'Flask>=0.11.1',
        'Flask-Gravatar>=0.4.2',
        'Flask-Login>=0.3.2',
        'Flask-Moment>=0.5.1',
        'Flask-Pure>=0.3',
        'Flask-Script>=2.0.5',
        'Flask-SimpleMDE>=0.3.0',
        'Flask-SQLAlchemy>=2.1',
        'Flask-WTF>=0.13.1',
        'hy>=0.11.1',
        'Markdown>=2.6.7',
        'Pygments>=2.1.3',
    ],
    extras_require={
        'dev': [
            'twine',
        ],
        'test': [
            'pytest>=2.6.4',
            'pytest-cov>=1.8.1',
        ],
    },
    packages=['hyoid'],
    package_data={'hyoid': HYSRC},
    license='BSD-New',
)
