BIN=snake
RM=rm -f

all: $(BIN)

$(BIN):
	sbcl --non-interactive --load compile.lisp

clean:
	$(RM) $(BIN)
