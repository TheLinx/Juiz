CPP = g++
CPPFLAGS = -W -Wall
LIBS = /usr/lib/liblua5.1.a /usr/lib/liblua5.1-socket.a /usr/lib/liblua5.1-mime.a -ldl
OUTPUT = juiz
FILES = juiz.cpp

all:
	$(CPP) $(CPPFLAGS) -o $(OUTPUT) $(FILES) $(LIBS)
