
RM = rm -rf
CHMOD = chmod
MKDIR = mkdir -p
VENDOR = vendor
PHPCS = vendor/bin/phpcs
PHPCS_STANDARD = vendor/thefox/phpcsrs/Standards/TheFox
PHPCS_OPTIONS = -v -s --colors --report=full --report-width=160 --standard=$(PHPCS_STANDARD)
PHPUNIT = vendor/bin/phpunit
COMPOSER = ./composer.phar
COMPOSER_OPTIONS ?= --no-interaction

# Local installed PHPStan while supporting PHP 5.
# PHPStan requires PHP 7.
PHPSTAN = ~/.composer/vendor/bin/phpstan


.PHONY: all
all: install test

.PHONY: install
install: $(VENDOR)

.PHONY: update 
update: $(COMPOSER)
	$(COMPOSER) selfupdate
	$(COMPOSER) update

.PHONY: test
test: test_phpcs test_phpunit

.PHONY: test_phpstan
test_phpstan:
	$(PHPSTAN) analyse --level 5 --no-progress src tests

.PHONY: test_phpcs
test_phpcs: $(PHPCS) $(PHPCS_STANDARD)
	$(PHPCS) $(PHPCS_OPTIONS) src tests

.PHONY: test_phpunit
test_phpunit: $(PHPUNIT) phpunit.xml
	$(PHPUNIT) $(PHPUNIT_OPTIONS)

.PHONY: test_phpunit_cc
test_phpunit_cc: build
	$(MAKE) test_phpunit PHPUNIT_OPTIONS="--coverage-html build/report"

.PHONY: clean
clean:
	$(RM) composer.lock $(COMPOSER) $(VENDOR)

$(VENDOR): $(COMPOSER)
	$(COMPOSER) install $(COMPOSER_OPTIONS)

$(COMPOSER):
	curl -sS https://getcomposer.org/installer | php
	$(CHMOD) u=rwx,go=rx $(COMPOSER)

$(PHPCS): $(VENDOR)

$(PHPUNIT): $(VENDOR)

build:
	$(MKDIR) $@
	$(CHMOD) u=rwx,go-rwx $@
