PREFIX ?= /usr
BINDIR = $(DESTDIR)$(PREFIX)/bin
SRCDIR = src
TARGET = wpspin
SOURCE = $(SRCDIR)/wpspin.nim

.PHONY: all install uninstall

all: $(TARGET)

$(TARGET): $(SOURCE)
	nimble install -y argparse
	nim compile --gc:none --checks:off --out:$@ $(SOURCE)
	strip $@
	nimble uninstall -y argparse

install: $(TARGET)
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 $< $(DESTDIR)$(BINDIR)

uninstall:
	rm $(BINDIR)/$(TARGET)

clean:
	rm -f $(TARGET)
