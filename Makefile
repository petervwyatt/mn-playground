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


# Latest Ruby + Gems.
# Use different Gemfiles for flavours to allow customization (eg. forked Gems with mods)
.PHONY: build-bundle
build-bundle:
	$(RM) *.lock
	bundle install
	bundle exec metanorma site generate --agree-to-terms --output-dir _site_pdfa metanorma-pdfa.yml > bundle-pdfa.log 2>&1
	bundle exec metanorma site generate --agree-to-terms --output-dir _site_iso  metanorma-iso.yml  > bundle-iso.log 2>&1


# Build using Docker. SLOW using last stable MN.
# Removes containers once done. Named in case monitoring.
.PHONY: build-docker
build-docker:
	docker pull metanorma/metanorma
	docker run --name mn-test --rm --volume "$(shell $(PWD))":/metanorma/ -w /metanorma metanorma/metanorma metanorma site generate metanorma-pdfa.yml --output-dir _site_dpdfa --agree-to-terms > docker-pdfa.log  2>&1
	docker run --name mn-test --rm --volume "$(shell $(PWD))":/metanorma/ -w /metanorma metanorma/metanorma metanorma site generate metanorma-iso.yml  --output-dir _site_diso  --agree-to-terms > docker-iso.log  2>&1


# Build using AsciiDoctor (for debugging only!). VERY FAST but doesn't support many MN features.
.PHONY: build-asciidoctor
build-asciidoctor:
	cd source && \
	asciidoctor     --warnings --verbose --out-file asciidoctor.html test-pdfa.adoc > asciidoctor-html-pdfa.log 2>&1 && \
	asciidoctor     --warnings --verbose --out-file asciidoctor.html test-iso.adoc  > asciidoctor-html-iso.log 2>&1 && \
	asciidoctor-pdf --warnings --verbose --out-file asciidoctor.pdf  test-pdfa.adoc > asciidoctor-pdf-pdfa.log 2>&1 \
	asciidoctor-pdf --warnings --verbose --out-file asciidoctor.pdf  test-iso.adoc  > asciidoctor-pdf-iso.log 2>&1

