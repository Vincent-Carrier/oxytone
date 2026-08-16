"""Install Perseus English translations into tei/ for works GLAUx covers.

Reads a canonical-greekLit tarball on stdin-path and writes the `-eng*` editions
into tei/{author}/{work}/{edition}.xml. Upstream names files
`tlg0003.tlg001.perseus-eng1.xml`; tei/ carries the author and work in the
directory path instead, so the prefix is stripped to match the Greek editions
already there.

Files whose edition div is not xml:lang="eng" are skipped: a handful of upstream
`-eng` filenames hold Greek text.
"""

import os
import shutil
import sys
import tarfile
import tempfile
import xml.etree.ElementTree as ET
from glob import glob

XML_LANG = '{http://www.w3.org/XML/1998/namespace}lang'


def is_english(path):
	root = ET.parse(path).getroot()
	for div in root.iter():
		if div.tag.split('}')[-1] == 'div' and div.get('type') in ('edition', 'translation'):
			return div.get(XML_LANG) == 'eng'
	return False


def main(tarball):
	installed = skipped_lang = skipped_glaux = 0
	with tempfile.TemporaryDirectory() as tmp:
		with tarfile.open(tarball) as tar:
			members = [
				m for m in tar.getmembers() if m.name.endswith('.xml') and '-eng' in m.name
			]
			tar.extractall(tmp, members=members, filter='data')

		for src in sorted(glob(f'{tmp}/**/*.xml', recursive=True)):
			parts = os.path.basename(src).split('.')
			author, work, edition = parts[0], parts[1], '.'.join(parts[2:-1])
			if not glob(f'glaux/{author}/{work}/*.xml'):
				skipped_glaux += 1
				continue
			if not is_english(src):
				skipped_lang += 1
				continue
			dst = f'tei/{author}/{work}/{edition}.xml'
			os.makedirs(os.path.dirname(dst), exist_ok=True)
			shutil.copyfile(src, dst)
			installed += 1

	print(f'installed {installed} translations')
	print(f'skipped {skipped_glaux} not in glaux, {skipped_lang} not English')


if __name__ == '__main__':
	main(sys.argv[1])
