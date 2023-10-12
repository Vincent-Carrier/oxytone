
from core import corpus
from core.render import HtmlPartialRenderer

for slug, tb in corpus.all_treebanks().items():
    folder = tb.meta.partial_path.parent
    folder.mkdir(parents=True, exist_ok=True)
    meta = folder / "_index.md"
    meta.write_text((
        f"+++"
        f"title = '{tb.meta.title}'"
        f"author = '{tb.meta.author}'"
        f"+++"
    ))
    for chunk in tb.chunks():
        f = chunk.meta.partial_path
        f.write_text(HtmlPartialRenderer(chunk).render_hugo_page())
