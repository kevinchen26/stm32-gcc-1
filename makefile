TARGET=mySTM32GCC-1

TOP=$(shell pwd)

#设定包含文件目录
INC_FLAGS= -I $(TOP)/CORE                  \
           -I $(TOP)/STM32F10x_FWLib/inc   \
           -I $(TOP)/USER

CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy

CPUFLAGS=-mthumb -mcpu=cortex-m3
LDFLAGS = -T stm32_flash.ld -Wl,-cref,-u,Reset_Handler -Wl,-Map=$(TARGET).map -Wl,--gc-sections -Wl,--defsym=malloc_getpagesize_P=0x80 -Wl,--start-group -lc -lm -Wl,--end-group
CFLAGS = -W -Wall -g -D STM32F10X_HD -D USE_STDPERIPH_DRIVER $(INC_FLAGS) -O0 -std=gnu11

C_SRC=$(shell find ./ -name '*.c')  
C_OBJ=$(C_SRC:%.c=%.o) 

$(TARGET):$(C_OBJ)
	$(CC) $(C_OBJ) $(CPUFLAGS) $(LDFLAGS) $(CFLAGS) -o $(TARGET).elf
	$(OBJCOPY) $(TARGET).elf  $(TARGET).bin -Obinary 
	$(OBJCOPY) $(TARGET).elf  $(TARGET).hex -Oihex

startup_stm32f10x_hd.o:startup_stm32f10x_hd.s
	$(CC) -c $^ $(CPUFLAGS) $(CFLAGS) $@
$(C_OBJ):%.o:%.c
	$(CC) -c $(CPUFLAGS) $(CFLAGS) -o $@ $<

clean:
#$(RM) *.o $(TARGET).*
	rm -f $(shell find ./ -name '*.o')
	rm -f $(shell find ./ -name '*.map')
	rm -f $(shell find ./ -name '*.elf')
	rm -f $(shell find ./ -name '*.bin')
	rm -f $(shell find ./ -name '*.hex')
update:
	openocd -f /usr/local/share/openocd/scripts/interface/jlink.cfg  -f /usr/local/share/openocd/scripts/target/stm32f1x.cfg -c init -c halt -c "flash write_image erase $(TOP)/$(TARGET).hex" -c reset -c shutdown