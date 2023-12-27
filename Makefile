md := $(shell find _recipes -name '*.md')
html := $(patsubst _recipes/%.md,_site/%.html,$(md))
meta := $(patsubst _recipes/%.md,_temp/%.metadata.json,$(md))

open: html
	open _site/index.html

legacy:
	bash build.sh

build: init meta html

rebuild: clean build

html: $(html)

clean:
	rm -r _site/
	rm -r _temp/

init:
	mkdir -p _site/
	mkdir -p _temp/
	cp -r _assets/ _site/assets/
	for FILE in _recipes/*; do [[ "$$FILE" == *.md ]] || cp "$$FILE" _site/; done

_temp/%.category.txt: _recipes/%.md
	pandoc '$<' \
		--metadata-file config.yaml \
		--metadata basename='$(basename $<)' \
		--template _templates/technical/category.template.txt \
		-t html -o '$@'

_temp/%.metadata.json: _recipes/%.md
	pandoc '$<' \
		--metadata htmlfile='$(basename $<).html' \
		--template _templates/technical/metadata.template.json \
		-t html -o '$@'

_site/%.html: _recipes/%.md _temp/%.category.txt
	pandoc '$<' \
		--metadata-file config.yaml \
		--metadata basename='$(basename $<)' \
		--metadata category_faux_urlencoded="$$(cat '$(filter-out $<,$^)' | cut -d" " -f2- | awk -f "_templates/technical/faux_urlencode.awk")" \
		--metadata updatedtime="$$(date -r '$<' "+%Y-%m-%d")" \
		--template _templates/recipe.template.html \
		-o $@
