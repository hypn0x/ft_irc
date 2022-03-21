CFLAGS := -Wall -Wextra -Werror -g3
CC = g++
MAKEFLAGS += --no-print-directory

#UNAME = $(shell uname -s)

#directories
SRC_DIR ?= ./src
TESTS_DIR ?= ./tests
LIBS_DIR ?= ./libs
BIN_DIR ?= ./bin
INC_DIR := ./include
BUILD_DIR ?= ./build

NAME = ft_irc

SRCS = $(shell find $(SRC_DIR) -name *.cpp)
OBJS = $(SRCS:%=$(BUILD_DIR)/%.o)

LIBS = $(shell $(MAKE) --no-print-directory -C $(LIBS_DIR) lib_names)
LIB_FILES = $(addprefix $(LIBS_DIR)/,$(shell $(MAKE) --no-print-directory -C $(LIBS_DIR) lib_path))
LIBS_INC = $(addprefix $(LIBS_DIR)/,$(shell $(MAKE) --no-print-directory -C $(LIBS_DIR) lib_inc))

TEST_FLAGS = $(addprefix -I../,$(LIBS_INC)) -I../$(INC_DIR) $(addprefix -L../,$(LIBS)) $(addprefix -l,$(LIBS))

$(BUILD_DIR)/%.cpp.o : %.cpp
	@printf "[`tput setaf 3`make`tput sgr0`] compiling $@...\n"
	@mkdir -p $(dir $@)
	@$(CC) -c $(CFLAGS) $(addprefix -I,$(LIBS_INC)) -I$(INC_DIR) $< -o $@

$(NAME):	library
	@printf "[`tput setaf 3`make`tput sgr0`] checking update status...\n"
	@if ! $(MAKE) $(BIN_DIR)/$(NAME) | grep -v "is up to date" ; then \
		printf "[`tput setaf 3`make`tput sgr0`] $@ is up to date ✅\n"; \
	fi

$(BIN_DIR)/$(NAME):	$(OBJS) $(LIB_FILES)
	@printf "[`tput setaf 3`make`tput sgr0`] linking $@\n"
	@$(CC) $(CFLAGS) $(OBJS) $(addprefix -L$(LIBS_DIR)/,$(LIBS)) $(addprefix -l,$(LIBS)) -o $(BIN_DIR)/$(NAME)

release: CFLAGS += -03 -march=native
release: fclean
release: all

tests:
	@printf "[`tput setaf 3`make`tput sgr0`] starting tests...\n"
	@$(MAKE) -e TEST_FLAGS="$(TEST_FLAGS)" -C $(TESTS_DIR)

$(LIB_FILES): library

run:
	@$(MAKE) $(BIN_DIR)/$(NAME) | grep -v "is up to date" || true
	@printf "[`tput setaf 3`make`tput sgr0`] running $(NAME)\n"
	@$(BIN_DIR)/$(NAME)


library:
	@$(MAKE) -e CFLAGS="$(CFLAGS)" -C $(LIBS_DIR)

all:	
	@$(MAKE) $(NAME)
	@$(MAKE) tests
	@$(MAKE) run

clean:
	@rm -rf $(BUILD_DIR)
	@$(MAKE) -C $(LIBS_DIR) fclean
	@printf "[`tput setaf 3`make`tput sgr0`] clean done\n"

fclean:
	@rm -rf $(BUILD_DIR)
	@rm -rf $(BIN_DIR)/$(NAME)
	@$(MAKE) -C $(LIBS_DIR) fclean
	@printf "[`tput setaf 3`make`tput sgr0`] fclean done\n"

re: fclean
re:	all

.PHONY: all fclean clean library re release tests run
