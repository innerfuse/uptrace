CREATE OR REPLACE FUNCTION public.array_intersect (anycompatiblearray, anycompatiblearray)
  RETURNS anycompatiblearray
  LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
as $FUNCTION$
  SELECT ARRAY(
    SELECT UNNEST($1)
    INTERSECT
    SELECT UNNEST($2)
  );
$FUNCTION$;

CREATE OR REPLACE AGGREGATE public.array_intersect_agg (anycompatiblearray) (
  SFUNC = array_intersect,
  STYPE = anycompatiblearray,
  PARALLEL = safe
);

--bun:split

ALTER TABLE users DROP COLUMN password;

--bun:split

CREATE TABLE grid_rows (
  id int8 PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,

  dash_id int8 NOT NULL REFERENCES dashboards (id) ON DELETE CASCADE,

  title varchar(1000) NOT NULL,
  description varchar(1000),
  expanded boolean DEFAULT FALSE,
  index int4 NOT NULL,

  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL
);

--bun:split

CREATE INDEX grid_rows_dash_id_idx
ON grid_rows (dash_id);

--bun:split

DO $$ BEGIN
  CREATE TYPE public.grid_item_type_enum AS ENUM (
    'chart',
    'table',
    'heatmap',
    'gauge'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

--bun:split

CREATE TABLE grid_items (
  id int8 PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,

  dash_id int8 NOT NULL REFERENCES dashboards (id) ON DELETE CASCADE,
  dash_kind dash_kind_enum NOT NULL,
  row_id bigint REFERENCES grid_rows (id) ON DELETE CASCADE,

  title varchar(1000) NOT NULL,
  description varchar(1000),

  width int4,
  height int4,
  x_axis int4,
  y_axis int4,

  type grid_item_type_enum NOT NULL,
  params jsonb NOT NULL,

  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL
);

--bun:split

CREATE INDEX grid_items_dash_id_idx
ON grid_items (dash_id);

--bun:split

alter table dashboards
add column min_interval float8 NOT NULL DEFAULT 0;

--bun:split

alter table dashboards
add column time_offset float8 NOT NULL DEFAULT 0;

--bun:split

alter table dashboards
add column grid_max_width int4 default 1416;
