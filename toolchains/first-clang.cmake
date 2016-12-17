# author: maxint <NOT_SPAM_lnychina@gmail.com>
# Find the first clang in PATH

# basic setup
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR X86) # optional

# compilers
find_program(CMAKE_C_COMPILER clang)
find_program(CMAKE_CXX_COMPILER clang++)

