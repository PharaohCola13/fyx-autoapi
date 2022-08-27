#> file:  ./docsrc/conf.py
#> synopsis: 
#> author:   <>
import os
import sys

sys.path.insert(0, os.path.abspath('../'))

project = 'Sphinx test with Fyx generated API'
copyright = '2022, Spencer Riley'
author = 'Spencer Riley'
version = ''
release = ''

# -- General configuration

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.autosummary',
    'sphinx.ext.coverage',
    'sphinx.ext.napoleon',
    'sphinx.ext.viewcode',
]

# -- Options for HTML output
html_title = 'Fyx Sample'
#html_logo = 'banner_icon.png'
#html_favicon = 'icon.png'

# html_css_files = [
#     'css/custom.css',
# ]
html_copy_source = False

html_theme = 'sphinx_rtd_theme'

# html_static_path = ["assets"]

# html_theme_options = {
#     'logo_only': True,
# }

# -- Options for LaTeX output
latex_engine = 'pdflatex'
latex_elements = {
    'papersize': 'a4paper',
    'pointsize': '11pt',
    }
latex_documents = [
 ('index', 'fyx-sample.tex', u'Fyx Sample', u'Spencer Riley', 'manual'),
]
#latex_logo = 'banner_icon.png'
latex_domain_indices = True
latex_show_urls = 'footnote'
latex_use_xindy = False
# -- Options for EPUB output
epub_show_urls = 'footnote'