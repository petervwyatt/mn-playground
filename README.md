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
