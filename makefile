include config.mk

PROGRAM=secret

.PHONY: all clean install uninstall

all: $(PROGRAM).1

clean:
	rm -f $(PROGRAM).1

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f $(PROGRAM).sh $(DESTDIR)$(PREFIX)/bin/$(PROGRAM)
	chmod 755 $(DESTDIR)$(PREFIX)/bin/$(PROGRAM)
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f $(PROGRAM).1 $(DESTDIR)$(MANPREFIX)/man1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/$(PROGRAM).1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(PROGRAM)
	rm -f $(DESTDIR)$(MANPREFIX)/man1/$(PROGRAM).1

$(PROGRAM).1:
	$(SCDOC) < $(PROGRAM).1.scd > $@
