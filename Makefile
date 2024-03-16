PROG = indent
SRCS = indent.c io.c lexi.c parse.c pr_comment.c args.c
CC = gcc
CFLAGS = -Wall

all: $(PROG)
clean:
	rm -f $(SRCS:.c=.o) $(PROG)

test: $(PROG)
	$(MAKE) -C tests test

$(PROG): $(SRCS:.c=.o)
	$(CC) $(CFLAGS) -o $@ $^
%.o: %.c
	$(CC) $(CFLAGS) -c $<
