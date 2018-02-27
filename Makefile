SRCDIR		:=	srcs
OBJDIR		:=	objs
INCDIR		:=	incs
OUTDIR		:=	.

AS		:=	nasm
INCFLAGS	:=	$(addprefix -I, $(addsuffix /, $(INCDIR)))
ASFLAGS		:=	-g -F dwarf -f elf64 $(INCFLAGS)

RM				:=	@rm -v -f

LD		:=	ld
LDLIBS		:=	readline c
LDLIBS		:=	$(addprefix -l, $(LDLIBS))
LDFLAGS		:=	$(INCFLAGS) -e main -I/lib/ld-linux-x86-64.so.2 

NAME			:=	$(OUTDIR)/ash

SRCS			:=	builtins.s main.s exec.s prompt.s
OBJS			:=	$(addprefix $(OBJDIR)/, $(SRCS))
SRCS			:=	$(addprefix $(SRCDIR)/, $(SRCS))
OBJS			:=	$(patsubst %.s, %.o, $(OBJS))


all:	$(NAME)

$(NAME):	| $(OBJDIR) $(OBJS)
	@$(LD) -o $@ $(OBJS) $(LDFLAGS) $(LDLIBS)
	@echo "linked '$@'"

$(OBJDIR):
	@mkdir objs

$(OBJDIR)/%.o::	$(SRCDIR)/%.s
	@$(AS) $(ASFLAGS) $< -o $@
	@echo "compiled '$@'"

clean:; $(RM) $(OBJS)

fclean: clean
	$(RM) $(NAME)

re: fclean all

.PHONY: all clean fclean re

get-%:;	$($*)
