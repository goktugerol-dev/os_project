# ORGANIZING ALL THE BUILD COMMANDS
# AND MAKING SURE THAT ONLY THE FILES THAT HAVE BEEN MODIFIED GET REBUILD


# CREATING A VARIABLE TO HOLD X86_64 ASSEMBLY SOURCE FILES

x86_64_asm_source_files := $(shell find src/impl/x86_64 -name *.asm) # TO FIND ALL FILE NAMES ENDING WITH .asm

# WHEN COMPILING THE CODE, IT WILL BE COMPILING EACH INDIVIDUAL 
# ASSEMBLY SOURCE FILE TO AN OBJECT FILE

# CREATING A LIST OF ALL THE OBJECT FILES

x86_64_asm_object_files := $(patsubst src/impl/x86_64/%.asm, build/x86_64/%.o, $(x86_64_asm_source_files))

# DEFINE THE COMMANDS IT NEEDS TO RUN TO BUILD ONE OF THE OBJECT FILES FROM THE SOURCE FILES
# ONLY RECOMPILE WHEN THE SOURCE FILES HAVE CHANGED. SO, REVERSING THE PATH SUBSTITUON

$(x86_64_asm_object_files): build/x86_64/%.o : src/impl/x86_64/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst build/x86_64/%.o, src/impl/x86_64/%.asm, $@) -o $@

# 20- DEFINE COMMANDS THAT NEEDS TO BE BUILT THE OBJECT FILES
# 20- CHECKING THE EXISTENCE OF THE DIRECTORY TO HOLD THE COMPILED FILE
# 21- USING NASM TO COMPILE THE ASSEMBLY CODE. 
# 21 -USING F FLAG TO CHANGE THE FORMAT OF THE OBJECT FILE

.PHONY: build-x86_64
build-x86_64: $(x86_64_asm_object_files) # IT WILL ONLY RUN IF ANY OF THE OBJECT FILES CHANGED
	mkdir -p dist/x86_64 && \
	x86_64-elf-ld -n -o dist/x86_64/kernel.bin -T targets/x86_64/linker.ld $(x86_64_asm_object_files) && \
	cp dist/x86_64/kernel.bin targets/x86_64/iso/boot/kernel.bin && \
	grub-mkrescue /usr/lib/grub/i386-pc -o dist/x86_64/kernel.iso targets/x86_64/iso