typedef __SIZE_TYPE__ size_t;
typedef volatile char jmp_buf[8];

int ft_strcmp(const char *a, const char *b)
{
	for (;;) {
		if (*a != *b) {
			return *a - *b;
		}
		if (*a == 0) {
			return 0;
		}
		a++;
		b++;
	}
}

int ft_strncmp(const char *a, const char *b, size_t n)
{
	for (size_t i = 0; i < n; i++) {
		if (a[i] != b[i]) {
			return a[i] - b[i];
		}
		if (a[i] == 0) {
			return 0;
		}
	}
	return 0;
}

void *ft_memcpy(void *dest, const void *src, size_t n)
{
	for (size_t i = 0; i < n; i++) {
		((char *)dest)[i] = ((char *)src)[i];
	}
	return dest;
}

void *ft_memset(void *s, int c, size_t n)
{
	for (size_t i = 0; i < n; i++) {
		((char *)s)[i] = c;
	}
	return s;
}

const char *ft_strstr(const char *haystack, const char *needle)
{
	for (;;) {
		for (size_t n = 0; needle[n] != 0; n++) {
			if (haystack[n] == 0) {
				return (char *)0;
			}
			if (haystack[n] != needle[n]) {
				goto no;
			}
		}
		return haystack;
no:
		haystack++;
	}
	return (char *)0;
}

size_t ft_strlen(const char *s)
{
	size_t len = 0;
	while (s[len] != 0) {
		len++;
	}
	return len;
}

void *ft_memmove(void *dest, const void *src, size_t n)
{
	return ft_memcpy(dest, src, n);
}

void ft_qsort(void *base, size_t n, size_t size, int (*cmp)(const void *, const void *)) {
	// ¯\_(ツ)_/¯
}

void *ft_smalloc(size_t);

void ft_sfree(void *ptr)
{
	// ¯\_(ツ)_/¯
}

void *ft_srealloc(void *ptr, size_t size)
{
	void *new = ft_smalloc(size);
	if (new) {
		ft_memcpy(new, ptr, size);
	}
	ft_sfree(ptr);
	return new;
}

int ft_setjmp(jmp_buf foo)
{
	// ¯\_(ツ)_/¯
	return 0;
}

void ft_longjmp(jmp_buf foo, int bar)
{
	// ¯\_(ツ)_/¯
}

void __chkstk() {
	// ¯\_(ツ)_/¯
}

#define FTSTDLIB_H_
#define ft_ptrdiff_t __PTRDIFF_TYPE__
#define ft_jmp_buf jmp_buf
#define FT_CHAR_BIT __CHAR_BIT__
#define FT_INT_MAX __INT_MAX__
#define FT_INT_MIN (~__INT_MAX__)
#define FT_UINT_MAX ((__INT_MAX__<<1)+1)
#define FT_LONG_MAX __LONG_MAX__
#define FT_ULONG_MAX ((__LONG_MAX__<<1)+1)
#define SHRT_MAX __SHRT_MAX__



#ifdef FT2_BUILD_LIBRARY

#undef _MSC_VER

#define FTOPTION_H_
#define FT_MAX_MODULES 32
#define T1_MAX_SUBRS_CALLS 16
#define T1_MAX_CHARSTRINGS_OPERANDS 256
#define FT_CONFIG_OPTION_DISABLE_STREAM_SUPPORT
#define TT_CONFIG_CMAP_FORMAT_0
#define TT_CONFIG_CMAP_FORMAT_2
#define TT_CONFIG_CMAP_FORMAT_4
#define TT_CONFIG_CMAP_FORMAT_6
#define TT_CONFIG_CMAP_FORMAT_8
#define TT_CONFIG_CMAP_FORMAT_10
#define TT_CONFIG_CMAP_FORMAT_12
#define TT_CONFIG_CMAP_FORMAT_13
#define TT_CONFIG_CMAP_FORMAT_14

#define FT_CONFIG_MODULES_H <modules.h>

#endif /* FT2_BUILD_LIBRARY */

#include <ft2build.h>
#include <freetype/freetype.h>

#ifdef FT2_BUILD_LIBRARY
#include <base/ftbase.c>
#include <base/ftinit.c>
#include <base/ftsystem.c>
#include <truetype/ttgload.c>
#include <truetype/ttpload.c>
#include <truetype/ttdriver.h>
#include <truetype/ttdriver.c>
#include <truetype/ttobjs.c>
#include <psnames/psmodule.c>
#include <sfnt/ttpost.c>
#include <sfnt/sfdriver.c>
#include <sfnt/ttload.c>
#include <sfnt/sfobjs.c>
#include <sfnt/ttkern.c>
#include <sfnt/ttcmap.c>
#include <sfnt/ttmtx.c>
#include <sfnt/sfwoff.c>
#include <sfnt/sfwoff2.c>
#include <sfnt/woff2tags.c>
#include <raster/ftrend1.c>
#include <raster/ftraster.c>

#endif /* FT2_BUILD_LIBRARY */
