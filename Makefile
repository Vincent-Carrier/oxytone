py := poetry run python
lexicons := data/ag/lsj.db
static := app/static
partials = $(wildcard build/**.html)
scss = $(wildcard $(static)/**.scss)
css = $(scss:%.scss=%.css)
sass = npx sass -Istyles -Inode_modules $(static):$(static)
esbuild = npx esbuild app/static/reader.ts --outdir=app/static --bundle --target=es2020 --sourcemap
browsersync = npx browser-sync start --proxy 'localhost:5000' -w -f app/** --no-open

.PHONY: default app partials css lexicons export test format clean chunks


watch:
	$(sass) --watch &
	$(esbuild) --watch=forever &
	$(browsersync) &
	$(MAKE) app

install:
	poetry install
	npm install
	$(MAKE) lexicons chunks

app: $(lexicons)
	$(py) -m app.main

partials:
	$(py) -m scripts.partials

css:
	$(sass)

js:
	$(esbuild)

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
