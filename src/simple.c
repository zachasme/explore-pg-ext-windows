#include "postgres.h"
#include <string.h>
#include "fmgr.h"
#include "utils/geo_decls.h"
#include "h3api.h"

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

PGDLLEXPORT Datum add_one(PG_FUNCTION_ARGS);
PGDLLEXPORT Datum h3_hex_area(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(add_one);
PG_FUNCTION_INFO_V1(h3_hex_area);

Datum
add_one(PG_FUNCTION_ARGS)
{
    int32   arg = PG_GETARG_INT32(0);

    PG_RETURN_INT32(arg + 1);
}

/* Average hexagon area in square (kilo)meters at the given resolution */
Datum
h3_hex_area(PG_FUNCTION_ARGS)
{
	int			resolution = PG_GETARG_INT32(0);
	int			km = PG_GETARG_BOOL(1);
	double		area;

	if (km)
		area = hexAreaKm2(resolution);
	else
		area = hexAreaM2(resolution);

	PG_RETURN_FLOAT8(area);
}
