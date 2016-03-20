#
# Make -- the OG build tool.
# Add any build tasks here and abstract complex build scripts into `lib` that
# can be run in a Makefile task like `coffee lib/build_script`.
#
# Remember to set your text editor to use 4 size non-soft tabs.
#

BIN = node_modules/.bin
BOOTSTRAP_STYLUS = node_modules/bootstrap-styl
# Start the server
s:
	APP_URL=http://localhost:5000 APP_NAME=rudy-development foreman start

# Start the server using forever
sf:
	$(BIN)/forever $(BIN)/coffee --nodejs --max_old_space_size=960 index.coffee

# Run all of the project-level tests, followed by app-level tests
test: lint assets
	$(BIN)/mocha $(shell find test -name '*.coffee' -not -path 'test/helpers/*')
	$(BIN)/mocha $(shell find apps/*/test -name '*.coffee' -not -path 'test/helpers/*')

# Run Coffeelint to check coffeescript styles
lint:
	$(BIN)/coffeelint $(shell find . -name '*.coffee' -not -path './node_modules/*')

# Generate minified assets from the /assets folder and output it to /public.
assets:
	mkdir -p public/assets
	$(foreach file, $(shell find assets -name '*.coffee' | cut -d '.' -f 1), \
		$(BIN)/browserify $(file).coffee -t jadeify -t caching-coffeeify > public/$(file).js; \
		$(BIN)/uglifyjs public/$(file).js > public/$(file).min.js; \
	)
	$(BIN)/stylus assets -o public/assets -I $(BOOTSTRAP_STYLUS)
	$(foreach file, $(shell find assets -name '*.styl' | cut -d '.' -f 1), \
		$(BIN)/sqwish public/$(file).css -o public/$(file).min.css; \
	)

# Runs all the necessary build tasks to push to staging or production.
# Run with `make deploy env=staging` or `make deploy env=production`.
deploy: assets
	$(BIN)/bucket-assets --bucket rudy-$(env)
	heroku config:set COMMIT_HASH=$(shell git rev-parse --short HEAD) --app=rudy-$(env)
	git push --force git@heroku.com:rudy-$(env).git $(shell git rev-parse --short HEAD):refs/heads/master

.PHONY: test assets deploy
