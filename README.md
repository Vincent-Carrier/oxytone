# Oxytone

Oxytone is a tool for generating syntax-highlighted texts for ancient languages. It uses treebanks (XML files containing morphological and syntactical annotations) [from the PerseusDL project](https://perseusdl.github.io/treebank_data/). Additionally, it lets you quickly create [Anki flashcards](https://apps.ankiweb.net/) from the text so you can remember new vocabulary.

## Getting started

First off, you'll need `npm` installed and `pipenv` installed. Depending on your OS, you may also need [PyEnv](https://github.com/pyenv/pyenv) to get the right Python version running. **This project requires `3.11`** (use `python -V` to make sure).

```sh
./tasks init
./tasks watch
```
