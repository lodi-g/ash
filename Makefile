SRCDIR		:=	srcs
OBJDIR		:=	objs
INCDIR		:=
OUTDIR		:=	.

AS				:=	nasm
ASFLAGS		:=	-g -f elf64

RM				:=	@rm -v -f

LD				:=	gcc
INCFLAGS	:=	$(addprefix -I, $(INCDIR))
LDLIBS		:=
LDLIBS		:=	$(addprefix -l, $(LDLIBS))
LDFLAGS		:=	$(INCFLAGS)

NAME			:=	$(OUTDIR)/ash

SRCS			:=	main.s exec.s
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
