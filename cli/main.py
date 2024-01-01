from typing import Optional, TypeAlias

import typer
from rich.console import Console
from rich.table import Table
from typing_extensions import Annotated

from core import corpus
from core.corpus import DocId, LangId

from .render import TerminalRenderer

app = typer.Typer()
console = Console()

LangOpt: TypeAlias = Annotated[Optional[LangId], typer.Option()]


@app.command()
def ls(lang: LangOpt = None) -> None:
    """List all treebanks"""
    table = Table()
    table.add_column("slug")
    table.add_column("title")
    table.add_column("author")
    if lang is None:
        table.add_column("lang")
    for slug, meta in corpus.corpus_index(lang).items():
        table.add_row(slug, meta.title, meta.author, *filter(None, [meta.lang]))
    console.print(table)


@app.command()
def cat(lang: LangId, slug: DocId, ref: str) -> None:
    """Print a passage to stdin"""
    tb = corpus.get_treebank(lang, slug)
    passage = tb[ref]
    TerminalRenderer(passage).render()


app()
