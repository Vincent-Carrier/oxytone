# Oxytone

A web application for studying Ancient Greek texts with integrated lexical, syntactic, and morphological analysis tools.

## Project Description

Oxytone provides an interactive reading environment for Ancient Greek texts with:

- Integration with LSJ dictionary (taken from [Giuseppe Celano's Unicode version](https://github.com/gcelano/LSJ_GreekUnicode))
- Morphological analysis and highlighting of verb complements
- Flashcard generation for vocabulary learning via [Anki](https://ankiweb.net/)

Oxytone includes the full [GLAUx corpus](https://github.com/alekkeersmaekers/glaux), which contains most Ancient Greek texts. However, most of these texts have been annotated automatically through machine learning. See [Keersmaekers, Alek (2021)](https://aclanthology.org/2021.lchange-1.6/) for more details and a breakdown of annotation accuracy. GLAUx itself is based on the hard work of the people behind the Perseus and Perseids Projects, along many others.

## Project Structure

```
oxytone/
  webapp/           # BaseX RESTXQ endpoints
  repo/             # XQuery modules
  seed/             # XQuery seeding scripts
  app/              # Python FastAPI backend (for Anki flashcards)
  src/              # SvelteKit frontend
  static/           # Static assets for SvelteKit
  glaux/            # GLAUx corpus files
  tei/              # TEI corpus files
  lsj/              # LSJ dictionary resources
```

## Requirements

Follow the installation instructions on their respective websites:

- [`basex`](https://basex.org/download/): XML database
- [`uv`](https://docs.astral.sh/uv/#installation): Python package manager
- [`pnpm`](https://pnpm.io/installation): JavaScript package manager
- [`just`](https://just.systems/man/en/packages.html): Task runner
- [Saxon-HE](https://github.com/Saxonica/Saxon-HE/): XSLT processor for BaseX (this can be installed automatically with `just saxon`)

## Getting Started

```bash
# Install dependencies
uv venv # create Python venv
source .venv/bin/activate.sh # might be different based on your shell
just install

# Seed the databases
just seed
```

See [CLAUDE.md](./CLAUDE.md) for more detailed development guidelines.
