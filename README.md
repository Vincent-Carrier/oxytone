# Pyrrho

Pyrrho is a tool for generating syntax-highlighted texts for ancient languages. It uses treebanks (XML files containing morphological and syntactical annotations) [from the PerseusDL project](https://perseusdl.github.io/treebank_data/). Additionally, it lets you quickly create [Anki flashcards](https://apps.ankiweb.net/) from the text so you can remember new vocabulary.

## Getting started

First off, you'll need `poetry`, and `npm` installed.

-   [Install Poetry](https://python-poetry.org/docs/#installation)
-   Depending on your distro, you may also need [PyEnv](https://github.com/pyenv/pyenv) to [get the right Python version running](https://python-poetry.org/docs/managing-environments/)

Now, run `make deps` to install all dependencies.

Run `make watch` to start the development server.
