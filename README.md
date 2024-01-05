# Pyrrho

Pyrrho is a tool for generating syntax-highlighted texts for ancient languages. It uses treebanks (XML files containing morphological and syntactical annotations) [from the PerseusDL project](https://perseusdl.github.io/treebank_data/). Additionally, it lets you quickly create [Anki flashcards](https://apps.ankiweb.net/) from the text so you can remember new vocabulary.

## Getting started

First off, you'll need `npm` installed. Depending on your OS, you may also need [PyEnv](https://github.com/pyenv/pyenv) to get the right Python version running. **This project requires `3.12` or greater** (use `python -V` to make sure).

Now, run `./tasks deps` to create your virtual env and install all dependencies.

Run `./tasks watch` to start the development server.
