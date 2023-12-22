py := poetry run python
lexicons := data/ag/lsj.db
static := app/static
partials = $(wildcard build/**.html)
scss = $(wildcard $(static)/**.scss)
css = $(scss:%.scss=%.css)

.PHONY: default app partials css lexicons export test format clean chunks

default:
	poetry install
	npm install

watch:
	npx sass -Istyles -Inode_modules $(static):$(static) --watch &
	$(MAKE) app

app: $(lexicons)
	$(py) -m app.main

partials:
	$(py) -m scripts.partials

css:
	npx sass -Istyles -Inode_modules $(static):$(static)

test:
	poetry run pytest

format:
	poetry run black .

db_clean:
	rm -f $(lexicons)

partials_clean:
	rm -rf build/

assets_clean:
	rm -rf $(static)/**.map $(static)/**.css


lexicons: $(lexicons)

chunks:
	rm -rf data/out/**
	$(py) -m scripts.chunkup

$(lexicons):
	$(py) -m scripts.seed
