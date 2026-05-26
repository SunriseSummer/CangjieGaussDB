-- Table: public.change_logs

-- DROP TABLE IF EXISTS public.change_logs;

CREATE TABLE IF NOT EXISTS public.change_logs
(
    id text COLLATE pg_catalog."default" NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    action text COLLATE pg_catalog."default",
    object_id text COLLATE pg_catalog."default",
    object_type text COLLATE pg_catalog."default",
    raw_object json,
    raw_meta json,
    raw_diff json,
    created_by text COLLATE pg_catalog."default",
    CONSTRAINT change_logs_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.change_logs
    OWNER to gorm;
-- Index: idx_change_logs_created_by

-- DROP INDEX IF EXISTS public.idx_change_logs_created_by;

CREATE INDEX IF NOT EXISTS idx_change_logs_created_by
    ON public.change_logs USING btree
    (created_by COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_change_logs_object_id

-- DROP INDEX IF EXISTS public.idx_change_logs_object_id;

CREATE INDEX IF NOT EXISTS idx_change_logs_object_id
    ON public.change_logs USING btree
    (object_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_change_logs_object_type

-- DROP INDEX IF EXISTS public.idx_change_logs_object_type;

CREATE INDEX IF NOT EXISTS idx_change_logs_object_type
    ON public.change_logs USING btree
    (object_type COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;