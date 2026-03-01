--
-- PostgreSQL database dump
--

\restrict G4XkiELV25IX0Daoq6WeDXFscjgp7Ef84SQhwHNgJunNahbnQ3RQlAHpCcf2fZP

-- Dumped from database version 17.7 (Ubuntu 17.7-0ubuntu0.25.04.1)
-- Dumped by pg_dump version 17.7 (Ubuntu 17.7-0ubuntu0.25.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: oban_job_state; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.oban_job_state AS ENUM (
    'available',
    'scheduled',
    'executing',
    'retryable',
    'completed',
    'discarded',
    'cancelled'
);


ALTER TYPE public.oban_job_state OWNER TO postgres;

--
-- Name: oban_count_estimate(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.oban_count_estimate(state text, queue text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
  plan jsonb;
BEGIN
  EXECUTE 'EXPLAIN (FORMAT JSON)
           SELECT id
           FROM public.oban_jobs
           WHERE state = $1::public.oban_job_state
           AND queue = $2'
    INTO plan
    USING state, queue;
  RETURN plan->0->'Plan'->'Plan Rows';
END;
$_$;


ALTER FUNCTION public.oban_count_estimate(state text, queue text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: finals_ticket_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.finals_ticket_types (
    id bigint NOT NULL,
    name character varying(255),
    price integer,
    is_active boolean DEFAULT false NOT NULL,
    admits integer,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    description text
);


ALTER TABLE public.finals_ticket_types OWNER TO postgres;

--
-- Name: finals_ticket_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.finals_ticket_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.finals_ticket_types_id_seq OWNER TO postgres;

--
-- Name: finals_ticket_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.finals_ticket_types_id_seq OWNED BY public.finals_ticket_types.id;


--
-- Name: finals_tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.finals_tickets (
    id bigint NOT NULL,
    name character varying(255),
    phone_number character varying(255),
    email character varying(255),
    total_price integer,
    is_complimentary boolean DEFAULT false NOT NULL,
    is_fully_paid boolean DEFAULT false NOT NULL,
    quantity integer,
    ticketid character varying(255),
    transaction_id character varying(255),
    finals_ticket_type_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    is_scanned boolean DEFAULT false
);


ALTER TABLE public.finals_tickets OWNER TO postgres;

--
-- Name: finals_tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.finals_tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.finals_tickets_id_seq OWNER TO postgres;

--
-- Name: finals_tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.finals_tickets_id_seq OWNED BY public.finals_tickets.id;


--
-- Name: oban_jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oban_jobs (
    id bigint NOT NULL,
    state public.oban_job_state DEFAULT 'available'::public.oban_job_state NOT NULL,
    queue text DEFAULT 'default'::text NOT NULL,
    worker text NOT NULL,
    args jsonb DEFAULT '{}'::jsonb NOT NULL,
    errors jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    attempt integer DEFAULT 0 NOT NULL,
    max_attempts integer DEFAULT 20 NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    scheduled_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    attempted_at timestamp without time zone,
    completed_at timestamp without time zone,
    attempted_by text[],
    discarded_at timestamp without time zone,
    priority integer DEFAULT 0 NOT NULL,
    tags text[] DEFAULT ARRAY[]::text[],
    meta jsonb DEFAULT '{}'::jsonb,
    cancelled_at timestamp without time zone,
    CONSTRAINT attempt_range CHECK (((attempt >= 0) AND (attempt <= max_attempts))),
    CONSTRAINT positive_max_attempts CHECK ((max_attempts > 0)),
    CONSTRAINT queue_length CHECK (((char_length(queue) > 0) AND (char_length(queue) < 128))),
    CONSTRAINT worker_length CHECK (((char_length(worker) > 0) AND (char_length(worker) < 128)))
);


ALTER TABLE public.oban_jobs OWNER TO postgres;

--
-- Name: TABLE oban_jobs; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.oban_jobs IS '12';


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oban_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.oban_jobs_id_seq OWNER TO postgres;

--
-- Name: oban_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oban_jobs_id_seq OWNED BY public.oban_jobs.id;


--
-- Name: oban_peers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE UNLOGGED TABLE public.oban_peers (
    name text NOT NULL,
    node text NOT NULL,
    started_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


ALTER TABLE public.oban_peers OWNER TO postgres;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: ticket_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ticket_types (
    id bigint NOT NULL,
    name character varying(255),
    description text,
    price integer,
    is_active boolean DEFAULT false NOT NULL,
    pass_type character varying(255),
    admits integer,
    is_complimentary boolean DEFAULT false NOT NULL,
    user_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    max_scans integer DEFAULT 1,
    is_for_prompt_only boolean DEFAULT false NOT NULL
);


ALTER TABLE public.ticket_types OWNER TO postgres;

--
-- Name: ticket_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ticket_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ticket_types_id_seq OWNER TO postgres;

--
-- Name: ticket_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ticket_types_id_seq OWNED BY public.ticket_types.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tickets (
    id bigint NOT NULL,
    name character varying(255),
    phone_number character varying(255),
    email character varying(255),
    total_price integer,
    is_complimentary boolean DEFAULT false NOT NULL,
    is_fully_paid boolean DEFAULT false NOT NULL,
    quantity integer,
    ticketid character varying(255),
    transaction_id character varying(255),
    ticket_type_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    purchased_on_site boolean DEFAULT false,
    is_scanned boolean DEFAULT false,
    scan_count integer DEFAULT 0,
    max_scans integer DEFAULT 1,
    is_sent boolean DEFAULT true,
    prompted_by_id bigint
);


ALTER TABLE public.tickets OWNER TO postgres;

--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tickets_id_seq OWNER TO postgres;

--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tickets_id_seq OWNED BY public.tickets.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email public.citext NOT NULL,
    hashed_password character varying(255) NOT NULL,
    confirmed_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    name character varying(255),
    is_active boolean DEFAULT false,
    is_admin boolean DEFAULT true NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token bytea NOT NULL,
    context character varying(255) NOT NULL,
    sent_to character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.users_tokens OWNER TO postgres;

--
-- Name: users_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_tokens_id_seq OWNER TO postgres;

--
-- Name: users_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_tokens_id_seq OWNED BY public.users_tokens.id;


--
-- Name: finals_ticket_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finals_ticket_types ALTER COLUMN id SET DEFAULT nextval('public.finals_ticket_types_id_seq'::regclass);


--
-- Name: finals_tickets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finals_tickets ALTER COLUMN id SET DEFAULT nextval('public.finals_tickets_id_seq'::regclass);


--
-- Name: oban_jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oban_jobs ALTER COLUMN id SET DEFAULT nextval('public.oban_jobs_id_seq'::regclass);


--
-- Name: ticket_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket_types ALTER COLUMN id SET DEFAULT nextval('public.ticket_types_id_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets ALTER COLUMN id SET DEFAULT nextval('public.tickets_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_tokens ALTER COLUMN id SET DEFAULT nextval('public.users_tokens_id_seq'::regclass);


--
-- Data for Name: finals_ticket_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.finals_ticket_types (id, name, price, is_active, admits, inserted_at, updated_at, description) FROM stdin;
\.


--
-- Data for Name: finals_tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.finals_tickets (id, name, phone_number, email, total_price, is_complimentary, is_fully_paid, quantity, ticketid, transaction_id, finals_ticket_type_id, inserted_at, updated_at, is_scanned) FROM stdin;
\.


--
-- Data for Name: oban_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oban_jobs (id, state, queue, worker, args, errors, attempt, max_attempts, inserted_at, scheduled_at, attempted_at, completed_at, attempted_by, discarded_at, priority, tags, meta, cancelled_at) FROM stdin;
1	completed	tickets	Kabeberi.TicketWorker	{"reference": "20250929060043_1"}	{}	1	20	2025-09-29 06:01:00.59373	2025-09-29 06:01:00.59373	2025-09-29 06:01:00.602898	2025-09-29 06:01:00.630176	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
2	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 1}	{}	1	5	2025-09-29 06:01:00.619088	2025-09-29 06:01:00.619088	2025-09-29 06:01:00.629537	2025-09-29 06:01:10.04691	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
3	completed	tickets	Kabeberi.TicketWorker	{"reference": "20250929060403_1"}	{}	1	20	2025-09-29 06:04:33.677209	2025-09-29 06:04:33.677209	2025-09-29 06:04:33.685944	2025-09-29 06:04:33.697118	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
4	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 2}	{}	1	5	2025-09-29 06:04:33.693619	2025-09-29 06:04:33.693619	2025-09-29 06:04:33.702925	2025-09-29 06:04:41.483422	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
192	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226163323_1"}	{}	1	20	2026-02-26 19:47:05.55272	2026-02-26 19:47:05.55272	2026-02-26 19:47:05.561125	2026-02-26 19:47:05.569985	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
5	completed	tickets	Kabeberi.TicketWorker	{"reference": "20250929142915_1"}	{}	1	20	2025-09-29 14:29:50.932306	2025-09-29 14:29:50.932306	2025-09-29 14:29:50.941989	2025-09-29 14:29:50.955378	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
6	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 3}	{}	1	5	2025-09-29 14:29:50.949361	2025-09-29 14:29:50.949361	2025-09-29 14:29:50.95893	2025-09-29 14:29:58.737252	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
7	completed	tickets	Kabeberi.TicketWorker	{"reference": "20250929155350_1"}	{}	1	20	2025-09-29 15:54:22.906946	2025-09-29 15:54:22.906946	2025-09-29 15:54:22.91596	2025-09-29 15:54:22.927977	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
8	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 4}	{}	1	5	2025-09-29 15:54:22.922189	2025-09-29 15:54:22.922189	2025-09-29 15:54:22.930856	2025-09-29 15:54:31.148454	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
9	completed	tickets	Kabeberi.TicketWorker	{"reference": "20250929155636_1"}	{}	1	20	2025-09-29 15:56:57.832016	2025-09-29 15:56:57.832016	2025-09-29 15:56:57.840874	2025-09-29 15:56:57.858363	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
10	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 6}	{}	1	5	2025-09-29 15:56:57.848131	2025-09-29 15:56:57.848131	2025-09-29 15:56:57.855798	2025-09-29 15:57:07.405991	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
11	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 7}	{}	1	5	2025-09-29 15:56:57.852008	2025-09-29 15:56:57.852008	2025-09-29 15:56:57.855798	2025-09-29 15:57:07.43626	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
12	completed	tickets	Kabeberi.TicketWorker	{"reference": "20250929171623_1"}	{}	1	20	2025-09-29 17:16:46.227673	2025-09-29 17:16:46.227673	2025-09-29 17:16:46.236921	2025-09-29 17:16:46.248017	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
13	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 8}	{}	1	5	2025-09-29 17:16:46.24364	2025-09-29 17:16:46.24364	2025-09-29 17:16:46.25189	2025-09-29 17:16:53.88961	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
14	completed	tickets	Kabeberi.TicketWorker	{"reference": "20250929173105_1"}	{}	1	20	2025-09-29 17:31:35.054588	2025-09-29 17:31:35.054588	2025-09-29 17:31:35.063847	2025-09-29 17:31:35.092098	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
15	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 9}	{}	1	5	2025-09-29 17:31:35.071923	2025-09-29 17:31:35.071923	2025-09-29 17:31:35.081048	2025-09-29 17:31:43.455521	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
16	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 10}	{}	1	5	2025-09-29 17:31:35.077995	2025-09-29 17:31:35.077995	2025-09-29 17:31:35.081048	2025-09-29 17:31:43.469265	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
17	completed	tickets	Kabeberi.TicketWorker	{"reference": "20250930180203_1"}	{}	1	20	2025-09-30 18:02:30.338309	2025-09-30 18:02:30.338309	2025-09-30 18:02:30.346946	2025-09-30 18:02:30.357099	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
18	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 12}	{}	1	5	2025-09-30 18:02:30.353047	2025-09-30 18:02:30.353047	2025-09-30 18:02:30.36092	2025-09-30 18:02:37.982688	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
19	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251001101752_1"}	{}	1	20	2025-10-01 10:18:50.189992	2025-10-01 10:18:50.189992	2025-10-01 10:18:50.200021	2025-10-01 10:18:50.218617	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
20	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 15}	{}	1	5	2025-10-01 10:18:50.212864	2025-10-01 10:18:50.212864	2025-10-01 10:18:50.221865	2025-10-01 10:18:56.881439	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
21	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251001164820_1"}	{}	1	20	2025-10-01 16:48:45.374091	2025-10-01 16:48:45.374091	2025-10-01 16:48:45.383851	2025-10-01 16:48:45.395949	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
22	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 17}	{}	1	5	2025-10-01 16:48:45.39135	2025-10-01 16:48:45.39135	2025-10-01 16:48:45.39988	2025-10-01 16:48:52.009791	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
23	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251001165020_1"}	{}	1	20	2025-10-01 16:50:40.180166	2025-10-01 16:50:40.180166	2025-10-01 16:50:40.18894	2025-10-01 16:50:40.200602	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
24	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 18}	{}	1	5	2025-10-01 16:50:40.196341	2025-10-01 16:50:40.196341	2025-10-01 16:50:40.204876	2025-10-01 16:50:47.108983	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
25	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251001165734_1"}	{}	1	20	2025-10-01 16:57:53.694697	2025-10-01 16:57:53.694697	2025-10-01 16:57:53.703923	2025-10-01 16:57:53.715921	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
26	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 19}	{}	1	5	2025-10-01 16:57:53.711644	2025-10-01 16:57:53.711644	2025-10-01 16:57:53.719855	2025-10-01 16:58:00.827402	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
33	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 24}	{}	1	5	2025-10-03 12:43:18.789724	2025-10-03 12:43:18.789724	2025-10-03 12:43:18.797865	2025-10-03 12:43:26.771309	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
27	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251003092118_1"}	{}	1	20	2025-10-03 09:22:45.290122	2025-10-03 09:22:45.290122	2025-10-03 09:22:45.29991	2025-10-03 09:22:45.311047	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
35	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 25}	{}	1	5	2025-10-05 14:38:44.043084	2025-10-05 14:38:44.043084	2025-10-05 14:38:44.0519	2025-10-05 14:38:51.499105	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
28	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 21}	{}	1	5	2025-10-03 09:22:45.306629	2025-10-03 09:22:45.306629	2025-10-03 09:22:45.31489	2025-10-03 09:22:52.838535	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
65	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 45}	{}	1	5	2025-10-15 17:15:11.36855	2025-10-15 17:15:11.36855	2025-10-15 17:15:11.375855	2025-10-15 17:15:19.694373	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
36	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251005150530_1"}	{}	1	20	2025-10-05 15:06:04.122207	2025-10-05 15:06:04.122207	2025-10-05 15:06:04.129873	2025-10-05 15:06:04.138868	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
39	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 27}	{}	1	5	2025-10-07 13:58:55.439537	2025-10-07 13:58:55.439537	2025-10-07 13:58:55.448912	2025-10-07 13:59:04.094532	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
43	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 30}	{}	1	5	2025-10-10 17:47:40.959495	2025-10-10 17:47:40.959495	2025-10-10 17:47:40.967871	2025-10-10 17:47:48.256937	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
47	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251011235523_1"}	{}	1	20	2025-10-11 23:55:48.039218	2025-10-11 23:55:48.039218	2025-10-11 23:55:48.047984	2025-10-11 23:55:48.058577	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
66	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251016193134_1"}	{}	1	20	2025-10-16 19:31:56.343818	2025-10-16 19:31:56.343818	2025-10-16 19:31:56.351825	2025-10-16 19:31:56.360408	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
48	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 33}	{}	1	5	2025-10-11 23:55:48.05423	2025-10-11 23:55:48.05423	2025-10-11 23:55:48.062871	2025-10-11 23:55:55.17763	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
49	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251011235631_1"}	{}	1	20	2025-10-11 23:57:12.011366	2025-10-11 23:57:12.011366	2025-10-11 23:57:12.019836	2025-10-11 23:57:12.030525	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
69	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 47}	{}	1	5	2025-10-17 03:14:07.222568	2025-10-17 03:14:07.222568	2025-10-17 03:14:07.230848	2025-10-17 03:14:14.524787	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
51	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251011235701_1"}	{}	1	20	2025-10-11 23:57:27.36619	2025-10-11 23:57:27.36619	2025-10-11 23:57:27.373881	2025-10-11 23:57:27.387261	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
71	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 48}	{}	1	5	2025-10-17 05:04:16.539098	2025-10-17 05:04:16.539098	2025-10-17 05:04:16.546868	2025-10-17 05:04:24.211431	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
54	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251012100654_1"}	{}	1	20	2025-10-12 10:07:20.995225	2025-10-12 10:07:20.995225	2025-10-12 10:07:21.003924	2025-10-12 10:07:21.016467	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
75	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 50}	{}	1	5	2025-10-17 21:28:30.888426	2025-10-17 21:28:30.888426	2025-10-17 21:28:30.896893	2025-10-17 21:28:38.31042	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
78	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 51}	{}	1	5	2025-10-17 23:47:33.134329	2025-10-17 23:47:33.134329	2025-10-17 23:47:33.142915	2025-10-17 23:47:39.669283	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
56	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251013115849_1"}	{}	1	20	2025-10-13 11:59:16.299047	2025-10-13 11:59:16.299047	2025-10-13 11:59:16.30793	2025-10-13 11:59:16.31953	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
59	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 41}	{}	1	5	2025-10-13 20:32:41.865194	2025-10-13 20:32:41.865194	2025-10-13 20:32:41.872868	2025-10-13 20:32:48.961295	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
63	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 44}	{}	1	5	2025-10-15 15:41:13.381019	2025-10-15 15:41:13.381019	2025-10-15 15:41:13.388882	2025-10-15 15:41:21.089334	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
82	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 53}	{}	1	5	2025-10-18 07:20:30.609553	2025-10-18 07:20:30.609553	2025-10-18 07:20:30.618875	2025-10-18 07:20:38.083636	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
86	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 59}	{}	1	5	2025-10-18 10:24:03.652391	2025-10-18 10:24:03.652391	2025-10-18 10:24:03.660855	2025-10-18 10:24:15.408355	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
85	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 58}	{}	1	5	2025-10-18 10:24:03.647875	2025-10-18 10:24:03.647875	2025-10-18 10:24:03.65184	2025-10-18 10:24:15.451916	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
90	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 61}	{}	1	5	2025-10-18 11:06:52.968352	2025-10-18 11:06:52.968352	2025-10-18 11:06:52.976863	2025-10-18 11:07:00.89718	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
91	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251018114222_1"}	{}	1	20	2025-10-18 11:42:48.856729	2025-10-18 11:42:48.856729	2025-10-18 11:42:48.864912	2025-10-18 11:42:48.874547	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
32	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251003124249_1"}	{}	1	20	2025-10-03 12:43:18.775181	2025-10-03 12:43:18.775181	2025-10-03 12:43:18.783905	2025-10-03 12:43:18.79482	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
37	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 26}	{}	1	5	2025-10-05 15:06:04.134686	2025-10-05 15:06:04.134686	2025-10-05 15:06:04.141883	2025-10-05 15:06:13.694842	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
30	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 22}	{}	1	5	2025-10-03 09:22:45.927386	2025-10-03 09:22:45.927386	2025-10-03 09:22:45.935873	2025-10-03 09:22:52.854158	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
64	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251015171443_1"}	{}	1	20	2025-10-15 17:15:11.354373	2025-10-15 17:15:11.354373	2025-10-15 17:15:11.362881	2025-10-15 17:15:11.372872	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
40	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251010112846_1"}	{}	1	20	2025-10-10 11:29:11.311198	2025-10-10 11:29:11.311198	2025-10-10 11:29:11.319831	2025-10-10 11:29:11.329807	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
67	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 46}	{}	1	5	2025-10-16 19:31:56.356863	2025-10-16 19:31:56.356863	2025-10-16 19:31:56.364822	2025-10-16 19:32:04.833572	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
70	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251017050347_1"}	{}	1	20	2025-10-17 05:04:16.521842	2025-10-17 05:04:16.521842	2025-10-17 05:04:16.53295	2025-10-17 05:04:16.543246	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
98	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 64}	{}	1	5	2025-10-18 12:51:40.763173	2025-10-18 12:51:40.763173	2025-10-18 12:51:40.770931	2025-10-18 12:51:49.049814	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
44	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251011235359_1"}	{}	1	20	2025-10-11 23:54:23.751962	2025-10-11 23:54:23.751962	2025-10-11 23:54:23.76082	2025-10-11 23:54:23.779852	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
46	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 32}	{}	1	5	2025-10-11 23:54:23.771242	2025-10-11 23:54:23.771242	2025-10-11 23:54:23.774825	2025-10-11 23:54:30.482365	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
142	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 93}	{}	1	5	2025-12-04 17:07:27.777095	2025-12-04 17:07:27.777095	2025-12-04 17:07:27.785873	2025-12-04 17:07:35.922161	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
73	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 49}	{}	1	5	2025-10-17 17:01:30.621627	2025-10-17 17:01:30.621627	2025-10-17 17:01:30.630886	2025-10-17 17:01:36.427612	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
50	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 34}	{}	1	5	2025-10-11 23:57:12.025045	2025-10-11 23:57:12.025045	2025-10-11 23:57:12.033841	2025-10-11 23:57:19.068113	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
52	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 35}	{}	1	5	2025-10-11 23:57:27.37982	2025-10-11 23:57:27.37982	2025-10-11 23:57:27.386875	2025-10-11 23:57:33.271831	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
76	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251017234656_1"}	{}	1	20	2025-10-17 23:47:22.011187	2025-10-17 23:47:22.011187	2025-10-17 23:47:22.01894	2025-10-17 23:47:22.02805	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
57	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 40}	{}	1	5	2025-10-13 11:59:16.315022	2025-10-13 11:59:16.315022	2025-10-13 11:59:16.323928	2025-10-13 11:59:23.941211	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
99	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251018154334_1"}	{}	1	20	2025-10-18 15:44:06.667387	2025-10-18 15:44:06.667387	2025-10-18 15:44:06.675941	2025-10-18 15:44:06.69163	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
79	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251018062306_1"}	{}	1	20	2025-10-18 06:23:44.629827	2025-10-18 06:23:44.629827	2025-10-18 06:23:44.637872	2025-10-18 06:23:44.648102	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
60	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251015153458_1"}	{}	1	20	2025-10-15 15:38:16.177065	2025-10-15 15:38:16.177065	2025-10-15 15:38:16.185942	2025-10-15 15:38:16.198225	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
81	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251018071936_1"}	{}	1	20	2025-10-18 07:20:30.590737	2025-10-18 07:20:30.590737	2025-10-18 07:20:30.602914	2025-10-18 07:20:30.615123	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
101	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 66}	{}	1	5	2025-10-18 15:44:06.685622	2025-10-18 15:44:06.685622	2025-10-18 15:44:06.689837	2025-10-18 15:44:15.787374	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
62	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251015154041_1"}	{}	1	20	2025-10-15 15:41:13.365553	2025-10-15 15:41:13.365553	2025-10-15 15:41:13.373884	2025-10-15 15:41:13.385815	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
83	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251018102331_1"}	{}	1	20	2025-10-18 10:24:03.626669	2025-10-18 10:24:03.626669	2025-10-18 10:24:03.635904	2025-10-18 10:24:03.66261	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
103	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 67}	{}	1	5	2025-10-18 17:15:30.244486	2025-10-18 17:15:30.244486	2025-10-18 17:15:30.25281	2025-10-18 17:15:37.51277	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
88	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 60}	{}	1	5	2025-10-18 10:34:21.453535	2025-10-18 10:34:21.453535	2025-10-18 10:34:21.461884	2025-10-18 10:34:29.501933	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
92	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 62}	{}	1	5	2025-10-18 11:42:48.869454	2025-10-18 11:42:48.869454	2025-10-18 11:42:48.877901	2025-10-18 11:42:56.853951	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
96	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 63}	{}	1	5	2025-10-18 12:14:07.081313	2025-10-18 12:14:07.081313	2025-10-18 12:14:07.088932	2025-10-18 12:14:18.493788	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
97	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251018125039_1"}	{}	1	20	2025-10-18 12:51:40.749872	2025-10-18 12:51:40.749872	2025-10-18 12:51:40.757915	2025-10-18 12:51:40.766859	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
100	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 65}	{}	1	5	2025-10-18 15:44:06.6813	2025-10-18 15:44:06.6813	2025-10-18 15:44:06.689837	2025-10-18 15:44:15.791273	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
29	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251003092223_1"}	{}	1	20	2025-10-03 09:22:45.912603	2025-10-03 09:22:45.912603	2025-10-03 09:22:45.920858	2025-10-03 09:22:45.939165	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
31	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 23}	{}	1	5	2025-10-03 09:22:45.931672	2025-10-03 09:22:45.931672	2025-10-03 09:22:45.935873	2025-10-03 09:22:52.875456	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
34	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251005143812_1"}	{}	1	20	2025-10-05 14:38:44.027226	2025-10-05 14:38:44.027226	2025-10-05 14:38:44.035933	2025-10-05 14:38:44.047894	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
68	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251017031336_1"}	{}	1	20	2025-10-17 03:14:07.206903	2025-10-17 03:14:07.206903	2025-10-17 03:14:07.215902	2025-10-17 03:14:07.227494	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
134	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251203200928_1"}	{}	1	20	2025-12-03 20:10:01.951172	2025-12-03 20:10:01.951172	2025-12-03 20:10:01.960927	2025-12-03 20:10:01.972898	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
38	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251007135831_1"}	{}	1	20	2025-10-07 13:58:55.423164	2025-10-07 13:58:55.423164	2025-10-07 13:58:55.431911	2025-10-07 13:58:55.446286	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
72	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251017170106_1"}	{}	1	20	2025-10-17 17:01:30.605814	2025-10-17 17:01:30.605814	2025-10-17 17:01:30.614902	2025-10-17 17:01:30.626885	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
41	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 29}	{}	1	5	2025-10-10 11:29:11.325885	2025-10-10 11:29:11.325885	2025-10-10 11:29:11.333875	2025-10-10 11:29:18.553172	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
102	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251018171452_1"}	{}	1	20	2025-10-18 17:15:30.228457	2025-10-18 17:15:30.228457	2025-10-18 17:15:30.237919	2025-10-18 17:15:30.255408	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
104	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 68}	{}	1	5	2025-10-18 17:15:30.248754	2025-10-18 17:15:30.248754	2025-10-18 17:15:30.25281	2025-10-18 17:15:37.525399	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
42	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251010174712_1"}	{}	1	20	2025-10-10 17:47:40.945374	2025-10-10 17:47:40.945374	2025-10-10 17:47:40.953847	2025-10-10 17:47:40.964215	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
74	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251017212748_1"}	{}	1	20	2025-10-17 21:28:30.874495	2025-10-17 21:28:30.874495	2025-10-17 21:28:30.882894	2025-10-17 21:28:30.893893	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
45	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 31}	{}	1	5	2025-10-11 23:54:23.767257	2025-10-11 23:54:23.767257	2025-10-11 23:54:23.774825	2025-10-11 23:54:30.497645	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
77	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 51}	{}	1	5	2025-10-17 23:47:22.02424	2025-10-17 23:47:22.02424	2025-10-17 23:47:22.031891	2025-10-17 23:47:29.717235	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
53	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 36}	{}	1	5	2025-10-11 23:57:27.382108	2025-10-11 23:57:27.382108	2025-10-11 23:57:27.386875	2025-10-11 23:57:32.74831	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
55	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 39}	{}	1	5	2025-10-12 10:07:21.011821	2025-10-12 10:07:21.011821	2025-10-12 10:07:21.019877	2025-10-12 10:07:29.876354	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
58	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251013203102_1"}	{}	1	20	2025-10-13 20:32:41.851139	2025-10-13 20:32:41.851139	2025-10-13 20:32:41.859864	2025-10-13 20:32:41.869231	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
80	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 52}	{}	1	5	2025-10-18 06:23:44.643323	2025-10-18 06:23:44.643323	2025-10-18 06:23:44.650862	2025-10-18 06:23:52.274857	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
61	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 43}	{}	1	5	2025-10-15 15:38:16.193431	2025-10-15 15:38:16.193431	2025-10-15 15:38:16.201864	2025-10-15 15:38:24.317303	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
84	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 57}	{}	1	5	2025-10-18 10:24:03.642669	2025-10-18 10:24:03.642669	2025-10-18 10:24:03.65184	2025-10-18 10:24:15.427879	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
87	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251018103350_1"}	{}	1	20	2025-10-18 10:34:21.438219	2025-10-18 10:34:21.438219	2025-10-18 10:34:21.446869	2025-10-18 10:34:21.45786	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
89	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251018110624_1"}	{}	1	20	2025-10-18 11:06:52.95292	2025-10-18 11:06:52.95292	2025-10-18 11:06:52.961972	2025-10-18 11:06:52.973963	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
93	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251018114822_1"}	{}	1	20	2025-10-18 11:48:54.604335	2025-10-18 11:48:54.604335	2025-10-18 11:48:54.612887	2025-10-18 11:48:54.62238	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
94	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 63}	{}	1	5	2025-10-18 11:48:54.618617	2025-10-18 11:48:54.618617	2025-10-18 11:48:54.625926	2025-10-18 11:49:02.648833	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
95	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 63}	{}	1	5	2025-10-18 12:14:01.981078	2025-10-18 12:14:01.981078	2025-10-18 12:14:01.989892	2025-10-18 12:14:14.533844	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
176	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 118}	{}	1	5	2026-02-26 16:40:06.035223	2026-02-26 16:40:06.035223	2026-02-26 16:40:06.044153	2026-02-26 16:40:07.089911	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
135	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 88}	{}	1	5	2025-12-03 20:10:01.96798	2025-12-03 20:10:01.96798	2025-12-03 20:10:01.97588	2025-12-03 20:10:13.668056	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
106	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 69}	{}	1	5	2025-11-20 06:41:45.168967	2025-11-20 06:41:45.168967	2025-11-20 06:41:45.176865	2025-11-20 06:41:51.51934	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
107	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 70}	{}	1	5	2025-11-20 06:41:45.172731	2025-11-20 06:41:45.172731	2025-11-20 06:41:45.176865	2025-11-20 06:41:51.970498	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
108	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251120135214_1"}	{}	1	20	2025-11-20 13:52:55.34674	2025-11-20 13:52:55.34674	2025-11-20 13:52:55.354837	2025-11-20 13:52:55.365214	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
139	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 91}	{}	1	5	2025-12-04 16:45:32.331885	2025-12-04 16:45:32.331885	2025-12-04 16:45:32.340802	2025-12-04 16:45:40.036918	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
140	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 92}	{}	1	5	2025-12-04 16:45:32.337117	2025-12-04 16:45:32.337117	2025-12-04 16:45:32.340802	2025-12-04 16:45:40.04137	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
145	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 95}	{}	1	5	2025-12-05 10:11:50.946212	2025-12-05 10:11:50.946212	2025-12-05 10:11:50.949802	2025-12-05 10:11:58.190228	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
147	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 96}	{}	1	5	2025-12-06 04:37:56.818735	2025-12-06 04:37:56.818735	2025-12-06 04:37:56.826883	2025-12-06 04:38:04.839132	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
149	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 97}	{}	1	5	2025-12-06 07:55:12.298562	2025-12-06 07:55:12.298562	2025-12-06 07:55:12.306828	2025-12-06 07:55:20.805592	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
150	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 98}	{}	1	5	2025-12-06 07:55:12.302305	2025-12-06 07:55:12.302305	2025-12-06 07:55:12.306828	2025-12-06 07:55:20.827919	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
152	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 100}	{}	1	5	2025-12-06 12:13:09.260654	2025-12-06 12:13:09.260654	2025-12-06 12:13:09.2699	2025-12-06 12:13:18.372114	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
153	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251206132030_1"}	{}	1	20	2025-12-06 13:20:56.336388	2025-12-06 13:20:56.336388	2025-12-06 13:20:56.344899	2025-12-06 13:20:56.366275	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
155	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 102}	{}	1	5	2025-12-06 13:20:56.355777	2025-12-06 13:20:56.355777	2025-12-06 13:20:56.35989	2025-12-06 13:21:06.725766	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
157	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 103}	{}	1	5	2025-12-06 16:19:36.784606	2025-12-06 16:19:36.784606	2025-12-06 16:19:36.793878	2025-12-06 16:19:44.726795	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
159	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 106}	{}	1	5	2025-12-06 16:57:26.795118	2025-12-06 16:57:26.795118	2025-12-06 16:57:26.804862	2025-12-06 16:57:34.619875	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
161	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 107}	{}	1	5	2025-12-06 17:00:33.451436	2025-12-06 17:00:33.451436	2025-12-06 17:00:33.459843	2025-12-06 17:00:40.317936	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
181	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 118}	{}	1	5	2026-02-26 19:47:05.195412	2026-02-26 19:47:05.195412	2026-02-26 19:47:05.205097	2026-02-26 19:47:06.05274	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
195	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 118}	{}	1	5	2026-02-26 19:47:05.661236	2026-02-26 19:47:05.661236	2026-02-26 19:47:05.67105	2026-02-26 19:47:06.062453	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
162	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260217163134_1"}	{}	1	20	2026-02-17 16:32:14.817602	2026-02-17 16:32:14.817602	2026-02-17 16:32:14.833908	2026-02-17 16:32:14.865142	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
165	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 109}	{}	1	5	2026-02-18 06:16:14.120906	2026-02-18 06:16:14.120906	2026-02-18 06:16:14.12903	2026-02-18 06:16:15.059923	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
167	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 110}	{}	1	5	2026-02-24 11:29:19.421662	2026-02-24 11:29:19.421662	2026-02-24 11:29:19.430078	2026-02-24 11:29:20.556596	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
169	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 111}	{}	1	5	2026-02-24 13:03:59.776352	2026-02-24 13:03:59.776352	2026-02-24 13:03:59.784072	2026-02-24 13:04:00.318055	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
172	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260225184501_1"}	{}	1	20	2026-02-25 18:45:31.462782	2026-02-25 18:45:31.462782	2026-02-25 18:45:31.472058	2026-02-25 18:45:31.484844	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
173	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 115}	{}	1	5	2026-02-25 18:45:31.479507	2026-02-25 18:45:31.479507	2026-02-25 18:45:31.488035	2026-02-25 18:45:32.354196	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
175	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 116}	{}	1	5	2026-02-26 14:30:10.032856	2026-02-26 14:30:10.032856	2026-02-26 14:30:10.042104	2026-02-26 14:30:10.446315	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
105	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251120064122_1"}	{}	1	20	2025-11-20 06:41:45.154476	2025-11-20 06:41:45.154476	2025-11-20 06:41:45.162934	2025-11-20 06:41:45.178216	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
109	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 71}	{}	1	5	2025-11-20 13:52:55.360884	2025-11-20 13:52:55.360884	2025-11-20 13:52:55.368877	2025-11-20 13:53:03.982641	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
110	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251120152646_1"}	{}	1	20	2025-11-20 15:27:16.176178	2025-11-20 15:27:16.176178	2025-11-20 15:27:16.185015	2025-11-20 15:27:16.195362	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
111	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 72}	{}	1	5	2025-11-20 15:27:16.191347	2025-11-20 15:27:16.191347	2025-11-20 15:27:16.198847	2025-11-20 15:27:24.044113	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
112	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251121031348_1"}	{}	1	20	2025-11-21 03:14:16.90117	2025-11-21 03:14:16.90117	2025-11-21 03:14:16.909913	2025-11-21 03:14:16.920045	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
136	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251204164502_1"}	{}	1	20	2025-12-04 16:45:32.30591	2025-12-04 16:45:32.30591	2025-12-04 16:45:32.314975	2025-12-04 16:45:32.351892	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
113	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 73}	{}	1	5	2025-11-21 03:14:16.915904	2025-11-21 03:14:16.915904	2025-11-21 03:14:16.923897	2025-11-21 03:14:24.238936	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
138	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 90}	{}	1	5	2025-12-04 16:45:32.326547	2025-12-04 16:45:32.326547	2025-12-04 16:45:32.330886	2025-12-04 16:45:40.042014	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
114	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251129162525_1"}	{}	1	20	2025-11-29 16:25:54.080269	2025-11-29 16:25:54.080269	2025-11-29 16:25:54.088915	2025-11-29 16:25:54.106282	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
115	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 75}	{}	1	5	2025-11-29 16:25:54.096348	2025-11-29 16:25:54.096348	2025-11-29 16:25:54.104837	2025-11-29 16:26:01.178995	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
116	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 76}	{}	1	5	2025-11-29 16:25:54.100306	2025-11-29 16:25:54.100306	2025-11-29 16:25:54.104837	2025-11-29 16:26:01.179351	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
117	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251201183203_1"}	{}	1	20	2025-12-01 18:33:01.769502	2025-12-01 18:33:01.769502	2025-12-01 18:33:01.779936	2025-12-01 18:33:01.797623	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
118	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 77}	{}	1	5	2025-12-01 18:33:01.789561	2025-12-01 18:33:01.789561	2025-12-01 18:33:01.800827	2025-12-01 18:33:10.788851	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
119	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251202072341_1"}	{}	1	20	2025-12-02 07:24:13.438218	2025-12-02 07:24:13.438218	2025-12-02 07:24:13.447916	2025-12-02 07:24:13.459181	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
120	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 78}	{}	1	5	2025-12-02 07:24:13.454127	2025-12-02 07:24:13.454127	2025-12-02 07:24:13.462982	2025-12-02 07:24:20.856231	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
121	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251202085822_1"}	{}	1	20	2025-12-02 08:58:51.173732	2025-12-02 08:58:51.173732	2025-12-02 08:58:51.182944	2025-12-02 08:58:51.209455	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
122	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 79}	{}	1	5	2025-12-02 08:58:51.19033	2025-12-02 08:58:51.19033	2025-12-02 08:58:51.198853	2025-12-02 08:58:58.254591	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
123	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 80}	{}	1	5	2025-12-02 08:58:51.195327	2025-12-02 08:58:51.195327	2025-12-02 08:58:51.198853	2025-12-02 08:58:58.282204	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
124	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 81}	{}	1	5	2025-12-02 08:58:51.199624	2025-12-02 08:58:51.199624	2025-12-02 08:58:51.207818	2025-12-02 08:58:58.694664	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
125	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251202140825_1"}	{}	1	20	2025-12-02 14:09:12.626453	2025-12-02 14:09:12.626453	2025-12-02 14:09:12.635923	2025-12-02 14:09:12.648101	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
126	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 82}	{}	1	5	2025-12-02 14:09:12.642561	2025-12-02 14:09:12.642561	2025-12-02 14:09:12.651869	2025-12-02 14:09:20.051966	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
127	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251202151945_1"}	{}	1	20	2025-12-02 15:20:33.486757	2025-12-02 15:20:33.486757	2025-12-02 15:20:33.496984	2025-12-02 15:20:33.511126	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
128	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 83}	{}	1	5	2025-12-02 15:20:33.506024	2025-12-02 15:20:33.506024	2025-12-02 15:20:33.514915	2025-12-02 15:20:41.509394	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
129	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251203105536_1"}	{}	1	20	2025-12-03 10:55:56.782661	2025-12-03 10:55:56.782661	2025-12-03 10:55:56.791928	2025-12-03 10:55:56.815613	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
131	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 87}	{}	1	5	2025-12-03 10:55:56.804407	2025-12-03 10:55:56.804407	2025-12-03 10:55:56.808901	2025-12-03 10:56:04.342969	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
133	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 87}	{}	1	5	2025-12-03 10:57:44.493515	2025-12-03 10:57:44.493515	2025-12-03 10:57:44.498943	2025-12-03 10:57:50.528301	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
132	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 86}	{}	1	5	2025-12-03 10:57:44.490901	2025-12-03 10:57:44.490901	2025-12-03 10:57:44.498943	2025-12-03 10:57:50.550881	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
130	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 86}	{}	1	5	2025-12-03 10:55:56.799683	2025-12-03 10:55:56.799683	2025-12-03 10:55:56.808901	2025-12-03 10:56:04.337463	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
226	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 125}	{}	1	5	2026-02-27 14:40:56.501244	2026-02-27 14:40:56.501244	2026-02-27 14:40:56.510022	2026-02-27 14:40:56.894261	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
137	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 89}	{}	1	5	2025-12-04 16:45:32.322276	2025-12-04 16:45:32.322276	2025-12-04 16:45:32.330886	2025-12-04 16:45:40.022454	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
177	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 118}	{}	1	5	2026-02-26 16:40:12.67228	2026-02-26 16:40:12.67228	2026-02-26 16:40:12.681138	2026-02-26 16:40:13.037563	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
178	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226163323_1"}	{}	1	20	2026-02-26 19:47:05.052368	2026-02-26 19:47:05.052368	2026-02-26 19:47:05.061103	2026-02-26 19:47:05.070413	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
141	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251204170657_1"}	{}	1	20	2025-12-04 17:07:27.760796	2025-12-04 17:07:27.760796	2025-12-04 17:07:27.76988	2025-12-04 17:07:27.781791	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
180	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226163323_1"}	{}	1	20	2026-02-26 19:47:05.18202	2026-02-26 19:47:05.18202	2026-02-26 19:47:05.190082	2026-02-26 19:47:05.203123	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
182	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226163323_1"}	{}	1	20	2026-02-26 19:47:05.202197	2026-02-26 19:47:05.202197	2026-02-26 19:47:05.211038	2026-02-26 19:47:05.219867	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
143	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251205101118_1"}	{}	1	20	2025-12-05 10:11:50.92001	2025-12-05 10:11:50.92001	2025-12-05 10:11:50.929949	2025-12-05 10:11:50.953041	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
144	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 94}	{}	1	5	2025-12-05 10:11:50.94048	2025-12-05 10:11:50.94048	2025-12-05 10:11:50.949802	2025-12-05 10:11:58.20323	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
146	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251206043722_1"}	{}	1	20	2025-12-06 04:37:56.80108	2025-12-06 04:37:56.80108	2025-12-06 04:37:56.810885	2025-12-06 04:37:56.823836	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
148	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251206075421_1"}	{}	1	20	2025-12-06 07:55:12.283077	2025-12-06 07:55:12.283077	2025-12-06 07:55:12.291888	2025-12-06 07:55:12.309356	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
184	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226163323_1"}	{}	1	20	2026-02-26 19:47:05.217001	2026-02-26 19:47:05.217001	2026-02-26 19:47:05.224994	2026-02-26 19:47:05.233521	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
151	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251206121245_1"}	{}	1	20	2025-12-06 12:13:09.242597	2025-12-06 12:13:09.242597	2025-12-06 12:13:09.252012	2025-12-06 12:13:09.266379	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
154	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 101}	{}	1	5	2025-12-06 13:20:56.350521	2025-12-06 13:20:56.350521	2025-12-06 13:20:56.35989	2025-12-06 13:21:06.720082	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,28b5c610-0662-4c30-a666-606f72d3ee80}	\N	0	{}	{}	\N
156	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251206161904_1"}	{}	1	20	2025-12-06 16:19:36.765538	2025-12-06 16:19:36.765538	2025-12-06 16:19:36.774941	2025-12-06 16:19:36.79075	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
179	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 118}	{}	1	5	2026-02-26 19:47:05.06606	2026-02-26 19:47:05.06606	2026-02-26 19:47:05.074108	2026-02-26 19:47:06.006541	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
158	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251206165657_1"}	{}	1	20	2025-12-06 16:57:26.774614	2025-12-06 16:57:26.774614	2025-12-06 16:57:26.785923	2025-12-06 16:57:26.801134	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
160	completed	tickets	Kabeberi.TicketWorker	{"reference": "20251206170000_1"}	{}	1	20	2025-12-06 17:00:33.437296	2025-12-06 17:00:33.437296	2025-12-06 17:00:33.445878	2025-12-06 17:00:33.458036	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,90793570-99e1-4b41-8e7e-06b7bda1fc34}	\N	0	{}	{}	\N
185	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 118}	{}	1	5	2026-02-26 19:47:05.22896	2026-02-26 19:47:05.22896	2026-02-26 19:47:05.237072	2026-02-26 19:47:06.095212	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
163	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 108}	{}	1	5	2026-02-17 16:32:14.849519	2026-02-17 16:32:14.849519	2026-02-17 16:32:14.861372	2026-02-17 16:32:15.918065	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
164	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260218061548_1"}	{}	1	20	2026-02-18 06:16:14.103367	2026-02-18 06:16:14.103367	2026-02-18 06:16:14.114046	2026-02-18 06:16:14.126247	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
166	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260224112836_1"}	{}	1	20	2026-02-24 11:29:19.401114	2026-02-24 11:29:19.401114	2026-02-24 11:29:19.411081	2026-02-24 11:29:19.427176	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
168	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260224130325_1"}	{}	1	20	2026-02-24 13:03:59.759539	2026-02-24 13:03:59.759539	2026-02-24 13:03:59.769063	2026-02-24 13:03:59.781613	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
170	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260224204206_1"}	{}	1	20	2026-02-24 20:43:55.04596	2026-02-24 20:43:55.04596	2026-02-24 20:43:55.054024	2026-02-24 20:43:55.063792	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
171	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 113}	{}	1	5	2026-02-24 20:43:55.059251	2026-02-24 20:43:55.059251	2026-02-24 20:43:55.067072	2026-02-24 20:43:55.967982	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
174	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226142934_1"}	{}	1	20	2026-02-26 14:30:10.016454	2026-02-26 14:30:10.016454	2026-02-26 14:30:10.025183	2026-02-26 14:30:10.039737	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
186	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226163323_1"}	{}	1	20	2026-02-26 19:47:05.362264	2026-02-26 19:47:05.362264	2026-02-26 19:47:05.370038	2026-02-26 19:47:05.37913	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
221	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260227063120_1"}	{}	1	20	2026-02-27 06:32:37.188083	2026-02-27 06:32:37.188083	2026-02-27 06:32:37.198176	2026-02-27 06:32:37.208748	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
227	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260227144344_1"}	{}	1	20	2026-02-27 14:46:29.76518	2026-02-27 14:46:29.76518	2026-02-27 14:46:29.774045	2026-02-27 14:46:29.785041	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
230	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 127}	{}	1	5	2026-02-27 16:08:53.707748	2026-02-27 16:08:53.707748	2026-02-27 16:08:53.716191	2026-02-27 16:08:54.61256	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
188	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226163323_1"}	{}	1	20	2026-02-26 19:47:05.460918	2026-02-26 19:47:05.460918	2026-02-26 19:47:05.469235	2026-02-26 19:47:05.479494	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
189	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226163323_1"}	{}	1	20	2026-02-26 19:47:05.460903	2026-02-26 19:47:05.460903	2026-02-26 19:47:05.469235	2026-02-26 19:47:05.481728	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
235	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260227185827_1"}	{}	1	20	2026-02-27 18:59:03.169173	2026-02-27 18:59:03.169173	2026-02-27 18:59:03.1781	2026-02-27 18:59:03.188365	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
187	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 118}	{}	1	5	2026-02-26 19:47:05.374932	2026-02-26 19:47:05.374932	2026-02-26 19:47:05.38307	2026-02-26 19:47:06.245008	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
190	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 118}	{}	1	5	2026-02-26 19:47:05.472915	2026-02-26 19:47:05.472915	2026-02-26 19:47:05.481021	2026-02-26 19:47:06.323344	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
191	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 118}	{}	1	5	2026-02-26 19:47:05.472726	2026-02-26 19:47:05.472726	2026-02-26 19:47:05.481021	2026-02-26 19:47:06.333927	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
193	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 118}	{}	1	5	2026-02-26 19:47:05.565658	2026-02-26 19:47:05.565658	2026-02-26 19:47:05.574579	2026-02-26 19:47:06.416443	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
236	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 130}	{}	1	5	2026-02-27 18:59:03.184279	2026-02-27 18:59:03.184279	2026-02-27 18:59:03.192009	2026-02-27 18:59:03.531903	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
222	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 122}	{}	1	5	2026-02-27 06:32:37.204731	2026-02-27 06:32:37.204731	2026-02-27 06:32:37.213088	2026-02-27 06:32:38.107021	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
194	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226163323_1"}	{}	1	20	2026-02-26 19:47:05.646847	2026-02-26 19:47:05.646847	2026-02-26 19:47:05.656092	2026-02-26 19:47:05.66914	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
196	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226163323_1"}	{}	1	20	2026-02-26 19:47:05.66508	2026-02-26 19:47:05.66508	2026-02-26 19:47:05.675084	2026-02-26 19:47:05.685495	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
228	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 126}	{}	1	5	2026-02-27 14:46:29.780047	2026-02-27 14:46:29.780047	2026-02-27 14:46:29.788077	2026-02-27 14:46:30.697454	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
231	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260227161748_1"}	{}	1	20	2026-02-27 16:18:29.04145	2026-02-27 16:18:29.04145	2026-02-27 16:18:29.050088	2026-02-27 16:18:29.060114	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
197	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 118}	{}	1	5	2026-02-26 19:47:05.679583	2026-02-26 19:47:05.679583	2026-02-26 19:47:05.688205	2026-02-26 19:47:06.550133	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
223	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260227141402_1"}	{}	1	20	2026-02-27 14:14:29.940249	2026-02-27 14:14:29.940249	2026-02-27 14:14:29.949116	2026-02-27 14:14:29.959608	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
229	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260227160825_1"}	{}	1	20	2026-02-27 16:08:53.692954	2026-02-27 16:08:53.692954	2026-02-27 16:08:53.702138	2026-02-27 16:08:53.71167	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
232	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 128}	{}	1	5	2026-02-27 16:18:29.055819	2026-02-27 16:18:29.055819	2026-02-27 16:18:29.064059	2026-02-27 16:18:29.965836	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
233	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260227185724_1"}	{}	1	20	2026-02-27 18:58:00.300127	2026-02-27 18:58:00.300127	2026-02-27 18:58:00.309095	2026-02-27 18:58:00.321348	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
234	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 129}	{}	1	5	2026-02-27 18:58:00.315632	2026-02-27 18:58:00.315632	2026-02-27 18:58:00.324065	2026-02-27 18:58:01.20948	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
183	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 118}	{}	1	5	2026-02-26 19:47:05.214974	2026-02-26 19:47:05.214974	2026-02-26 19:47:05.2232	2026-02-26 19:47:06.088766	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
198	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 119}	{}	1	5	2026-02-26 20:29:57.5839	2026-02-26 20:29:57.5839	2026-02-26 20:29:57.592086	2026-02-26 20:29:58.469802	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
224	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 123}	{}	1	5	2026-02-27 14:14:29.955664	2026-02-27 14:14:29.955664	2026-02-27 14:14:29.964081	2026-02-27 14:14:30.567661	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
199	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226202912_1"}	{}	1	20	2026-02-26 21:58:06.52809	2026-02-26 21:58:06.52809	2026-02-26 21:58:06.53709	2026-02-26 21:58:06.547872	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
225	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260227143827_1"}	{}	1	20	2026-02-27 14:40:56.483695	2026-02-27 14:40:56.483695	2026-02-27 14:40:56.493141	2026-02-27 14:40:56.507519	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
200	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 119}	{}	1	5	2026-02-26 21:58:06.54358	2026-02-26 21:58:06.54358	2026-02-26 21:58:06.551086	2026-02-26 21:58:07.451052	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
201	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226202912_1"}	{}	1	20	2026-02-26 21:58:08.128615	2026-02-26 21:58:08.128615	2026-02-26 21:58:08.137079	2026-02-26 21:58:08.146732	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
202	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 119}	{}	1	5	2026-02-26 21:58:08.142114	2026-02-26 21:58:08.142114	2026-02-26 21:58:08.151058	2026-02-26 21:58:08.492137	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
203	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226202912_1"}	{}	1	20	2026-02-26 21:58:31.854515	2026-02-26 21:58:31.854515	2026-02-26 21:58:31.863055	2026-02-26 21:58:31.871295	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
204	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 119}	{}	1	5	2026-02-26 21:58:31.867322	2026-02-26 21:58:31.867322	2026-02-26 21:58:31.875068	2026-02-26 21:58:32.218326	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
205	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226202912_1"}	{}	1	20	2026-02-26 21:58:32.841162	2026-02-26 21:58:32.841162	2026-02-26 21:58:32.850173	2026-02-26 21:58:32.859073	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
207	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226202912_1"}	{}	1	20	2026-02-26 21:58:33.130767	2026-02-26 21:58:33.130767	2026-02-26 21:58:33.140158	2026-02-26 21:58:33.149892	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
206	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 119}	{}	1	5	2026-02-26 21:58:32.854845	2026-02-26 21:58:32.854845	2026-02-26 21:58:32.863074	2026-02-26 21:58:33.20437	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
209	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226202912_1"}	{}	1	20	2026-02-26 21:58:33.336472	2026-02-26 21:58:33.336472	2026-02-26 21:58:33.345135	2026-02-26 21:58:33.354156	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
208	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 119}	{}	1	5	2026-02-26 21:58:33.145994	2026-02-26 21:58:33.145994	2026-02-26 21:58:33.154108	2026-02-26 21:58:33.494359	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
210	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 119}	{}	1	5	2026-02-26 21:58:33.350127	2026-02-26 21:58:33.350127	2026-02-26 21:58:33.35806	2026-02-26 21:58:34.211839	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
211	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226202912_1"}	{}	1	20	2026-02-26 22:02:20.563355	2026-02-26 22:02:20.563355	2026-02-26 22:02:20.572031	2026-02-26 22:02:20.580645	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
212	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 119}	{}	1	5	2026-02-26 22:02:20.576061	2026-02-26 22:02:20.576061	2026-02-26 22:02:20.584093	2026-02-26 22:02:21.461371	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
213	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226202912_1"}	{}	1	20	2026-02-26 22:06:22.243862	2026-02-26 22:06:22.243862	2026-02-26 22:06:22.254099	2026-02-26 22:06:22.265377	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
214	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 119}	{}	1	5	2026-02-26 22:06:22.260402	2026-02-26 22:06:22.260402	2026-02-26 22:06:22.269075	2026-02-26 22:06:23.151081	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
215	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260226202912_1"}	{}	1	20	2026-02-26 22:08:22.019893	2026-02-26 22:08:22.019893	2026-02-26 22:08:22.029065	2026-02-26 22:08:22.036407	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
216	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 119}	{}	1	5	2026-02-26 22:08:22.032558	2026-02-26 22:08:22.032558	2026-02-26 22:08:22.041098	2026-02-26 22:08:22.919017	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
217	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260227044906_1"}	{}	1	20	2026-02-27 04:49:46.068899	2026-02-27 04:49:46.068899	2026-02-27 04:49:46.078145	2026-02-27 04:49:46.0891	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
218	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 120}	{}	1	5	2026-02-27 04:49:46.084003	2026-02-27 04:49:46.084003	2026-02-27 04:49:46.091078	2026-02-27 04:49:47.029263	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
219	completed	tickets	Kabeberi.TicketWorker	{"reference": "20260227053029_1"}	{}	1	20	2026-02-27 05:31:01.244277	2026-02-27 05:31:01.244277	2026-02-27 05:31:01.254093	2026-02-27 05:31:01.264663	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,75a9067e-9c4c-4fd9-abdf-eb91261469f8}	\N	0	{}	{}	\N
220	completed	emails	Kabeberi.EmailWorker	{"ticket_id": 121}	{}	1	5	2026-02-27 05:31:01.260318	2026-02-27 05:31:01.260318	2026-02-27 05:31:01.26808	2026-02-27 05:31:01.658026	{ubuntu-s-8vcpu-16gb-amd-nyc3-01,dc95036a-1cc6-4a3a-8dad-7b8d0f6af880}	\N	0	{}	{}	\N
\.


--
-- Data for Name: oban_peers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oban_peers (name, node, started_at, expires_at) FROM stdin;
Oban	ubuntu-s-8vcpu-16gb-amd-nyc3-01	2026-02-17 05:33:34.014842	2026-03-01 05:48:46.792299
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (version, inserted_at) FROM stdin;
20250321135704	2025-09-29 05:39:29
20250321154524	2025-09-29 05:39:29
20250321154747	2025-09-29 05:39:29
20250323051455	2025-09-29 05:39:29
20250410051746	2025-09-29 05:39:29
20250410052722	2025-09-29 05:39:29
20250410054327	2025-09-29 05:39:29
20250425115441	2025-09-29 05:39:29
20250725161000	2025-09-29 05:39:29
20250725162236	2025-09-29 05:39:29
20250902075622	2025-09-29 05:39:29
20250904174831	2025-09-29 05:39:29
20250904175021	2025-09-29 05:39:29
20250905190024	2025-09-29 05:39:29
20250911184733	2025-09-29 05:39:29
20250924060707	2025-09-29 05:39:29
20250924062008	2025-09-29 05:39:29
20250924063603	2025-09-29 05:39:29
\.


--
-- Data for Name: ticket_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ticket_types (id, name, description, price, is_active, pass_type, admits, is_complimentary, user_id, inserted_at, updated_at, max_scans, is_for_prompt_only) FROM stdin;
1	Advance Ticket	Step into an intimate electronic music experience in Kileleshwa, where The Stageyard brings together DJs who blend high-energy oontz with diverse genres and expressive, atmospheric sounds. \n📅 Date: 27th Feb 2026\n🕑 Time: 2:00 PM – Till dawn\n📍 Venue: Kileleshwa\n💰 Price: KSH 1000	1000	t	\N	1	f	1	2025-09-29 06:00:33	2026-02-17 15:19:37	1	f
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tickets (id, name, phone_number, email, total_price, is_complimentary, is_fully_paid, quantity, ticketid, transaction_id, ticket_type_id, inserted_at, updated_at, purchased_on_site, is_scanned, scan_count, max_scans, is_sent, prompted_by_id) FROM stdin;
108	Linah M.W	0703133357	codercodes01@gmail.com	1000	f	t	1	S19HRG9BVFRDU0duWFEhblhd	20260217163134_1	1	2026-02-17 16:31:34	2026-02-17 16:32:14	f	f	0	1	t	\N
113	Phil	0700537686	wambuguphil@gmail.com	1000	f	t	1	S19HRG9BV1dAVUBtW1MhbllW	20260224204206_1	1	2026-02-24 20:42:06	2026-02-24 20:43:55	f	f	0	1	t	\N
116	Charnnelle	0705881746	daizeeycharnnelle@gmail.com	1000	f	t	1	S19HRG9BV1VDUUZmWFEhbllT	20260226142934_1	1	2026-02-26 14:29:34	2026-02-26 14:30:10	f	f	0	1	t	\N
120	GroovyJo	0708478829	wacuksmunyinyi@gmail.com	1000	f	t	1	S19HRG9BV1RCUUBmW1IhblpV	20260227044906_1	1	2026-02-27 04:49:07	2026-02-27 04:49:46	f	f	0	1	t	\N
18	Brian Mwaniki	0704030900	mwanikibrian5@gmail.com	300	f	f	1	S19HR25DVVJDU0FvWVUhblA	20251001165020_1	1	2025-10-01 16:50:20	2025-11-19 16:28:51	f	t	1	1	t	\N
125	Jeff Miringu	0794529025	miringujeff02@gmail.com	1000	f	t	1	S19HRG9BV1RDUUdnWVIhblpQ	20260227143827_1	1	2026-02-27 14:38:27	2026-02-27 14:40:56	f	f	0	1	t	\N
128	Ian Ohaga	0715221899	ianoohaga7@gmail.com	1000	f	t	1	S19HRG9BV1RDU0VoX10hblpd	20260227161748_1	1	2026-02-27 16:17:48	2026-02-27 16:18:29	f	f	0	1	t	\N
109	Oscar	0715214454	ongoya.it@gmail.com	1000	f	t	1	S19HRG9BVFtCU0VqX10hblhc	20260218061548_1	1	2026-02-18 06:15:48	2026-02-18 06:16:14	f	f	0	1	t	\N
115	Sharon	0705758501	sharonotheraob@gmail.com	1000	f	t	1	S19HRG9BV1ZDXUBqW1chbllQ	20260225184501_1	1	2026-02-25 18:45:02	2026-02-25 18:45:31	f	f	0	1	t	\N
122	Lewin	0719705843	johnlewin12@gmail.com	1000	f	t	1	S19HRG9BV1RCU0duWVQhblpX	20260227063120_1	1	2026-02-27 06:31:21	2026-02-27 06:32:37	f	f	0	1	t	\N
130	James Nganga	0716031534	jamesnight1994@gmail.com	1000	f	t	1	S19HRG9BV1RDXUFnWVIhbltV	20260227185827_1	1	2026-02-27 18:58:27	2026-02-27 18:59:03	f	f	0	1	t	\N
59	Mims	0768460689	waiganjomims@gmail.com	300	f	f	1	S19HR25DVFtDVUZsWFchalE	20251018102331_1	1	2025-10-18 10:23:32	2025-11-19 16:28:51	f	t	1	1	t	\N
82	Felix Maiko	0725911427	maikofelix89@gmail.com	500	f	f	1	S19HR25BVVFDUURnWVAhZ1o	20251202140825_1	1	2025-12-02 14:08:25	2025-12-02 14:09:12	f	f	0	1	t	\N
110	KK	0704905748	kiprotich254@gmail.com	1000	f	t	1	S19HRG9BV1dDVEZnWFMhbllV	20260224112836_1	1	2026-02-24 11:28:36	2026-02-24 11:29:19	f	f	0	1	t	\N
117	Edward	0714253615	edumuhoro@gmail.com	1000	f	f	1	S19HRG9BV1VDU0dtXlIhbllS	20260226163257_1	1	2026-02-26 16:32:57	2026-02-26 16:32:57	f	f	0	1	t	\N
22	Oscar Jr	0715214454	ongoya.it@gmail.com	300	f	f	1	S19HR25DVVBCXEZtWVYhbVo	20251003092223_1	1	2025-10-03 09:22:23	2025-11-19 16:28:51	f	t	1	1	t	\N
8	Bobby	0712664466	bobbykamande@gmail.com	300	f	f	1	S19HR29KV1pDUkVpWVEhZw	20250929171623_1	1	2025-09-29 17:16:24	2025-11-19 16:28:51	f	t	1	1	t	\N
17	John Muthui	0742674478	sanchezjohnte@gmail.com	300	f	f	1	S19HR25DVVJDU0BnWVUhbl8	20251001164820_1	1	2025-10-01 16:48:20	2025-11-19 16:28:51	f	t	1	1	t	\N
5	Basil Oluoch	0796069088	basilooluoch@gmail.com	300	f	f	1	S19HR29KV1pDUEFpW1Yhag	20250929155603_1	1	2025-09-29 15:56:03	2025-09-29 15:56:03	f	f	0	1	t	\N
55	Mims	0768460689	waiganjomims@gmail.com	300	f	f	1	S19HR25DVFtDVUZtWVUhal0	20251018102219_1	1	2025-10-18 10:22:20	2025-10-18 10:22:20	f	f	0	1	t	\N
15	Lewin	0719705843	johnlewin12@gmail.com	300	f	f	1	S19HR25DVVJDVUVoXlchbl0	20251001101752_1	1	2025-10-01 10:17:52	2025-11-19 16:28:51	f	t	1	1	t	\N
2	Grace Muthui	0714299566	graycemuthui20@gmail.com	1	f	f	1	S19HR29KV1pCU0RrW1EhbQ	20250929060403_1	1	2025-09-29 06:04:04	2025-11-19 16:28:51	f	t	1	1	t	\N
4	Nyingi	723264069	nyingidennis@gmail.com	300	f	f	1	S19HR29KV1pDUEFsXlUhaw	20250929155350_1	1	2025-09-29 15:53:50	2025-11-19 16:28:51	f	t	1	1	t	\N
24	Kelvin Enock	0708367015	kelvinenock30@gmail.com	300	f	f	1	S19HR25DVVBDV0BtXlUhbVw	20251003124249_1	1	2025-10-03 12:42:50	2025-11-19 16:28:51	f	t	1	1	t	\N
31	George munge	0704756037	georgemunge95@gmail.com	300	f	f	1	S19HR25DVFJAVkFrW1UhbFk	20251011235359_1	1	2025-10-11 23:54:00	2025-11-19 16:28:51	f	t	1	1	t	\N
9	Devin	0742227999	devinjhanaway@gmail.com	300	f	f	1	S19HR29KV1pDUkduW1AhZg	20250929173105_1	1	2025-09-29 17:31:05	2025-11-19 16:28:51	f	t	1	1	t	\N
3	Linnet Gachanja 	0712445276	wairimugachanja77@gmail.com	300	f	f	1	S19HR29KV1pDUUZmWlAhbA	20250929142915_1	1	2025-09-29 14:29:15	2025-11-19 16:28:51	f	t	1	1	t	\N
11	Sandra 	0112230275	Sandrabuyaki1@gmail.com	300	f	f	1	S19HR29KVlNCU0ZmXlMhblk	20250930062955_1	1	2025-09-30 06:29:56	2025-09-30 06:29:56	f	f	0	1	t	\N
27	Sandra	0112230275	Sandrabuyaki1@gmail.com	300	f	f	1	S19HR25DVVRDVkFnWFQhbV8	20251007135831_1	1	2025-10-07 13:58:31	2025-11-19 16:28:51	f	t	1	1	t	\N
23	Oscar Jr	0715214454	ongoya.it@gmail.com	300	f	f	1	S19HR25DVVBCXEZtWVYhbVs	20251003092223_1	1	2025-10-03 09:22:23	2025-11-19 16:28:51	f	t	1	1	t	\N
21	Rhychi	0729677506	matheka.rm@gmail.com	300	f	f	1	S19HR25DVVBCXEZuWl0hbVk	20251003092118_1	1	2025-10-03 09:21:18	2025-11-19 16:28:51	f	t	1	1	t	\N
13	Amelia James	08074017005	odunright19@gmail.com	300	f	f	1	S19HR25DVVJCUkdnW1Uhbls	20251001073800_1	1	2025-10-01 07:38:00	2025-10-01 07:38:00	f	f	0	1	t	\N
39	Rita Kariuki 	0719782621	ritawangarikariuki@gmail.com	300	f	f	1	S19HR25DVFFDVURpXlAhbFE	20251012100654_1	1	2025-10-12 10:06:55	2025-11-19 16:28:51	f	t	1	1	t	\N
14	Lewin	0719705843	johnlewin12@gmail.com	300	f	f	1	S19HR25DVVJDVUVoWlQhblw	20251001101710_1	1	2025-10-01 10:17:11	2025-10-01 10:17:11	f	f	0	1	t	\N
6	Basil Oluoch	0796069088	basilooluoch@gmail.com	300	f	f	1	S19HR29KV1pDUEFpWFMhaQ	20250929155636_1	1	2025-09-29 15:56:36	2025-11-19 16:28:51	f	t	1	1	t	\N
19	Yvoone Wanjiru Wambui	0746229613	ywanjiru44@gmail.com	300	f	f	1	S19HR25DVVJDU0FoWFAhblE	20251001165734_1	1	2025-10-01 16:57:35	2025-11-19 16:28:51	f	t	1	1	t	\N
36	Martin Kiilu	0707760795	martinkiilu001@gmail.com	300	f	f	1	S19HR25DVFJAVkFoW1QhbF4	20251011235701_1	1	2025-10-11 23:57:01	2025-11-19 16:28:51	f	t	1	1	t	\N
16	John Muthui	0742674478	sanchezjohnte@gmail.com	300	f	f	1	S19HR25DVVJDU0BpXl0hbl4	20251001164658_1	1	2025-10-01 16:46:58	2025-10-01 16:46:58	f	f	0	1	t	\N
35	Martin Kiilu	0707760795	martinkiilu001@gmail.com	300	f	f	1	S19HR25DVFJAVkFoW1QhbF0	20251011235701_1	1	2025-10-11 23:57:01	2025-11-19 16:28:51	f	t	1	1	t	\N
1	Michael Munavu	0740769596	michaelmunavu83@gmail.com	1	f	f	1	S19HR29KV1pCU0RvX1Yhbg	20250929060043_1	1	2025-09-29 06:00:43	2025-11-19 16:28:51	f	f	0	1	t	\N
10	Devin	0742227999	devinjhanaway@gmail.com	300	f	f	1	S19HR29KV1pDUkduW1Ahblg	20250929173105_1	1	2025-09-29 17:31:05	2025-11-19 16:28:51	f	t	1	1	t	\N
40	Evans Kamau 	0794963275	njugunaevanskamau@gmail.com	300	f	f	1	S19HR25DVFBDVEFnXlUha1g	20251013115849_1	1	2025-10-13 11:58:50	2025-11-19 16:28:51	f	t	1	1	t	\N
12	Lee	0703133357	codercodes01@gmail.com	300	f	f	1	S19HR29KVlNDXURtW1Yhblo	20250930180203_1	1	2025-09-30 18:02:03	2025-11-19 16:28:51	f	f	0	1	t	\N
25	Juliet Chelah	0715502777	juliet.kiplimo94@gmail.com	300	f	f	1	S19HR25DVVZDUUdnWlYhbV0	20251005143812_1	1	2025-10-05 14:38:13	2025-11-19 16:28:51	f	f	0	1	t	\N
26	Yvonne Mugure	721175988	mugure644@gmail.com	300	f	f	1	S19HR25DVVZDUERqWFUhbV4	20251005150530_1	1	2025-10-05 15:05:30	2025-11-19 16:28:51	f	f	0	1	t	\N
20	Michael Olang	0768241008	olangmichael37@gmail.com	300	f	f	1	S19HR25DVVFDU0RmW1YhbVg	20251002160902_1	1	2025-10-02 16:09:03	2025-10-02 16:09:03	f	f	0	1	t	\N
29	Eric	0727423942	biofilm_ditches.9r@icloud.com	300	f	f	1	S19HR25DVFNDVEZnX1IhbVE	20251010112846_1	1	2025-10-10 11:28:47	2025-11-19 16:28:51	f	f	0	1	t	\N
30	Phil	0700537686	wambuguphil@gmail.com	300	f	f	1	S19HR25DVFNDUkBoWlchbFg	20251010174712_1	1	2025-10-10 17:47:12	2025-11-19 16:28:51	f	f	0	1	t	\N
32	George munge	0704756037	georgemunge95@gmail.com	300	f	f	1	S19HR25DVFJAVkFrW1UhbFo	20251011235359_1	1	2025-10-11 23:54:00	2025-11-19 16:28:51	f	f	0	1	t	\N
33	Dennis Muoki Muia	0720975260	dennismuia.dm@gmail.com	300	f	f	1	S19HR25DVFJAVkFqWVYhbFs	20251011235523_1	1	2025-10-11 23:55:23	2025-11-19 16:28:51	f	f	0	1	t	\N
34	Chebo 	0707562110	maltymasai@gmail.com	300	f	f	1	S19HR25DVFJAVkFpWFchbFw	20251011235631_1	1	2025-10-11 23:56:32	2025-11-19 16:28:51	f	f	0	1	t	\N
28	Denzel Midambo	0797976257	denzelmidambo@gmail.com	300	f	f	1	S19HR25DVVpAVEVuX1whbVA	20251009211149_1	1	2025-10-09 21:11:49	2025-10-09 21:11:49	f	f	0	1	t	\N
84	Norman	0702235023	normanmondohamaze@gmail.com	500	f	f	1	S19HR25BVVBDVUFqW1chZ1w	20251203105501_1	1	2025-12-03 10:55:02	2025-12-03 10:55:02	f	f	0	1	t	\N
123	Maria	0706513217	kamu.mary@gmail.com	1000	f	t	1	S19HRG9BV1RDUUVrW1chblpW	20260227141402_1	1	2026-02-27 14:14:02	2026-02-27 14:14:29	f	f	0	1	t	\N
111	Rhychi	0729677506	matheka.rm@gmail.com	1000	f	t	1	S19HRG9BV1dDVkRsWVMhbllU	20260224130325_1	1	2026-02-24 13:03:26	2026-02-24 13:03:59	f	f	0	1	t	\N
118	Edward	0714253615	edumuhoro@gmail.com	1000	f	t	1	S19HRG9BV1VDU0dsWVEhblld	20260226163323_1	1	2026-02-26 16:33:24	2026-02-26 16:40:06	f	f	0	1	t	\N
121	Vincent Nyabuto	0713740793	vincenyabuto@gmail.com	1000	f	t	1	S19HRG9BV1RCUEdvWFUhblpU	20260227053029_1	1	2026-02-27 05:30:30	2026-02-27 05:31:01	f	f	0	1	t	\N
124	Jeff Miringu	0794529025	miringujeff02@gmail.com	1000	f	f	1	S19HRG9BV1RDUUVpX1QhblpR	20260227141641_1	1	2026-02-27 14:16:41	2026-02-27 14:16:41	f	f	0	1	t	\N
78	Valerie	0708600090	valeriekiprop@gmail.com	500	f	f	1	S19HR25BVVFCUkZsX1QhaFA	20251202072341_1	1	2025-12-02 07:23:41	2025-12-06 17:21:22	f	t	1	1	t	\N
85	Norman	0702235023	normanmondohamaze@gmail.com	500	f	f	1	S19HR25BVVBDVUFqW1chZ10	20251203105501_1	1	2025-12-03 10:55:02	2025-12-03 10:55:02	f	f	0	1	t	\N
96	Kip	0704905748	anthonykiprop@gmail.com	500	f	f	1	S19HR25BVVVCUUdoWVchZl4	20251206043722_1	1	2025-12-06 04:37:22	2025-12-06 18:29:12	f	t	1	1	t	\N
94	Kip	0704905748	anthonykiprop@gmail.com	500	f	f	1	S19HR25BVVZDVUVuWlwhZlw	20251205101118_1	1	2025-12-05 10:11:19	2025-12-06 18:29:13	f	t	1	1	t	\N
37	Rita Kariuky	0719782621	ritawangarikariuki@gmail.com	300	f	f	1	S19HR25DVFFDVURrWlQhbF8	20251012100410_1	1	2025-10-12 10:04:11	2025-10-12 10:04:11	f	f	0	1	t	\N
86	Norman	0702235023	normanmondohamaze@gmail.com	500	f	f	1	S19HR25BVVBDVUFqWFIhZ14	20251203105536_1	1	2025-12-03 10:55:37	2025-12-03 10:55:56	f	f	0	1	t	\N
87	Norman	0702235023	normanmondohamaze@gmail.com	500	f	f	1	S19HR25BVVBDVUFqWFIhZ18	20251203105536_1	1	2025-12-03 10:55:37	2025-12-03 10:55:56	f	f	0	1	t	\N
38	Rita Kariuki	0719782621	ritawangarikariuki@gmail.com	300	f	f	1	S19HR25DVFFDVURrXlMhbFA	20251012100456_1	1	2025-10-12 10:04:56	2025-10-12 10:04:56	f	f	0	1	t	\N
95	Kip	0704905748	anthonykiprop@gmail.com	500	f	f	1	S19HR25BVVZDVUVuWlwhZl0	20251205101118_1	1	2025-12-05 10:11:19	2025-12-06 18:29:14	f	t	1	1	t	\N
42	Collins Kiprop Korir	0729394730	korir254@gmail.com	300	f	f	1	S19HR25DVFZDV0FpWlwha1o	20251015125618_1	1	2025-10-15 12:56:19	2025-10-15 12:56:19	f	f	0	1	t	\N
68	Stephanie 	0746852020	alekii254@gmail.com	300	f	f	1	S19HR25DVFtDUkVrXlchaVA	20251018171452_1	1	2025-10-18 17:14:52	2025-11-19 16:28:51	f	t	1	1	t	\N
89	Gladys Wairimu Mwangi	724372585	mwangiwairimug@gmail.com	500	f	f	1	S19HR25BVVdDU0BqW1YhZ1E	20251204164502_1	1	2025-12-04 16:45:03	2025-12-06 18:45:44	f	t	1	1	t	\N
90	Gladys Wairimu Mwangi	724372585	mwangiwairimug@gmail.com	500	f	f	1	S19HR25BVVdDU0BqW1YhZlg	20251204164502_1	1	2025-12-04 16:45:03	2025-12-06 18:45:46	f	t	1	1	t	\N
62	Kevin Theuri	0711121906	ktheuri14@gmail.com	300	f	f	1	S19HR25DVFtDVEBtWVchaVo	20251018114222_1	1	2025-10-18 11:42:22	2025-11-19 16:28:51	f	f	0	1	t	\N
7	Basil Oluoch	0796069088	basilooluoch@gmail.com	300	f	f	1	S19HR29KV1pDUEFpWFMhaA	20250929155636_1	1	2025-09-29 15:56:36	2025-11-19 16:28:51	f	t	1	1	t	\N
91	Gladys Wairimu Mwangi	724372585	mwangiwairimug@gmail.com	500	f	f	1	S19HR25BVVdDU0BqW1YhZlk	20251204164502_1	1	2025-12-04 16:45:03	2025-12-06 18:45:48	f	t	1	1	t	\N
51	Sheilla Isaboke	0712930600	sheillaisaboke@gmail.com	300	f	f	1	S19HR25DVFRAVkBpXlIhalk	20251017234656_1	1	2025-10-17 23:46:57	2025-11-19 16:28:51	f	t	1	1	t	\N
72	Bobby	0712664466	bobbykamande@gmail.com	500	f	f	1	S19HR25CV1NDUEZpX1IhaFo	20251120152646_1	1	2025-11-20 15:26:47	2025-12-06 18:28:49	f	t	1	1	t	\N
52	Cyril Michino	0791801660	cyrilmichino@gmail.com	300	f	f	1	S19HR25DVFtCU0ZsW1Ihalo	20251018062306_1	1	2025-10-18 06:23:07	2025-11-19 16:28:51	f	t	1	1	t	\N
54	Mims	0768460689	waiganjomims@gmail.com	300	f	f	1	S19HR25DVFtDVUZtWVUhalw	20251018102219_1	1	2025-10-18 10:22:20	2025-10-18 10:22:20	f	f	0	1	t	\N
75	Oscar Jr	0715214454	ongoya.it@gmail.com	500	f	f	1	S19HR25CV1pDU0ZqWVMhaF0	20251129162525_1	1	2025-11-29 16:25:26	2025-12-06 19:08:32	f	t	1	1	t	\N
56	Mims	0768460689	waiganjomims@gmail.com	300	f	f	1	S19HR25DVFtDVUZtWVUhal4	20251018102219_1	1	2025-10-18 10:22:20	2025-10-18 10:22:20	f	f	0	1	t	\N
76	Oscar Jr	0715214454	ongoya.it@gmail.com	500	f	f	1	S19HR25CV1pDU0ZqWVMhaF4	20251129162525_1	1	2025-11-29 16:25:26	2025-12-06 19:09:49	f	t	1	1	t	\N
64	Vincent 	0713740793	Vincenyabuto@gmail.com	300	f	f	1	S19HR25DVFtDV0FvX1UhaVw	20251018125039_1	1	2025-10-18 12:50:40	2025-11-19 16:28:51	f	t	1	1	t	\N
60	Lilian Muthoni	0719453998	lillianmuthonimaina@gmail.com	300	f	f	1	S19HR25DVFtDVUdsXlUhaVg	20251018103350_1	1	2025-10-18 10:33:50	2025-11-19 16:28:51	f	t	1	1	t	\N
47	Christine kathure 	0790856718	kathurec903@gmail.com	300	f	f	1	S19HR25DVFRCVkVsWFIha18	20251017031336_1	1	2025-10-17 03:13:37	2025-11-19 16:28:51	f	t	1	1	t	\N
70	Brian	0707388134	brayomunyi@gmail.com	500	f	f	1	S19HR25CV1NCU0BuWVYhaFg	20251120064122_1	1	2025-11-20 06:41:23	2025-12-06 19:33:10	f	t	1	1	t	\N
106	Victor 	0717585064	vickalan345@gmail.com	500	f	f	1	S19HR25BVVVDU0FpXlIhblhT	20251206165657_1	1	2025-12-06 16:56:57	2025-12-06 19:33:26	f	t	1	1	t	\N
79	Kioko	0714032347	kiokomulwa85@gmail.com	500	f	f	1	S19HR25BVVFCXUFnWVchaFE	20251202085822_1	1	2025-12-02 08:58:22	2025-12-06 19:54:04	f	t	1	1	t	\N
80	Kioko	0714032347	kiokomulwa85@gmail.com	500	f	f	1	S19HR25BVVFCXUFnWVchZ1g	20251202085822_1	1	2025-12-02 08:58:22	2025-12-06 19:54:09	f	t	1	1	t	\N
46	Maria	0706513217	kamu.mary@gmail.com	300	f	f	1	S19HR25DVFVDXEduWFEha14	20251016193134_1	1	2025-10-16 19:31:34	2025-11-19 16:28:51	f	t	1	1	t	\N
63	Sk	0115551337	simon1kanyingi@gmail.com	300	f	f	1	S19HR25DVFtDVEBnWVYhaVs	20251018114822_1	1	2025-10-18 11:48:23	2025-11-19 16:28:51	f	t	1	1	t	\N
81	Kioko	0714032347	kiokomulwa85@gmail.com	500	f	f	1	S19HR25BVVFCXUFnWVchZ1k	20251202085822_1	1	2025-12-02 08:58:22	2025-12-06 19:54:26	f	t	1	1	t	\N
43	Bryan 	0720882406	koyundibryan@gmail.com	300	f	f	1	S19HR25DVFZDUEdrXlwha1s	20251015153458_1	1	2025-10-15 15:34:59	2025-11-19 16:28:51	f	f	0	1	t	\N
44	Nicole Osanya 	0717328207	koyundibryan@gmail.com	300	f	f	1	S19HR25DVFZDUEBvX1Qha1w	20251015154041_1	1	2025-10-15 15:40:41	2025-11-19 16:28:51	f	f	0	1	t	\N
41	Laban Obiero	0708943263	Labanobiero93@gmail.com	300	f	f	1	S19HR25DVFBAVUduW1cha1k	20251013203102_1	1	2025-10-13 20:31:02	2025-11-19 16:28:51	f	t	1	1	t	\N
53	Zablon 	0703564366	z.okoth92@gmail.com	300	f	f	1	S19HR25DVFtCUkVmWFIhals	20251018071936_1	1	2025-10-18 07:19:37	2025-11-19 16:28:51	f	t	1	1	t	\N
65	Tekla Mutindu	0746131777	natashatekla@gmail.com	300	f	f	1	S19HR25DVFtDUEBsWFAhaV0	20251018154334_1	1	2025-10-18 15:43:35	2025-11-19 16:28:51	f	t	1	1	t	\N
66	Tekla Mutindu	0746131777	natashatekla@gmail.com	300	f	f	1	S19HR25DVFtDUEBsWFAhaV4	20251018154334_1	1	2025-10-18 15:43:35	2025-11-19 16:28:51	f	t	1	1	t	\N
50	Ciru	0113431655	dianaberyl12@gmail.com	300	f	f	1	S19HR25DVFRAVEZoX10halg	20251017212748_1	1	2025-10-17 21:27:48	2025-11-19 16:28:51	f	t	1	1	t	\N
77	Chrisantus william	0790998272	mbuguahmbuguah@gmail.com	500	f	f	1	S19HR25BVVJDXUdtW1YhaF8	20251201183203_1	1	2025-12-01 18:32:03	2025-12-06 16:26:33	f	t	1	1	t	\N
71	Rhychi	0729677506	matheka.rm@gmail.com	500	f	f	1	S19HR25CV1NDVkFtWlAhaFk	20251120135214_1	1	2025-11-20 13:52:15	2025-11-20 13:52:55	f	f	0	1	t	\N
49	Achy	0704213874	wayneachoki5@gmail.com	300	f	f	1	S19HR25DVFRDUkRuW1Iha1E	20251017170106_1	1	2025-10-17 17:01:07	2025-11-19 16:28:51	f	t	1	1	t	\N
67	Stephanie 	0746852020	alekii254@gmail.com	300	f	f	1	S19HR25DVFtDUkVrXlchaV8	20251018171452_1	1	2025-10-18 17:14:52	2025-11-19 16:28:51	f	f	0	1	t	\N
48	Daggie 	254705212848	daggieblanqx@gmail.com	300	f	f	1	S19HR25DVFRCUERsX1Iha1A	20251017050347_1	1	2025-10-17 05:03:47	2025-11-19 16:28:51	f	t	1	1	t	\N
45	Sloan Onderi	0725333612	conoronoc95@gmail.com	300	f	f	1	S19HR25DVFZDUkVrX1Yha10	20251015171443_1	1	2025-10-15 17:14:43	2025-11-19 16:28:51	f	t	1	1	t	\N
61	Dennis Oweke	0114360677	dennisoweke@gmail.com	300	f	f	1	S19HR25DVFtDVERpWVEhaVk	20251018110624_1	1	2025-10-18 11:06:24	2025-11-19 16:28:51	f	f	0	1	t	\N
57	Mims	0768460689	waiganjomims@gmail.com	300	f	f	1	S19HR25DVFtDVUZsWFchal8	20251018102331_1	1	2025-10-18 10:23:32	2025-11-19 16:28:51	f	t	1	1	t	\N
58	Mims	0768460689	waiganjomims@gmail.com	300	f	f	1	S19HR25DVFtDVUZsWFchalA	20251018102331_1	1	2025-10-18 10:23:32	2025-11-19 16:28:51	f	t	1	1	t	\N
73	Lestie Masiga	0710924823	celestemasiga@gmail.com	500	f	f	1	S19HR25CV1JCVkVsX10haFs	20251121031348_1	1	2025-11-21 03:13:48	2025-11-21 03:14:16	f	f	0	1	t	\N
74	Valerie Kiprop	0708600090	valeriekiprop@gmail.com	500	f	f	1	S19HR25CV1pDU0RmWVIhaFw	20251129160921_1	1	2025-11-29 16:09:27	2025-11-29 16:09:27	f	f	0	1	t	\N
69	Brian	0707388134	brayomunyi@gmail.com	500	f	f	1	S19HR25CV1NCU0BuWVYhaVE	20251120064122_1	1	2025-11-20 06:41:23	2025-12-06 16:24:32	f	t	1	1	t	\N
83	Eliud Luutsa 	0700422973	eliudlutsa@gmail.com	500	f	f	1	S19HR25BVVFDUEVmX1AhZ1s	20251202151945_1	1	2025-12-02 15:19:45	2025-12-06 18:24:39	f	t	1	1	t	\N
107	Nyingi	0723264069	nyingidennis@gmail.com	500	f	f	1	S19HR25BVVVDUkRvW1QhblhS	20251206170000_1	1	2025-12-06 17:00:01	2025-12-06 19:26:47	f	t	1	1	t	\N
93	Achsah ❤️🌸	718050477	achsahfedha@gmail.com	500	f	f	1	S19HR25BVVdDUkRpXl0hZls	20251204170657_1	1	2025-12-04 17:06:58	2025-12-06 18:46:24	f	t	1	1	t	\N
100	Kevin mwangq	254701432396	kevinishmael27@gmail.com	500	f	f	1	S19HR25BVVVDV0VtX1AhblhV	20251206121245_1	1	2025-12-06 12:12:45	2025-12-06 18:46:46	f	t	1	1	t	\N
92	Gladys Wairimu Mwangi	724372585	mwangiwairimug@gmail.com	500	f	f	1	S19HR25BVVdDU0BqW1YhZlo	20251204164502_1	1	2025-12-04 16:45:03	2025-12-04 16:45:32	f	f	0	1	t	\N
97	kelvin mbugua	0702158483	kelvinmbuguaw@gmail.com	500	f	f	1	S19HR25BVVVCUkFrWVchZl8	20251206075421_1	1	2025-12-06 07:54:22	2025-12-06 19:19:56	f	t	1	1	t	\N
98	kelvin mbugua	0702158483	kelvinmbuguaw@gmail.com	500	f	f	1	S19HR25BVVVCUkFrWVchZlA	20251206075421_1	1	2025-12-06 07:54:22	2025-12-06 19:19:57	f	t	1	1	t	\N
99	Erick Tshimpe	8013618524	ericktshimpe959@gmail.com	500	f	f	1	S19HR25BVVVCXUdvWlYhZlE	20251206083012_1	1	2025-12-06 08:30:13	2025-12-06 08:30:13	f	f	0	1	t	\N
102	Phil	0700537686	wambuguphil@gmail.com	500	f	f	1	S19HR25BVVVDVkZvWFUhblhX	20251206132030_1	1	2025-12-06 13:20:30	2025-12-06 13:20:56	f	f	0	1	t	\N
88	Sarah 	0795065102	sarahmmutinda@gmail.com	500	f	f	1	S19HR25BVVBAVURmWVwhZ1A	20251203200928_1	1	2025-12-03 20:09:29	2025-12-06 15:51:28	f	t	1	1	t	\N
103	Nyambura Gutettah	0706275633	nyambura4gutettah@gmail.com	500	f	f	1	S19HR25BVVVDU0VmW1AhblhW	20251206161904_1	1	2025-12-06 16:19:05	2025-12-06 16:27:09	f	t	1	1	t	\N
101	Phil	0700537686	wambuguphil@gmail.com	500	f	f	1	S19HR25BVVVDVkZvWFUhblhU	20251206132030_1	1	2025-12-06 13:20:30	2025-12-06 16:35:04	f	t	1	1	t	\N
104	Vince	0713713793	vincenyabuto@gmail.com	500	f	f	1	S19HR25BVVVDU0FrWFchblhR	20251206165432_1	1	2025-12-06 16:54:32	2025-12-06 16:54:32	f	f	0	1	t	\N
105	Vince	0713713793	vincenyabuto@gmail.com	500	f	f	1	S19HR25BVVVDU0FrWFchblhQ	20251206165432_1	1	2025-12-06 16:54:32	2025-12-06 16:54:32	f	f	0	1	t	\N
112	Mbogi ya mashashola	0705758501	sharonotheraob@gmail.com	1000	f	f	1	S19HRG9BV1dDUEZoX1chbllX	20260224152740_1	1	2026-02-24 15:27:42	2026-02-24 15:27:42	f	f	0	1	t	\N
114	k	0712345678	k@c.com	1000	f	f	1	S19HRG9BV1ZDUURpW1EhbllR	20260225140603_1	1	2026-02-25 14:06:04	2026-02-25 14:06:04	f	f	0	1	t	\N
119	Lilian	0714253615	edumuhoro@gmail.com	1000	f	t	1	S19HRG9BV1VAVUZmWlYhbllc	20260226202912_1	1	2026-02-26 20:29:13	2026-02-26 20:29:57	f	f	0	1	t	\N
126	Barake Jeff	0742900269	lightblade254@gmail.com	1000	f	t	1	S19HRG9BV1RDUUBsX1EhblpT	20260227144344_1	1	2026-02-27 14:43:44	2026-02-27 14:46:29	f	f	0	1	t	\N
127	Linnet 	0712445276	linnetgachanja@gmail.com	1000	f	t	1	S19HRG9BV1RDU0RnWVMhblpS	20260227160825_1	1	2026-02-27 16:08:26	2026-02-27 16:08:53	f	f	0	1	t	\N
129	George Itumo	0714980448	gitumo@gmail.com	1000	f	t	1	S19HRG9BV1RDXUFoWVAhblpc	20260227185724_1	1	2026-02-27 18:57:25	2026-02-27 18:58:00	f	f	0	1	t	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, hashed_password, confirmed_at, inserted_at, updated_at, name, is_active, is_admin) FROM stdin;
1	michaelmunavu83@gmail.com	$2b$12$Pfy/45aNQCq3efJMacXdQuAU1tlWtftSS6eGcG1RGXmfiWkjXG4su	\N	2025-09-29 05:39:30	2025-09-29 05:39:30	Michael Munavu	t	t
2	admin@tukutane.live	$2b$12$gT6b85MvPuIqHsMB2zH26u2pOUmVsnPC70FBhnGl0LWft4it5dmXa	\N	2025-09-29 05:39:30	2025-09-29 05:39:30	Michael Munavu	t	t
3	graycemuthui20@gmail.com	$2b$12$qoKmaqp/12wHJtKnRmn3RewyPmiS97h2gMHvKN4RvMLxLbPnvMMre	\N	2025-09-29 13:39:37	2025-09-29 13:40:53	Gee Gee	t	t
\.


--
-- Data for Name: users_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_tokens (id, user_id, token, context, sent_to, inserted_at) FROM stdin;
1	1	\\x6bb2df270010b050e356f2d10f6be50cf4c9a3ea36a34dcd33bcf952d43cebb2	session	\N	2025-09-29 06:00:19
4	3	\\x6d55d7ee706390804713c94e2c064bde3b87bde9d5b96f07a5d5a09e6a45f203	session	\N	2025-09-29 13:50:54
5	3	\\x3613e6aa992c182a7fa15bda2dec9089048721a88b1b7898e0d09357b3a2e407	session	\N	2025-10-10 17:52:22
6	1	\\x5724057cd11ba5171c0319a12830d1d87e2407d692132655dba6e3f003e51fb0	session	\N	2025-10-18 13:04:30
7	1	\\x6c6d490a1ee25802bc06e6b8a7e148c73e2c32bae34184f12c0095562172d6af	session	\N	2025-10-20 09:12:45
8	3	\\xf73f11021cece13e0fd8de3a0cdcf7c7e5ec8010aa3c3606410cf19e94e2314f	session	\N	2025-12-03 13:50:59
9	1	\\xec7621f0199dd8fdbd9d2640a59ebe6a38ca26f515338bc146fd18669c326747	session	\N	2025-12-03 14:10:01
10	3	\\x2930da5ee2be26c7586d2932a6e36908889d6669049237c3731a3c5519d762e1	session	\N	2025-12-03 14:50:15
11	3	\\x9e95f0c99e6151eca834943fdf4b57be1d73bbe6d98c79b0142023c425cd62fa	session	\N	2025-12-06 13:45:14
12	3	\\x72a528b83f008ccff25d1028a9667fad1f8fc824b8e66eeede6795e011e7a2dd	session	\N	2025-12-06 13:45:15
13	3	\\x1899bb4016a5e2e4273b7ed1201696396b2545de7d1e1d8f2703ddd3745a6c95	session	\N	2025-12-06 13:45:16
14	3	\\x80bc9faeb54de8cc252575209e0ffae9e1fc2c0a2f4ebae278f0a46b45864166	session	\N	2025-12-06 17:21:03
15	3	\\x77e412e1d7e231fffa6fbab185eaaa547241c4710f95576d261e1d3cc0eb6d6e	session	\N	2025-12-06 17:24:01
16	3	\\x19dc97a73d8ce661450e4cd5fd33f4c8505cce54b972e37552d7924aa6216bda	session	\N	2025-12-06 18:23:30
17	3	\\xcc692da7e4a9a2f15de8e6a8484733bd877d6887c82207b6cfe8d43d6a5e4afd	session	\N	2025-12-06 20:49:15
18	3	\\x7d1ef6c631c3917036bc1f80f93a1e8f72247ea331c06303000dc5a1882bbda1	session	\N	2026-01-15 08:30:15
19	1	\\xd4faecf3d3e39a42d1722c232d56a26508f7fbe8f7f65c29eb3a256ce670c2f7	session	\N	2026-02-17 05:34:21
20	3	\\x5de791714d7f47d1412af7dae1f766901e7e77c404bb03afcb321b9b7a76770c	session	\N	2026-02-17 12:39:58
21	1	\\x1c2b5e29af0d0020d4643211781256214702b11f4dfabc417d49dd6634ee7362	session	\N	2026-02-17 15:06:44
22	1	\\xa061f9f36f3dcb8d7e42ab3db843d1268dc24611557307958712b051b3e8231e	session	\N	2026-02-27 09:16:00
\.


--
-- Name: finals_ticket_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.finals_ticket_types_id_seq', 1, false);


--
-- Name: finals_tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.finals_tickets_id_seq', 1, false);


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oban_jobs_id_seq', 236, true);


--
-- Name: ticket_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ticket_types_id_seq', 1, true);


--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tickets_id_seq', 130, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- Name: users_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_tokens_id_seq', 22, true);


--
-- Name: finals_ticket_types finals_ticket_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finals_ticket_types
    ADD CONSTRAINT finals_ticket_types_pkey PRIMARY KEY (id);


--
-- Name: finals_tickets finals_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finals_tickets
    ADD CONSTRAINT finals_tickets_pkey PRIMARY KEY (id);


--
-- Name: oban_jobs non_negative_priority; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.oban_jobs
    ADD CONSTRAINT non_negative_priority CHECK ((priority >= 0)) NOT VALID;


--
-- Name: oban_jobs oban_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oban_jobs
    ADD CONSTRAINT oban_jobs_pkey PRIMARY KEY (id);


--
-- Name: oban_peers oban_peers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oban_peers
    ADD CONSTRAINT oban_peers_pkey PRIMARY KEY (name);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: ticket_types ticket_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket_types
    ADD CONSTRAINT ticket_types_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_tokens users_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_pkey PRIMARY KEY (id);


--
-- Name: finals_tickets_finals_ticket_type_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX finals_tickets_finals_ticket_type_id_index ON public.finals_tickets USING btree (finals_ticket_type_id);


--
-- Name: finals_tickets_ticketid_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX finals_tickets_ticketid_index ON public.finals_tickets USING btree (ticketid);


--
-- Name: oban_jobs_args_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oban_jobs_args_index ON public.oban_jobs USING gin (args);


--
-- Name: oban_jobs_meta_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oban_jobs_meta_index ON public.oban_jobs USING gin (meta);


--
-- Name: oban_jobs_state_queue_priority_scheduled_at_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX oban_jobs_state_queue_priority_scheduled_at_id_index ON public.oban_jobs USING btree (state, queue, priority, scheduled_at, id);


--
-- Name: ticket_types_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ticket_types_user_id_index ON public.ticket_types USING btree (user_id);


--
-- Name: tickets_ticket_type_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tickets_ticket_type_id_index ON public.tickets USING btree (ticket_type_id);


--
-- Name: tickets_ticketid_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tickets_ticketid_index ON public.tickets USING btree (ticketid);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_tokens_context_token_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_tokens_context_token_index ON public.users_tokens USING btree (context, token);


--
-- Name: users_tokens_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_tokens_user_id_index ON public.users_tokens USING btree (user_id);


--
-- Name: finals_tickets finals_tickets_finals_ticket_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finals_tickets
    ADD CONSTRAINT finals_tickets_finals_ticket_type_id_fkey FOREIGN KEY (finals_ticket_type_id) REFERENCES public.finals_ticket_types(id);


--
-- Name: ticket_types ticket_types_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket_types
    ADD CONSTRAINT ticket_types_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: tickets tickets_prompted_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_prompted_by_id_fkey FOREIGN KEY (prompted_by_id) REFERENCES public.users(id);


--
-- Name: tickets tickets_ticket_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_ticket_type_id_fkey FOREIGN KEY (ticket_type_id) REFERENCES public.ticket_types(id);


--
-- Name: users_tokens users_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict G4XkiELV25IX0Daoq6WeDXFscjgp7Ef84SQhwHNgJunNahbnQ3RQlAHpCcf2fZP

