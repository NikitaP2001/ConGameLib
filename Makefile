SHELL=cmd.exe
TARGET = congame.lib

SRC_DIR = src
OBJ_DIR = obj
INC_DIR = inc
LIB_DIR = lib

PATH=\masm32

vpath %.asm SRC_DIR
vpath %.inc INC_DIR
vpath %.obj OBJ_DIR

CFLAGS = /c /Cp /I $(PATH)\include64 /I $(INC_DIR) \
/I $(PATH)\macros64
LDFLAGS = 
LDLIBS = /LIBPATH:$(PATH)\lib64

CC=\masm32\bin\ml64.exe
LNK=\masm32\bin\lib.exe

SOURCES = $(wildcard $(SRC_DIR)/*.asm)
OBJECTS = $(subst $(SRC_DIR)/,$(OBJ_DIR)/,$(SOURCES:.asm=.obj))

$(OBJ_DIR)/%.obj: $(SRC_DIR)/%.asm
	$(CC) $(CFLAGS) /Fo $@ $<

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LNK) $(LDFLAGS) /OUT:$@ $(LDLIBS) $^
	move .\$(TARGET) .\$(LIB_DIR)

clean:
	@-del $(OBJ_DIR)\*.obj