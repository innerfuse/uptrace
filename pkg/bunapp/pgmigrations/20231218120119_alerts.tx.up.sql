DROP TABLE IF EXISTS alerts CASCADE;

--bun:split

DROP TABLE IF EXISTS alert_events CASCADE;

--bun:split

CREATE TABLE alerts (
  id int8 PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
  project_id int4 NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
  dedup_hash int8 NOT NULL,

  name varchar(1000) NOT NULL,
  attrs jsonb,
  attrs_hash int8 NOT NULL,
  tsv tsvector,

  monitor_id int8 REFERENCES monitors (id) ON DELETE CASCADE,
  trackable_model trackable_model_enum,
  trackable_id int8,

  type alert_type_enum NOT NULL,
  event_id int8,

  created_at timestamptz NOT NULL DEFAULT now()
);

--bun:split

CREATE INDEX alerts_project_id_tsv_idx ON alerts
USING GIN (project_id, tsv);

--bun:split

CREATE INDEX alerts_monitor_id_idx ON alerts (monitor_id);

--bun:split

CREATE UNIQUE INDEX alerts_project_id_dedup_hash_unq ON alerts (project_id, dedup_hash);

--==============================================================================
--bun:split

DO $$ BEGIN
  CREATE TYPE public.alert_status_enum AS ENUM (
    'open',
    'closed'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

--bun:split

DO $$ BEGIN
  CREATE TYPE public.alert_event_name_enum AS ENUM (
    'created',
    'status-changed',
    'recurring'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

--bun:split

CREATE TABLE alert_events (
  id int8 PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,

  user_id int8 REFERENCES users (id) ON DELETE CASCADE,
  project_id int4 NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
  alert_id int8 NOT NULL REFERENCES alerts (id) ON DELETE CASCADE,

  name alert_event_name_enum NOT NULL,
  status alert_status_enum NOT NULL DEFAULT 'open',
  params jsonb,

  time timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);

--==============================================================================
--bun:split

CREATE TABLE annotations (
  id int8 PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
  project_id int4 NOT NULL,
  hash int8,
  name varchar(500) NOT NULL,
  description varchar(5000) NOT NULL,
  color varchar(100) NOT NULL,
  attrs jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

--bun:split

CREATE UNIQUE INDEX annotations_project_id_hash_idx
ON annotations (project_id, hash);
