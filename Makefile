# Stub name for docker containers (so can be meaningfully monitored)
DOCKER_NAME := mn-playground

# Name of main AsciiDoc file for PDFa publication (in YAML file for MN, but needed for AsciiDoctor CLI)
MAIN_PDFA_ADOC := test-pdfa.adoc
MAIN_ISO_ADOC  := test-iso.adoc


# Check for Windows_NT environment variable (cmd.exe/PowerShell)
OS ?= $(shell echo %OS% 2>/dev/null)  # Fetch %OS% from Windows shell
ifeq ($(OS),Windows_NT)
    IS_WINDOWS := 1  # Confirmed Windows (cmd.exe/PowerShell)
		RM:=del /F/S/Q
		RMDIR:=rmdir /Q/S
		CP:=copy /Y
		SEP:=\\
		PWD:=cd
else
    # Not Windows cmd.exe; check via `uname -s` (Unix-like shells)
    UNAME_S := $(shell uname -s 2>/dev/null)  # Get OS name (e.g., Linux, Darwin)
		RMDIR:=rm -rf
		CP:=cp
		SEP:=/
		PWD:=pwd
    
    # Detect Unix-like systems (Linux/macOS)
    ifeq ($(UNAME_S),Linux)
        IS_UNIX := 1
    else ifeq ($(UNAME_S),Darwin)  # macOS uses "Darwin"
        IS_UNIX := 1
    # Detect Windows subsystems (MINGW64, CYGWIN, etc.)
    else ifneq ($(filter MINGW%,$(UNAME_S)),)  # Git Bash/MinGW
        IS_WINDOWS := 1
    else ifneq ($(filter CYGWIN%,$(UNAME_S)),)  # Cygwin
        IS_WINDOWS := 1
    else
        # Fallback: Assume Unix-like if unrecognized
        IS_UNIX := 1
    endif
endif

# Clean up all outputs that can be re-created. Does NOT delete Gemfile.lock!
# Windows doesn't support wildcards for folder names.
.PHONY: clean
clean:
	-@$(RMDIR) iev relaton
	-@$(RMDIR) _site_diso _site_dpdfa _site_iso _site_pdfa _site
	-@$(RM) *.log
	-@$(RM) *.abort 
	-@$(RM) *.log.txt
	-@$(RM) *.err.*
	-@$(RM) *asciidoc*
	-@$(RM) docker*.*


# Latest Ruby + Gems.
# Use different Gemfiles for flavours to allow customization (eg. forked Gems with mods)
.PHONY: build-bundle
build-bundle:
	bundle install
	bundle exec metanorma site generate --agree-to-terms --output-dir _site_pdfa metanorma-pdfa.yml > bundle-pdfa.log 2>&1
	bundle exec metanorma site generate --agree-to-terms --output-dir _site_iso  metanorma-iso.yml  > bundle-iso.log  2>&1


# Build using Docker. SLOW using last stable MN.
# Removes containers once done. Named in case monitoring.
.PHONY: build-docker
build-docker:
	docker pull metanorma/metanorma
	docker run --name $(DOCKER_NAME) --rm --volume .:/metanorma/ -w /metanorma metanorma/metanorma metanorma site generate metanorma-pdfa.yml --output-dir _site_dpdfa --agree-to-terms > docker-pdfa.log 2>&1
	docker run --name $(DOCKER_NAME) --rm --volume .:/metanorma/ -w /metanorma metanorma/metanorma metanorma site generate metanorma-iso.yml  --output-dir _site_diso  --agree-to-terms > docker-iso.log  2>&1


# Build using AsciiDoctor via bundle (for debugging only!). VERY FAST but doesn't support many MN features.
.PHONY: build-asciidoctor-bundle
build-asciidoctor-bundle:
	$(CP) .$(SEP)publication-info$(SEP)docinfo-*.* .
	bundle install
	bundle exec asciidoctor     --warnings --verbose --require .$(SEP)publication-info$(SEP)mn-override.rb --out-file asciidoctor-bundle-pdfa.html $(MAIN_PDFA_ADOC) > asciidoctor-html-bundle-pdfa.log 2>&1
	bundle exec asciidoctor     --warnings --verbose --require .$(SEP)publication-info$(SEP)mn-override.rb --out-file asciidoctor-bundle-iso.html  $(MAIN_ISO_ADOC)  > asciidoctor-html-bundle-iso.log 2>&1
	bundle exec asciidoctor-pdf --warnings --verbose --theme .$(SEP)publication-info$(SEP)pdfa-theme.yml --require .$(SEP)publication-info$(SEP)mn-override.rb --out-file asciidoctor-bundle-pdfa.pdf  $(MAIN_PDFA_ADOC) > asciidoctor-pdf-bundle-pdfa.log 2>&1
	bundle exec asciidoctor-pdf --warnings --verbose --theme .$(SEP)publication-info$(SEP)pdfa-theme.yml --require .$(SEP)publication-info$(SEP)mn-override.rb --out-file asciidoctor-bundle-iso.pdf   $(MAIN_ISO_ADOC)  > asciidoctor-pdf-bundle-iso.log 2>&1


# Build using AsciiDoctor (for debugging only!). VERY FAST but doesn't support many MN features.
.PHONY: build-asciidoctor
build-asciidoctor:
	$(CP) .$(SEP)publication-info$(SEP)docinfo-*.* .
	asciidoctor     --warnings --verbose --require .$(SEP)publication-info$(SEP)mn-override.rb --out-file asciidoctor-pdfa.html $(MAIN_PDFA_ADOC) > asciidoctor-html-pdfa.log 2>&1
	asciidoctor     --warnings --verbose --require .$(SEP)publication-info$(SEP)mn-override.rb --out-file asciidoctor-iso.html  $(MAIN_ISO_ADOC)  > asciidoctor-html-iso.log 2>&1
	asciidoctor-pdf --warnings --verbose --theme .$(SEP)publication-info$(SEP)pdfa-theme.yml --require .$(SEP)publication-info$(SEP)mn-override.rb --out-file asciidoctor-pdfa.pdf  $(MAIN_PDFA_ADOC) > asciidoctor-pdf-pdfa.log 2>&1
	asciidoctor-pdf --warnings --verbose --theme .$(SEP)publication-info$(SEP)pdfa-theme.yml --require .$(SEP)publication-info$(SEP)mn-override.rb --out-file asciidoctor-iso.pdf   $(MAIN_ISO_ADOC)  > asciidoctor-pdf-iso.log 2>&1


# Build using AsciiDoctor Docker (for debugging only!). FAST-ish but still doesn't support all MN features.
.PHONY: build-asciidoctor-docker
build-asciidoctor-docker:
	$(CP) .$(SEP)publication-info$(SEP)docinfo-*.* .
	docker pull asciidoctor/docker-asciidoctor
	docker run --name $(DOCKER_NAME) --rm --volume .:/documents asciidoctor/docker-asciidoctor sh -c "asciidoctor     --warnings --verbose --require ./publication-info/mn-override.rb --require asciidoctor-diagram --require asciidoctor-mathematical --out-file dockerad-pdfa.html $(MAIN_PDFA_ADOC) > docker-adoc-pdfa-html.log 2>&1"
	docker run --name $(DOCKER_NAME) --rm --volume .:/documents asciidoctor/docker-asciidoctor sh -c "asciidoctor     --warnings --verbose --require ./publication-info/mn-override.rb --require asciidoctor-diagram --require asciidoctor-mathematical --out-file dockerad-iso.html  $(MAIN_ISO_ADOC)  > docker-adoc-iso-html.log 2>&1"
	docker run --name $(DOCKER_NAME) --rm --volume .:/documents asciidoctor/docker-asciidoctor sh -c "asciidoctor-pdf --warnings --verbose --theme ./publication-info/pdfa-theme.yml --require ./publication-info/mn-override.rb --require asciidoctor-diagram --require asciidoctor-mathematical --out-file dockerad-pdfa.pdf  $(MAIN_PDFA_ADOC) > docker-adoc-pdfa-pdf.log 2>&1"
	docker run --name $(DOCKER_NAME) --rm --volume .:/documents asciidoctor/docker-asciidoctor sh -c "asciidoctor-pdf --warnings --verbose --theme ./publication-info/pdfa-theme.yml --require ./publication-info/mn-override.rb --require asciidoctor-diagram --require asciidoctor-mathematical --out-file dockerad-iso.pdf   $(MAIN_ISO_ADOC)  > docker-adoc-iso-pdf.log 2>&1"

