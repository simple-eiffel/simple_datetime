/*
 * simple_datetime_clock.h - monotonic clock for SIMPLE_MONOTONIC_CLOCK.
 *
 *   sdc_counter    current tick count
 *   sdc_frequency  ticks per second
 *
 * Windows uses QueryPerformanceCounter. POSIX uses clock_gettime with
 * CLOCK_MONOTONIC, whose ticks are nanoseconds.
 */
#ifndef SIMPLE_DATETIME_CLOCK_H
#define SIMPLE_DATETIME_CLOCK_H

#if defined(_WIN32) || defined(EIF_WINDOWS)

#include <windows.h>

static long long sdc_counter (void)
{
	LARGE_INTEGER li;
	QueryPerformanceCounter (&li);
	return (long long) li.QuadPart;
}

static long long sdc_frequency (void)
{
	LARGE_INTEGER li;
	QueryPerformanceFrequency (&li);
	return (long long) li.QuadPart;
}

#else /* POSIX */

#include <time.h>

static long long sdc_counter (void)
{
	struct timespec ts;
	clock_gettime (CLOCK_MONOTONIC, &ts);
	return (long long) ts.tv_sec * 1000000000LL + (long long) ts.tv_nsec;
}

static long long sdc_frequency (void)
{
	return 1000000000LL;
}

#endif

#endif /* SIMPLE_DATETIME_CLOCK_H */
