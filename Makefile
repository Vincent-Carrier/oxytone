py := poetry run python
lexicons := data/ag/lsj.db
static := app/static
partials = $(wildcard build/**.html)
scss = $(wildcard $(static)/**.scss)
css = $(scss:.scss=.css)

.PHONY: default app partials css lexicons export test format clean

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

css: $(css)
$(css): $(scss)
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

$(lexicons):
	$(py) -m scripts.seed
