py := poetry run python
lexicons := data/lsj.db
static := app/static
partials = $(wildcard build/**.html)
scss = $(wildcard $(static)/**.scss)
css = $(scss:%.scss=%.css)
sass = npx sass -Istyles -Inode_modules $(static):$(static)
esbuild = npx esbuild app/static/reader.ts --outdir=app/static --bundle --target=es2020 --sourcemap
browsersync = npx browser-sync start --proxy 'localhost:5000' --host '0.0.0.0' -w -f app/** --no-open

.PHONY: default app partials css lexicons export test format clean chunks static

app: $(lexicons)
	$(py) -m app.main

watch:
	$(sass) --watch &
	poetry run watchmedo shell-command -p "*.ts" -c "$(esbuild)" -W $(static) &
	$(browsersync) & bspid=$!
	$(MAKE) app
	kill $bspid

deps:
	poetry install & npm install
	$(MAKE) lexicons chunks

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

lexicons: $(lexicons)

$(lexicons):
	$(py) -m scripts.seed

chunks:
	rm -rf data/treebanks/index.json
	rm -rf data/treebanks/chunks/**
	$(py) -m scripts.chunkup

static:
	wget -r -nH -P build \
		--page-requisites \
		--html-extension \
		localhost:5000

clean:
	rm -f $(lexicons)
	rm -rf $(static)/**.{css,css.map,js,js.map}
	rm -rf data/treebanks/chunks/**
	rm -rf data/treebanks/index.json
	rm -rf tmp/**
	rm -rf build/**