SRCDIR		:=	srcs
OBJDIR		:=	objs
INCDIR		:=	incs
OUTDIR		:=	.

AS				:=	nasm
INCFLAGS	:=	$(addprefix -I, $(addsuffix /, $(INCDIR)))
ASFLAGS		:=	-g -f elf64 $(INCFLAGS)

RM				:=	@rm -v -f

LD				:=	gcc
LDLIBS		:=	readline
LDLIBS		:=	$(addprefix -l, $(LDLIBS))
LDFLAGS		:=	$(INCFLAGS)

NAME			:=	$(OUTDIR)/ash

SRCS			:=	main.s exec.s parser.s prompt.s
OBJS			:=	$(addprefix $(OBJDIR)/, $(SRCS))
SRCS			:=	$(addprefix $(SRCDIR)/, $(SRCS))
OBJS			:=	$(patsubst %.s, %.o, $(OBJS))


all:	$(NAME)

$(NAME):	$(OBJS)
	@$(LD) -o $@ $^ $(LDFLAGS) $(LDLIBS)
	@echo "linked '$@'"

$(OBJDIR)/%.o::	$(SRCDIR)/%.s
	@$(AS) $(ASFLAGS) $< -o $@
	@echo "compiled '$@'"

clean:; $(RM) $(OBJS)

fclean: clean
	$(RM) $(NAME)

re: fclean all

.PHONY: all clean fclean re

get-%:;	$($*)
