-- Table: public.some_types

-- DROP TABLE IF EXISTS public.some_types;

CREATE TABLE IF NOT EXISTS public.some_types
(
    id serial NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    source text COLLATE pg_catalog."default",
    CONSTRAINT some_types_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.some_types
    OWNER to gorm;
-- Index: idx_some_types_deleted_at

-- DROP INDEX IF EXISTS public.idx_some_types_deleted_at;

CREATE INDEX IF NOT EXISTS idx_some_types_deleted_at
    ON public.some_types USING btree
    (deleted_at ASC NULLS LAST)
    TABLESPACE pg_default;