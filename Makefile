md := $(shell find _recipes -name '*.md')
html := $(patsubst _recipes/%.md,_site/%.html,$(md))
meta := $(patsubst _recipes/%.md,_temp/%.metadata.json,$(md))

html: $(html)

assets:
	cp -r _assets/ _site/assets/

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
