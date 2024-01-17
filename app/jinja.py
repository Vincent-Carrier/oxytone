from sanic import Sanic, html
from jinja2 import Environment, FileSystemLoader

from core.constants import PROD, ROOT

app = Sanic.get_app("oxytone")

jinja_env = Environment(
    loader=FileSystemLoader(ROOT / "templates"),
    auto_reload=not PROD,
    enable_async=True,
    trim_blocks=True,
    optimized=PROD,
)
jinja_env.globals["url_for"] = app.url_for


def template(name: str):
    tmpl = jinja_env.get_template(f"{name}.html")

    async def render(**kwargs):
        html_str = await tmpl.render_async(**kwargs)
        return html(html_str)

    return render
