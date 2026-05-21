# Playground for testing MN stuff

Minimal stuff, but still highly indicative of the way that PDFa repos use MN for both ISO and PDFa flavors.

```bash
make clean
make build-bundle
make build-docker
make build-asciidoctor
make build-asciidoctor-docker
```

Currently does NOT use the [custom Ruby code](https://github.com/pdf-association/publication-info/blob/main/mn-override.rb) to pre-process and transform MN markup to pure AsciiDoc.

## Messing around with pdfa.xsl

The XSL, etc. used for controlling PDFa outout is located for me at `C:\Ruby40-x64\lib\ruby\gems\4.0.0\gems\metanorma-taste-1.0.4\data\pdfa\`. Files can be changed in my forked repo <https://github.com/petervwyatt/metanorma-taste> in `./data/pdfa/` then copied to this location for testing. Alternatively modify Gemfile by adding the line `gem 'metanorma-taste', git: 'https://github.com/petervwyatt/metanorma-taste'` - but remember to remove this later!
