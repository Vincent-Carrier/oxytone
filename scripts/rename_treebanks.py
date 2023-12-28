from os import rename
from posixpath import basename
from xml.etree.ElementTree import XMLParser
from bs4 import BeautifulSoup

import requests
from slugify import slugify
from core.constants import TREEBANKS
from lxml import etree

dir = TREEBANKS / "perseus/1.6"
for f in dir.glob("*.xml"):
    if not f.name.startswith("tlg"):
        continue
    urn_short, edition = f.name.rstrip(".tb.xml").rsplit(".", 1)
    urn = f"urn:cts:greekLit:{urn_short}"
    try:
        html = requests.get(
            "https://catalog.perseus.org/",
            params={"utf8": "✓", "search_field": "urn", "q": urn},
        ).text
        soup = BeautifulSoup(html, "html.parser")
        author = soup.select_one("dd.blacklight-exp_auth_name").text
        title = soup.select_one(".index_title>a").text
        if title in ["Iliad", "Odyssey"]:
            continue
        # print(title, author, urn)
        slug = slugify(f"{author} {title} {edition}")
        new = f.parent / f"{slug}.xml"
        print(new)
        rename(f, new)
    except:
        print(f"failed to match {urn}")
