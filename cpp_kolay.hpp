#ifndef CPP_KOLAY_HPP
#define CPP_KOLAY_HPP
#include <iostream>

// types
typedef int8_t i8;
typedef uint8_t u8;

typedef int16_t i16;
typedef uint16_t u16;

typedef int32_t i32;
typedef uint32_t u32;

typedef int64_t i64;
typedef uint64_t u64;

typedef float f32;
typedef double f64;

typedef char* c_string;

// custom syntax
#define returns(x) {return x;}
#define sswitch(str) switch(string_switch(str))

#define var auto

//debugging
#ifdef DEBUG
#define DEBYELLOW "\e[1;33m"
#define DEBRED "\e[1;31m"
#define DEBCRESET "\e[0m"
#define __DEBUG_COUT std::cout << DEBYELLOW "[DEBUG " __FILE__ ":" << __LINE__ << " " << __FUNCTION__ << "()]: " DEBCRESET 
#define DPRINT(var) __DEBUG_COUT << #var " = " << var << "\n";
#define DTEXT(text) __DEBUG_COUT << text << std::endl;

#define unimplemented() __DEBUG_COUT << __FUNCTION__ << "() is unimplemented\n";
#define unimplemented_exit() {unimplemented(); exit(1);}

#define nul_guard(ptr) if(!ptr) {\
	__DEBUG_COUT DEBRED "\"" #ptr "\"" DEBCRESET " is a null pointer. quitting.\n" ;\
	exit(1);\
}

#else
#define unimplemented() std::cout << "unimplemented\n";
#define unimplemented_exit() {unimplemented(); exit(1);}
#define DPRINT(var)
#define DTEXT(var)
#define nul_guard(ptr) if(!ptr) {\
	std::cout << "Null pointer error. quitting.\n";\
	exit(1);\
}
#endif // DEBUG

// strings in switch
// based on https://gist.github.com/hare1039/581b20cc8fbc8058d875894f05e655e5
static constexpr inline u64 kinternal_hash(const char* str, int h = 0)
	returns (!str[h] ? 5381 : (kinternal_hash(str, h+1)*33) ^ str[h]);

#if __has_include(<string_view>) && __cplusplus >= 201703L
#include <string_view>
inline u64 string_switch(std::string_view s)
	returns (kinternal_hash(s.data()))
#else
inline u64 string_switch(const std::string& s)
	returns (kinternal_hash(s.c_str()))
#endif

constexpr inline u64 string_switch(const char* s)
	returns (kinternal_hash(s))

constexpr inline u64 operator "" _(const char* p, size_t)
	returns (kinternal_hash(p))

//memory
#define free(ptr) free(ptr); ptr = NULL

#define kdelete(ptr) {delete ptr; ptr = NULL;}
#define kdelete_array(ptr) {delete[] ptr; ptr = NULL;}

//args parsing
inline c_string shift_arg(i32 &argc, c_string const* &argv) {
	argc--; *argv++;
	
	if (argc <= 0 || argv[0] == NULL)
		return "";

	return argv[0];
}

#define shift_args() shift_arg(argc, argv)
#define error_if_null(x, message) if(!x) {\
	std::cerr << "[ERROR]: " message "\n";\
	exit(1);\
}

#define forever for(;;)

//more fun than std
template<typename...A>
constexpr inline void print(A&&...args)
{
	(std::cout << ... << args);
}
template<typename...A>
constexpr inline void print_error(A&&...args)
{
	(std::cerr << ... << args);
}

#endif //CPP_KOLAY_HPP
