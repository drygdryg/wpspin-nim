PREFIX ?= /usr
BINDIR = $(DESTDIR)$(PREFIX)/bin
SRCDIR = src
TARGET = wpspin
SOURCE = $(SRCDIR)/wpspin.nim

.PHONY: all install uninstall

all: $(TARGET)

$(TARGET): $(SOURCE)
	nimble build -y -d:release
	strip $@

install: $(TARGET)
	install -d $(BINDIR)
	install -m 755 $< $(BINDIR)

uninstall:
	rm $(BINDIR)/$(TARGET)

clean:
	rm -f $(TARGET)
