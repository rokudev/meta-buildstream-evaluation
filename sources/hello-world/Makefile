SRCS := hello.c
OUT := hello_app

all: $(OUT)

$(OUT): $(SRCS)
	@echo "~ Compiling '$<' -> '$@' with $(CC)"
	$(CC) -Wall -o $@ $<

install:
	@echo "~ Installing to ${DESTDIR}${PREFIX}/bin"
	install -d ${DESTDIR}${PREFIX}/bin
	install -m 755 $(OUT) ${DESTDIR}${PREFIX}/bin
