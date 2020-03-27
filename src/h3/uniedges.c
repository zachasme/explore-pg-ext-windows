/*
 * Copyright 2018-2019 Bytes & Brains
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *	   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <postgres.h>			 // Datum, etc.
#include <fmgr.h>				 // PG_FUNCTION_ARGS, etc.
#include <funcapi.h>			 // Needed to return HeapTuple
#include <access/htup_details.h> //Needed to return HeapTuple
#include <utils/geo_decls.h>	 // making native points

#include <h3api.h> // Main H3 include
#include "extension.h"

PG_FUNCTION_INFO_V1(h3_indexes_are_neighbors);
PG_FUNCTION_INFO_V1(h3_get_h3_unidirectional_edge);
PG_FUNCTION_INFO_V1(h3_unidirectional_edge_is_valid);
PG_FUNCTION_INFO_V1(h3_get_origin_h3_index_from_unidirectional_edge);
PG_FUNCTION_INFO_V1(h3_get_destination_h3_index_from_unidirectional_edge);
PG_FUNCTION_INFO_V1(h3_get_h3_indexes_from_unidirectional_edge);
PG_FUNCTION_INFO_V1(h3_get_h3_unidirectional_edges_from_hexagon);
PG_FUNCTION_INFO_V1(h3_get_h3_unidirectional_edge_boundary);

/* Returns whether or not the provided H3Indexes are neighbors */
Datum
h3_indexes_are_neighbors(PG_FUNCTION_ARGS)
{
	H3Index    *origin = PG_GETARG_H3_INDEX_P(0);
	H3Index    *destination = PG_GETARG_H3_INDEX_P(1);
	bool		areNeighbors = h3IndexesAreNeighbors(*origin, *destination);

	PG_RETURN_BOOL(areNeighbors);
}

/*
 * Returns a unidirectional edge H3 index based on the provided origin and
 * destination
 */
Datum
h3_get_h3_unidirectional_edge(PG_FUNCTION_ARGS)
{
	H3Index    *origin = PG_GETARG_H3_INDEX_P(0);
	H3Index    *destination = PG_GETARG_H3_INDEX_P(1);
	H3Index    *edge = palloc(sizeof(H3Index));

	*edge = getH3UnidirectionalEdge(*origin, *destination);
	ASSERT_EXTERNAL(*edge, "Can only create edges between neighbouring indexes");

	PG_RETURN_H3_INDEX_P(edge);
}

/* Determines if the provided H3Index is a valid unidirectional edge index */
Datum
h3_unidirectional_edge_is_valid(PG_FUNCTION_ARGS)
{
	H3Index    *edge = PG_GETARG_H3_INDEX_P(0);
	bool		isValid = h3UnidirectionalEdgeIsValid(*edge);

	PG_RETURN_BOOL(isValid);
}

/* Returns the origin hexagon from the unidirectional edge H3Index */
Datum
h3_get_origin_h3_index_from_unidirectional_edge(PG_FUNCTION_ARGS)
{
	H3Index    *edge = PG_GETARG_H3_INDEX_P(0);
	H3Index    *origin = palloc(sizeof(H3Index));

	*origin = getOriginH3IndexFromUnidirectionalEdge(*edge);

	PG_RETURN_H3_INDEX_P(origin);
}

/* Returns the destination hexagon from the unidirectional edge H3Index */
Datum
h3_get_destination_h3_index_from_unidirectional_edge(PG_FUNCTION_ARGS)
{
	H3Index    *edge = PG_GETARG_H3_INDEX_P(0);
	H3Index    *destination = palloc(sizeof(H3Index));

	*destination = getDestinationH3IndexFromUnidirectionalEdge(*edge);
	PG_RETURN_H3_INDEX_P(destination);
}

/* Returns the origin, destination pair of hexagon IDs for the given edge ID */
Datum
h3_get_h3_indexes_from_unidirectional_edge(PG_FUNCTION_ARGS)
{
	TupleDesc	tuple_desc;
	Datum		values[2];
	bool		nulls[2] = {false};
	HeapTuple	tuple;
	Datum		result;

	H3Index    *edge = PG_GETARG_H3_INDEX_P(0);
	H3Index    *indexes = palloc(sizeof(H3Index) * 2);

	getH3IndexesFromUnidirectionalEdge(*edge, indexes);

	ENSURE_TYPEFUNC_COMPOSITE(get_call_result_type(fcinfo, NULL, &tuple_desc));
	tuple_desc = BlessTupleDesc(tuple_desc);

	values[0] = PointerGetDatum(indexes);
	indexes++;
	/* increment pointer to next index */
	values[1] = PointerGetDatum(indexes);

	tuple = heap_form_tuple(tuple_desc, values, nulls);
	result = HeapTupleGetDatum(tuple);
	PG_RETURN_DATUM(result);
}

/* Provides all of the unidirectional edges from the current H3Index */
Datum
h3_get_h3_unidirectional_edges_from_hexagon(PG_FUNCTION_ARGS)
{
	if (SRF_IS_FIRSTCALL())
	{
		FuncCallContext *funcctx = SRF_FIRSTCALL_INIT();
		MemoryContext oldcontext =
		MemoryContextSwitchTo(funcctx->multi_call_memory_ctx);

		H3Index    *origin = PG_GETARG_H3_INDEX_P(0);
		int			maxSize = 6;
		H3Index    *edges = palloc(sizeof(H3Index) * maxSize);

		getH3UnidirectionalEdgesFromHexagon(*origin, edges);

		funcctx->user_fctx = edges;
		funcctx->max_calls = maxSize;
		MemoryContextSwitchTo(oldcontext);
	}

	SRF_RETURN_H3_INDEXES_FROM_USER_FCTX();
}

/* Provides the coordinates defining the unidirectional edge */
Datum
h3_get_h3_unidirectional_edge_boundary(PG_FUNCTION_ARGS)
{
	H3Index    *edge = PG_GETARG_H3_INDEX_P(0);

	GeoBoundary geoBoundary;
	POLYGON    *polygon;
	int			size;

	getH3UnidirectionalEdgeBoundary(*edge, &geoBoundary);

	size = offsetof(POLYGON, p[0]) +sizeof(polygon->p[0]) * geoBoundary.numVerts;
	polygon = (POLYGON *) palloc(size);
	SET_VARSIZE(polygon, size);
	polygon->npts = geoBoundary.numVerts;

	for (int v = 0; v < geoBoundary.numVerts; v++)
	{
		polygon->p[v].x = radsToDegs(geoBoundary.verts[v].lat);
		polygon->p[v].y = radsToDegs(geoBoundary.verts[v].lon);
	}

	PG_RETURN_POLYGON_P(polygon);
}
