TARGET = main

# Define the linker script location and chip architecture.
LD_SCRIPT = STM32F031K6T6.ld
MCU_SPEC  = cortex-m0

# Toolchain definitions (ARM bare metal defaults)
CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OC = arm-none-eabi-objcopy
OD = arm-none-eabi-objdump
OS = arm-none-eabi-size

SERIAL ?= COM39
# FLASH ?= stm32loader -e -n -p $(SERIAL) -b 57600 -w
FLASH ?= stm32flash -i dtr-dtr -g 0 -w

# common build flags
BFLAGS = -mcpu=$(MCU_SPEC)
BFLAGS += -mthumb
BFLAGS += -Wall

# Assembly directives.
ASFLAGS += -c
ASFLAGS += -O0
ASFLAGS += $(BFLAGS)
# (Set error messages to appear on a single line.)
ASFLAGS += -fmessage-length=0

# C compilation directives
CFLAGS += $(BFLAGS)
CFLAGS += -g
CFLAGS += -Os
# enable for 2-stage pipeline
CFLAGS += -DDELAY_NOP
# (Set error messages to appear on a single line.)
CFLAGS += -fmessage-length=0
# (Set system to ignore semihosted junk)
CFLAGS += --specs=nosys.specs

# Linker directives.
LSCRIPT = ./ld/$(LD_SCRIPT)
LFLAGS += $(BFLAGS)
LFLAGS += --specs=nosys.specs
LFLAGS += -nostdlib
LFLAGS += -lgcc
LFLAGS += -T$(LSCRIPT)

AS_SRC   += ./src/vector_table.S
C_SRC    =  ./src/main.c

INCLUDE  =  -I./
INCLUDE  += -I./device_headers

OBJS  = $(AS_SRC:.S=.o)
OBJS += $(C_SRC:.c=.o)

.PHONY: all
all: $(TARGET).bin

%.o: %.S
	$(CC) -x assembler-with-cpp $(ASFLAGS) $< -o $@

%.o: %.c
	$(CC) -c $(CFLAGS) $(INCLUDE) $< -o $@

$(TARGET).elf: $(OBJS)
	$(CC) $^ $(LFLAGS) -o $@

$(TARGET).bin: $(TARGET).elf
	$(OC) -S -O binary $< $@
	$(OS) $<

flash: $(TARGET).bin
	$(FLASH) $< $(SERIAL)

.PHONY: clean
clean:
	rm -f $(OBJS)
	rm -f $(TARGET).elf
	rm -f $(TARGET).bin
