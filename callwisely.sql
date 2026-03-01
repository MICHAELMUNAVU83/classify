--
-- PostgreSQL database dump
--

\restrict 6NFYlkt1f4bKy5Da5ERyJvyXplCONYfKLLUZ4vvXzz5RAUSv3Zbb4h5QwpmogPd

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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_usages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ai_usages (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    product_id bigint,
    input_tokens integer DEFAULT 0 NOT NULL,
    output_tokens integer DEFAULT 0 NOT NULL,
    total_tokens integer DEFAULT 0 NOT NULL,
    model character varying(255),
    source character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    cost numeric(12,6) DEFAULT 0
);


ALTER TABLE public.ai_usages OWNER TO postgres;

--
-- Name: ai_usages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ai_usages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ai_usages_id_seq OWNER TO postgres;

--
-- Name: ai_usages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ai_usages_id_seq OWNED BY public.ai_usages.id;


--
-- Name: call_conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.call_conversations (
    id bigint NOT NULL,
    caller character varying(255),
    called character varying(255),
    text text,
    message_type character varying(255),
    call_instance_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    product_id bigint,
    user_id bigint,
    call_analysis jsonb
);


ALTER TABLE public.call_conversations OWNER TO postgres;

--
-- Name: call_conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.call_conversations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.call_conversations_id_seq OWNER TO postgres;

--
-- Name: call_conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.call_conversations_id_seq OWNED BY public.call_conversations.id;


--
-- Name: call_instances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.call_instances (
    id bigint NOT NULL,
    call_sid character varying(255),
    caller character varying(255),
    called character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    product_id bigint,
    user_id bigint,
    call_analysis jsonb,
    inbound_greeting_message text DEFAULT 'Hello, this is {agent_name} from {company_name}. How can I assist you today?'::text
);


ALTER TABLE public.call_instances OWNER TO postgres;

--
-- Name: call_instances_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.call_instances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.call_instances_id_seq OWNER TO postgres;

--
-- Name: call_instances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.call_instances_id_seq OWNED BY public.call_instances.id;


--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_messages (
    id bigint NOT NULL,
    message_id character varying(255) NOT NULL,
    content text NOT NULL,
    message_type character varying(255) NOT NULL,
    sender_name character varying(255),
    sender_id character varying(255),
    metadata jsonb,
    is_read boolean DEFAULT false NOT NULL,
    response_time_seconds double precision,
    chat_session_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.chat_messages OWNER TO postgres;

--
-- Name: chat_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_messages_id_seq OWNER TO postgres;

--
-- Name: chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_messages_id_seq OWNED BY public.chat_messages.id;


--
-- Name: chat_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_sessions (
    id bigint NOT NULL,
    session_id character varying(255) NOT NULL,
    visitor_id character varying(255),
    customer_email character varying(255),
    customer_name character varying(255),
    status character varying(255) DEFAULT 'active'::character varying NOT NULL,
    is_human_takeover boolean DEFAULT false NOT NULL,
    taken_over_at timestamp(0) without time zone,
    taken_over_by character varying(255),
    visitor_info jsonb,
    tags character varying(255)[] DEFAULT ARRAY[]::character varying[],
    priority character varying(255) DEFAULT 'normal'::character varying NOT NULL,
    ended_at timestamp(0) without time zone,
    product_id bigint NOT NULL,
    chatbot_config_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.chat_sessions OWNER TO postgres;

--
-- Name: chat_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_sessions_id_seq OWNER TO postgres;

--
-- Name: chat_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_sessions_id_seq OWNED BY public.chat_sessions.id;


--
-- Name: chatbot_analytics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chatbot_analytics (
    id bigint NOT NULL,
    event_name character varying(255) NOT NULL,
    session_id character varying(255) NOT NULL,
    product_id bigint NOT NULL,
    user_id bigint,
    visitor_id character varying(255),
    url character varying(255),
    referrer character varying(255),
    user_agent text,
    ip_address character varying(255),
    event_data jsonb DEFAULT '{}'::jsonb,
    "timestamp" timestamp(0) without time zone NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.chatbot_analytics OWNER TO postgres;

--
-- Name: chatbot_analytics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chatbot_analytics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chatbot_analytics_id_seq OWNER TO postgres;

--
-- Name: chatbot_analytics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chatbot_analytics_id_seq OWNED BY public.chatbot_analytics.id;


--
-- Name: chatbot_configs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chatbot_configs (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    is_enabled boolean DEFAULT false,
    welcome_message text,
    chatbot_name character varying(255),
    theme character varying(255) DEFAULT 'modern'::character varying,
    primary_color character varying(255) DEFAULT '#105efe'::character varying,
    secondary_color character varying(255) DEFAULT '#051e4f'::character varying,
    widget_position character varying(255) DEFAULT 'bottom-right'::character varying,
    custom_css text,
    send_email_notifications boolean DEFAULT false,
    notification_emails text,
    email_subject_template character varying(255),
    collect_customer_email boolean DEFAULT false,
    response_delay double precision DEFAULT 2.0,
    max_messages_per_session integer DEFAULT 50,
    enable_analytics boolean DEFAULT true,
    offline_message text,
    always_available boolean DEFAULT true,
    business_hours_start time(0) without time zone,
    business_hours_end time(0) without time zone,
    timezone character varying(255) DEFAULT 'UTC'::character varying,
    embed_api_key character varying(255),
    allowed_domains text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.chatbot_configs OWNER TO postgres;

--
-- Name: chatbot_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chatbot_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chatbot_configs_id_seq OWNER TO postgres;

--
-- Name: chatbot_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chatbot_configs_id_seq OWNED BY public.chatbot_configs.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    email character varying(255),
    name character varying(255),
    source character varying(255),
    status character varying(255),
    subscribed_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.contacts OWNER TO postgres;

--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacts_id_seq OWNER TO postgres;

--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: demo_configurations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.demo_configurations (
    id bigint NOT NULL,
    user_phone_number character varying(255) NOT NULL,
    website_url character varying(255),
    custom_context text,
    company_name character varying(255),
    scraped_content text,
    ai_instructions text,
    user_email character varying(255),
    status character varying(255) DEFAULT 'active'::character varying,
    call_sid character varying(255),
    demo_called_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    extracted_analysis jsonb
);


ALTER TABLE public.demo_configurations OWNER TO postgres;

--
-- Name: demo_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.demo_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.demo_configurations_id_seq OWNER TO postgres;

--
-- Name: demo_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.demo_configurations_id_seq OWNED BY public.demo_configurations.id;


--
-- Name: generated_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.generated_documents (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    user_id bigint,
    workflow_execution_id bigint,
    pending_approval_id bigint,
    document_number character varying(255) NOT NULL,
    document_type character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'draft'::character varying NOT NULL,
    title character varying(255),
    content_json jsonb,
    content_html text,
    content_markdown text,
    recipient_name character varying(255),
    recipient_email character varying(255),
    recipient_company character varying(255),
    recipient_phone character varying(255),
    currency character varying(255) DEFAULT 'USD'::character varying,
    subtotal numeric(12,2),
    tax_amount numeric(12,2),
    discount_amount numeric(12,2),
    total_amount numeric(12,2),
    line_items jsonb[] DEFAULT ARRAY[]::jsonb[],
    terms character varying(255)[] DEFAULT ARRAY[]::character varying[],
    notes text,
    personalized_message text,
    valid_from date,
    valid_until date,
    sent_at timestamp(0) without time zone,
    sent_via character varying(255),
    delivery_status character varying(255),
    first_viewed_at timestamp(0) without time zone,
    view_count integer DEFAULT 0,
    last_viewed_at timestamp(0) without time zone,
    responded_at timestamp(0) without time zone,
    response_type character varying(255),
    response_notes text,
    pdf_url character varying(255),
    attachments jsonb[] DEFAULT ARRAY[]::jsonb[],
    conversation_id character varying(255),
    conversation_summary text,
    version integer DEFAULT 1,
    parent_document_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.generated_documents OWNER TO postgres;

--
-- Name: generated_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.generated_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.generated_documents_id_seq OWNER TO postgres;

--
-- Name: generated_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.generated_documents_id_seq OWNED BY public.generated_documents.id;


--
-- Name: information_sources; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.information_sources (
    id bigint NOT NULL,
    type character varying(255),
    source text,
    extracted_analysis jsonb,
    product_id bigint,
    user_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.information_sources OWNER TO postgres;

--
-- Name: information_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.information_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.information_sources_id_seq OWNER TO postgres;

--
-- Name: information_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.information_sources_id_seq OWNED BY public.information_sources.id;


--
-- Name: invitation_workspaces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invitation_workspaces (
    id bigint NOT NULL,
    team_invitation_id bigint NOT NULL,
    product_id bigint NOT NULL,
    role character varying(255) DEFAULT 'member'::character varying NOT NULL,
    inserted_at timestamp with time zone NOT NULL
);


ALTER TABLE public.invitation_workspaces OWNER TO postgres;

--
-- Name: invitation_workspaces_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invitation_workspaces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invitation_workspaces_id_seq OWNER TO postgres;

--
-- Name: invitation_workspaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invitation_workspaces_id_seq OWNED BY public.invitation_workspaces.id;


--
-- Name: pending_approvals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pending_approvals (
    id bigint NOT NULL,
    workflow_id bigint NOT NULL,
    product_id bigint NOT NULL,
    user_id bigint,
    action_type character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    document_type character varying(255),
    document_data jsonb,
    preview_url character varying(255),
    rendered_content text,
    recipient_email character varying(255),
    recipient_name character varying(255),
    recipient_company character varying(255),
    recipient_phone character varying(255),
    conversation_id character varying(255),
    conversation_summary text,
    execution_context jsonb,
    requested_at timestamp(0) without time zone NOT NULL,
    expires_at timestamp(0) without time zone,
    decided_at timestamp(0) without time zone,
    decided_by_id bigint,
    decision_notes text,
    user_edits jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.pending_approvals OWNER TO postgres;

--
-- Name: pending_approvals_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pending_approvals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pending_approvals_id_seq OWNER TO postgres;

--
-- Name: pending_approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pending_approvals_id_seq OWNED BY public.pending_approvals.id;


--
-- Name: product_contexts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_contexts (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    status character varying(255) DEFAULT 'draft'::character varying NOT NULL,
    master_context jsonb DEFAULT '{}'::jsonb NOT NULL,
    custom_overrides jsonb DEFAULT '{}'::jsonb NOT NULL,
    source_metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.product_contexts OWNER TO postgres;

--
-- Name: product_contexts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_contexts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_contexts_id_seq OWNER TO postgres;

--
-- Name: product_contexts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_contexts_id_seq OWNED BY public.product_contexts.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    name character varying(255),
    description character varying(255),
    assigned_phone_number character varying(255),
    user_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    agent_name character varying(255) DEFAULT 'Jane'::character varying,
    outbound_greeting_message text DEFAULT 'Hey, I am {agent_name} from {company_name}. Do you have a few minutes? , I''d love to tell you about how we can help your business.'::text,
    call_handling_instructions text DEFAULT 'Answer the phone professionally and be helpful. If the customer has questions, provide accurate information from the knowledge base.'::text,
    voice character varying(255) DEFAULT 'Polly.Joanna-Neural'::character varying,
    inbound_greeting_message text DEFAULT 'Hello, this is {agent_name} from {company_name}. How can I assist you today?'::text,
    chatbot_greeting_message character varying(255) DEFAULT 'Hi, I''m {agent_name} from {company_name}. How can I help you today?'::character varying
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: team_invitations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team_invitations (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    invited_by_id bigint NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    accepted_at timestamp with time zone,
    inserted_at timestamp with time zone NOT NULL
);


ALTER TABLE public.team_invitations OWNER TO postgres;

--
-- Name: team_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.team_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.team_invitations_id_seq OWNER TO postgres;

--
-- Name: team_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.team_invitations_id_seq OWNED BY public.team_invitations.id;


--
-- Name: user_notification_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_notification_settings (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    notify_new_conversation boolean DEFAULT false NOT NULL,
    notify_document_generated boolean DEFAULT false NOT NULL,
    notify_pending_approval boolean DEFAULT false NOT NULL,
    emails character varying(255)[] DEFAULT ARRAY[]::character varying[] NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    product_id bigint NOT NULL
);


ALTER TABLE public.user_notification_settings OWNER TO postgres;

--
-- Name: user_notification_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_notification_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_notification_settings_id_seq OWNER TO postgres;

--
-- Name: user_notification_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_notification_settings_id_seq OWNED BY public.user_notification_settings.id;


--
-- Name: user_workflows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_workflows (
    id bigint NOT NULL,
    name character varying(255),
    description text,
    is_active boolean DEFAULT false NOT NULL,
    user_id bigint,
    product_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    trigger_type character varying(255) NOT NULL,
    trigger_config jsonb DEFAULT '{}'::jsonb,
    conditions jsonb[] DEFAULT ARRAY[]::jsonb[],
    actions jsonb[] DEFAULT ARRAY[]::jsonb[],
    priority integer DEFAULT 50,
    requires_approval boolean DEFAULT false,
    approval_config jsonb DEFAULT '{}'::jsonb,
    execution_count integer DEFAULT 0,
    last_executed_at timestamp(0) without time zone,
    success_rate double precision DEFAULT 0.0,
    template_id character varying(255),
    template_version character varying(255)
);


ALTER TABLE public.user_workflows OWNER TO postgres;

--
-- Name: user_workflows_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_workflows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_workflows_id_seq OWNER TO postgres;

--
-- Name: user_workflows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_workflows_id_seq OWNED BY public.user_workflows.id;


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
    first_name character varying(255),
    last_name character varying(255),
    last_logged_in_at timestamp(0) without time zone,
    last_logged_out_at timestamp(0) without time zone,
    invited_by_id integer
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
-- Name: workflow_executions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_executions (
    id bigint NOT NULL,
    workflow_id bigint NOT NULL,
    product_id bigint NOT NULL,
    user_id bigint,
    conversation_id character varying(255),
    call_type character varying(255),
    status character varying(255) DEFAULT 'started'::character varying NOT NULL,
    trigger_data jsonb,
    execution_log jsonb[] DEFAULT ARRAY[]::jsonb[],
    result jsonb,
    error text,
    error_details jsonb,
    started_at timestamp(0) without time zone NOT NULL,
    completed_at timestamp(0) without time zone,
    duration_ms integer,
    pending_approval_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.workflow_executions OWNER TO postgres;

--
-- Name: workflow_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workflow_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workflow_executions_id_seq OWNER TO postgres;

--
-- Name: workflow_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workflow_executions_id_seq OWNED BY public.workflow_executions.id;


--
-- Name: workflow_tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_tasks (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    user_id bigint,
    workflow_execution_id bigint,
    workflow_id bigint,
    conversation_id character varying(255),
    title character varying(255) NOT NULL,
    description text,
    status character varying(255) DEFAULT 'open'::character varying NOT NULL,
    priority character varying(255) DEFAULT 'medium'::character varying NOT NULL,
    due_at timestamp(0) without time zone,
    completed_at timestamp(0) without time zone,
    metadata jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.workflow_tasks OWNER TO postgres;

--
-- Name: workflow_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workflow_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workflow_tasks_id_seq OWNER TO postgres;

--
-- Name: workflow_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workflow_tasks_id_seq OWNED BY public.workflow_tasks.id;


--
-- Name: workflow_templates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_templates (
    id bigint NOT NULL,
    template_id character varying(255) NOT NULL,
    version character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    category character varying(255),
    tags character varying(255)[] DEFAULT ARRAY[]::character varying[],
    trigger_type character varying(255) NOT NULL,
    trigger_config jsonb DEFAULT '{}'::jsonb,
    conditions jsonb[] DEFAULT ARRAY[]::jsonb[],
    actions jsonb[] DEFAULT ARRAY[]::jsonb[],
    requires_approval boolean DEFAULT false,
    approval_config jsonb DEFAULT '{}'::jsonb,
    icon character varying(255),
    color character varying(255),
    difficulty character varying(255),
    estimated_setup_time character varying(255),
    required_context character varying(255)[] DEFAULT ARRAY[]::character varying[],
    usage_count integer DEFAULT 0,
    avg_success_rate double precision DEFAULT 0.0,
    is_active boolean DEFAULT true,
    is_featured boolean DEFAULT false,
    is_system boolean DEFAULT true,
    created_by bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.workflow_templates OWNER TO postgres;

--
-- Name: workflow_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workflow_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workflow_templates_id_seq OWNER TO postgres;

--
-- Name: workflow_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workflow_templates_id_seq OWNED BY public.workflow_templates.id;


--
-- Name: workspace_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workspace_members (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    product_id bigint NOT NULL,
    role character varying(255) DEFAULT 'member'::character varying NOT NULL,
    invited_by_id bigint,
    inserted_at timestamp with time zone NOT NULL
);


ALTER TABLE public.workspace_members OWNER TO postgres;

--
-- Name: workspace_members_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workspace_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workspace_members_id_seq OWNER TO postgres;

--
-- Name: workspace_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workspace_members_id_seq OWNED BY public.workspace_members.id;


--
-- Name: ai_usages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_usages ALTER COLUMN id SET DEFAULT nextval('public.ai_usages_id_seq'::regclass);


--
-- Name: call_conversations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.call_conversations ALTER COLUMN id SET DEFAULT nextval('public.call_conversations_id_seq'::regclass);


--
-- Name: call_instances id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.call_instances ALTER COLUMN id SET DEFAULT nextval('public.call_instances_id_seq'::regclass);


--
-- Name: chat_messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages ALTER COLUMN id SET DEFAULT nextval('public.chat_messages_id_seq'::regclass);


--
-- Name: chat_sessions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_sessions ALTER COLUMN id SET DEFAULT nextval('public.chat_sessions_id_seq'::regclass);


--
-- Name: chatbot_analytics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbot_analytics ALTER COLUMN id SET DEFAULT nextval('public.chatbot_analytics_id_seq'::regclass);


--
-- Name: chatbot_configs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbot_configs ALTER COLUMN id SET DEFAULT nextval('public.chatbot_configs_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: demo_configurations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.demo_configurations ALTER COLUMN id SET DEFAULT nextval('public.demo_configurations_id_seq'::regclass);


--
-- Name: generated_documents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_documents ALTER COLUMN id SET DEFAULT nextval('public.generated_documents_id_seq'::regclass);


--
-- Name: information_sources id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.information_sources ALTER COLUMN id SET DEFAULT nextval('public.information_sources_id_seq'::regclass);


--
-- Name: invitation_workspaces id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitation_workspaces ALTER COLUMN id SET DEFAULT nextval('public.invitation_workspaces_id_seq'::regclass);


--
-- Name: pending_approvals id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pending_approvals ALTER COLUMN id SET DEFAULT nextval('public.pending_approvals_id_seq'::regclass);


--
-- Name: product_contexts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_contexts ALTER COLUMN id SET DEFAULT nextval('public.product_contexts_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: team_invitations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_invitations ALTER COLUMN id SET DEFAULT nextval('public.team_invitations_id_seq'::regclass);


--
-- Name: user_notification_settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_notification_settings ALTER COLUMN id SET DEFAULT nextval('public.user_notification_settings_id_seq'::regclass);


--
-- Name: user_workflows id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_workflows ALTER COLUMN id SET DEFAULT nextval('public.user_workflows_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_tokens ALTER COLUMN id SET DEFAULT nextval('public.users_tokens_id_seq'::regclass);


--
-- Name: workflow_executions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_executions ALTER COLUMN id SET DEFAULT nextval('public.workflow_executions_id_seq'::regclass);


--
-- Name: workflow_tasks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_tasks ALTER COLUMN id SET DEFAULT nextval('public.workflow_tasks_id_seq'::regclass);


--
-- Name: workflow_templates id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_templates ALTER COLUMN id SET DEFAULT nextval('public.workflow_templates_id_seq'::regclass);


--
-- Name: workspace_members id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspace_members ALTER COLUMN id SET DEFAULT nextval('public.workspace_members_id_seq'::regclass);


--
-- Data for Name: ai_usages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ai_usages (id, user_id, product_id, input_tokens, output_tokens, total_tokens, model, source, inserted_at, updated_at, cost) FROM stdin;
1	1	1	1541	49	1590	gpt-4o-mini	chatbot	2026-02-19 12:38:50	2026-02-19 12:38:50	0.000261
2	1	1	1555	54	1609	gpt-4o-mini	chatbot	2026-02-19 12:41:37	2026-02-19 12:41:37	0.000266
3	1	1	1642	64	1706	gpt-4o-mini	chatbot	2026-02-19 12:42:08	2026-02-19 12:42:08	0.000285
4	1	1	1535	35	1570	gpt-4o-mini	chatbot	2026-02-19 12:44:13	2026-02-19 12:44:13	0.000251
5	2	2	1758	89	1847	gpt-4o-mini	chatbot	2026-02-19 13:30:21	2026-02-19 13:30:21	0.000317
6	2	2	1748	33	1781	gpt-4o-mini	chatbot	2026-02-19 13:31:28	2026-02-19 13:31:28	0.000282
7	2	2	1792	89	1881	gpt-4o-mini	chatbot	2026-02-19 13:31:40	2026-02-19 13:31:40	0.000322
8	1	1	1535	37	1572	gpt-4o-mini	chatbot	2026-02-27 07:52:28	2026-02-27 07:52:28	0.000252
9	1	1	1582	67	1649	gpt-4o-mini	chatbot	2026-02-27 07:52:45	2026-02-27 07:52:45	0.000277
10	1	1	1533	40	1573	gpt-4o-mini	chatbot	2026-02-27 07:53:55	2026-02-27 07:53:55	0.000254
\.


--
-- Data for Name: call_conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.call_conversations (id, caller, called, text, message_type, call_instance_id, inserted_at, updated_at, product_id, user_id, call_analysis) FROM stdin;
\.


--
-- Data for Name: call_instances; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.call_instances (id, call_sid, caller, called, inserted_at, updated_at, product_id, user_id, call_analysis, inbound_greeting_message) FROM stdin;
\.


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_messages (id, message_id, content, message_type, sender_name, sender_id, metadata, is_read, response_time_seconds, chat_session_id, inserted_at, updated_at) FROM stdin;
1	msg_b034d430a06f1514	Where are your offices	user	Visitor	\N	{}	f	\N	4	2026-02-19 12:38:48	2026-02-19 12:38:48
2	msg_dac922cc49d5d5e3	Hi there! Our offices are located at the 5th Floor, Room number 39, Nextgen Mall, Mombasa Road, Nairobi, Kenya. If you need any further assistance or have more questions, feel free to ask! 😊	bot	AI Assistant	\N	{}	f	\N	4	2026-02-19 12:38:50	2026-02-19 12:38:50
3	msg_a6a4c600f44c1e82	Suzie has joined the conversation and will assist you from here.	system	System	\N	{}	f	\N	4	2026-02-19 12:39:32	2026-02-19 12:39:32
4	msg_83109ef4604a712c	We are not open because of ramadan	agent	\N	\N	{"agent_id": 1}	f	\N	4	2026-02-19 12:39:46	2026-02-19 12:39:46
5	msg_78b6b48eac3882c3	Hey , I need a book a meeting with the CEO	user	Visitor	\N	{}	f	\N	5	2026-02-19 12:41:35	2026-02-19 12:41:35
6	msg_3ecf0ac4ef0dc448	Hi there! I'd be happy to help you set up a meeting with the CEO. Could you please provide me with your full name, email address, and your preferred date and time for the meeting? Once I have that information, I'll confirm the details for you! 😊	bot	AI Assistant	\N	{}	f	\N	5	2026-02-19 12:41:37	2026-02-19 12:41:37
7	msg_a92f4864f3ee0d27	Michael , michaelmunavu83@gmail.com. , 19th Feb at 5pm	user	Visitor	\N	{}	f	\N	5	2026-02-19 12:42:06	2026-02-19 12:42:06
8	msg_7bf2732c3f84d05f	Great, Michael! I've got you down for a meeting with the CEO on February 19th at 5 PM. Just to confirm, your email is michaelmunavu83@gmail.com. If you need to make any changes or have any questions before then, feel free to reach out. Looking forward to it! 😊	bot	AI Assistant	\N	{}	f	\N	5	2026-02-19 12:42:08	2026-02-19 12:42:08
9	msg_69b667011b7e699f	Hey	user	Visitor	\N	{}	f	\N	6	2026-02-19 12:44:11	2026-02-19 12:44:11
10	msg_12f787e403b80087	Hi there! 😊 What can I assist you with today? If you have any questions about our services, membership, or anything else, feel free to ask!	bot	AI Assistant	\N	{}	f	\N	6	2026-02-19 12:44:13	2026-02-19 12:44:13
11	msg_2ef2584600e25b71	Hello, what is GS1	user	Visitor	\N	{}	f	\N	7	2026-02-19 13:30:17	2026-02-19 13:30:17
12	msg_e6b94bb4b8739064	Hi there! GS1 is a global organization that develops and maintains standards for business communication, particularly in supply chain management. At GS1 Kenya, we focus on improving supply chain efficiency through services like training, consultancy, and membership, helping businesses with traceability, data management, and product identification. Our mission is to enhance the visibility and efficiency of supply chains. If you have any specific questions or need more information, feel free to ask! 😊	bot	AI Assistant	\N	{}	f	\N	7	2026-02-19 13:30:21	2026-02-19 13:30:21
13	msg_a844e761a76059eb	hey	user	Visitor	\N	{}	f	\N	8	2026-02-19 13:31:26	2026-02-19 13:31:26
14	msg_605f95e114894a74	Hi there! 😊 How's your day going? Is there something specific you'd like to know about our services or any questions I can help you with?	bot	AI Assistant	\N	{}	f	\N	8	2026-02-19 13:31:28	2026-02-19 13:31:28
15	msg_871c44102e096794	what is gs1	user	Visitor	\N	{}	f	\N	8	2026-02-19 13:31:38	2026-02-19 13:31:38
16	msg_9ef68405f43b9de9	GS1 is a global organization that develops and maintains standards for business communication, particularly in supply chain management. At GS1 Kenya, we focus on improving supply chain efficiency through services like training, consultancy, and membership, helping businesses with traceability, data management, and product identification. Our mission is to enhance the efficiency and visibility of supply chains using these global standards. If you have more questions or need specific information, feel free to ask! 😊	bot	AI Assistant	\N	{}	f	\N	8	2026-02-19 13:31:40	2026-02-19 13:31:40
17	msg_eca09d9cd809fa8e	Munavu	user	Visitor	\N	{}	f	\N	9	2026-02-27 07:52:26	2026-02-27 07:52:26
18	msg_c332693076c9c4ee	Hi Munavu! Thanks for reaching out. How can I assist you today? If you have any questions about our services, membership, or anything else, feel free to ask! 😊	bot	AI Assistant	\N	{}	f	\N	9	2026-02-27 07:52:28	2026-02-27 07:52:28
19	msg_e8cd233d46cbed31	What's this	user	Visitor	\N	{}	f	\N	9	2026-02-27 07:52:43	2026-02-27 07:52:43
20	msg_39a50a10c7220c2e	Hi Munavu! 😊 This is GS1 Kenya, where we provide standards and solutions to enhance efficiency in supply chains and business communication. We focus on traceability, data management, and barcoding to help businesses optimize their operations. If you have specific questions about our services or how we can assist your business, just let me know!	bot	AI Assistant	\N	{}	f	\N	9	2026-02-27 07:52:45	2026-02-27 07:52:45
21	msg_5af541c04a2ef9c1	Hey	user	Visitor	\N	{}	f	\N	10	2026-02-27 07:53:52	2026-02-27 07:53:52
22	msg_32017d1d921cafd8	Hi there! It's great to hear from you. How can I assist you today? Whether you have questions about our services, membership, or anything else, I'm here to help! 😊	bot	AI Assistant	\N	{}	f	\N	10	2026-02-27 07:53:55	2026-02-27 07:53:55
\.


--
-- Data for Name: chat_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_sessions (id, session_id, visitor_id, customer_email, customer_name, status, is_human_takeover, taken_over_at, taken_over_by, visitor_info, tags, priority, ended_at, product_id, chatbot_config_id, inserted_at, updated_at) FROM stdin;
4	cht_nwo9918vlmltg5skt	\N	\N	\N	handed_over	t	2026-02-19 12:39:32	Suzie	{"ip": "127.0.0.1", "referrer": "http://127.0.0.1:5501/", "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36"}	{}	normal	\N	1	\N	2026-02-19 12:38:48	2026-02-19 12:39:32
5	cht_kllyak5xhmltg9ies	\N	\N	\N	active	f	\N	\N	{"ip": "127.0.0.1", "referrer": "http://127.0.0.1:5501/", "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36"}	{}	normal	\N	1	\N	2026-02-19 12:41:35	2026-02-19 12:41:35
6	cht_nkf7ys8u0mltgcmp3	\N	\N	\N	active	f	\N	\N	{"ip": "127.0.0.1", "referrer": "http://127.0.0.1:5501/", "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36"}	{}	normal	\N	1	\N	2026-02-19 12:44:11	2026-02-19 12:44:11
7	cht_heg5iu3m1mlti00qk	\N	\N	\N	active	f	\N	\N	{"ip": "127.0.0.1", "referrer": "https://gs1kenya.org/", "user_agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0"}	{}	normal	\N	2	\N	2026-02-19 13:30:17	2026-02-19 13:30:17
8	cht_0s4mvy5g5mlti1y9a	\N	\N	\N	active	f	\N	\N	{"ip": "127.0.0.1", "referrer": "https://gs1kenya.org/", "user_agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0"}	{}	normal	\N	2	\N	2026-02-19 13:31:26	2026-02-19 13:31:26
9	cht_ms2170q83mm4lgn97	\N	\N	\N	active	f	\N	\N	{"ip": "127.0.0.1", "referrer": "https://www.michaelmunavu.com/", "user_agent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36"}	{}	normal	\N	1	\N	2026-02-27 07:52:25	2026-02-27 07:52:25
10	cht_80qwszymzmm4liib4	\N	\N	\N	active	f	\N	\N	{"ip": "127.0.0.1", "referrer": "https://www.michaelmunavu.com/", "user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/135.0.7049.53 Mobile/15E148 Safari/604.1"}	{}	normal	\N	1	\N	2026-02-27 07:53:52	2026-02-27 07:53:52
\.


--
-- Data for Name: chatbot_analytics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chatbot_analytics (id, event_name, session_id, product_id, user_id, visitor_id, url, referrer, user_agent, ip_address, event_data, "timestamp", inserted_at, updated_at) FROM stdin;
74	widget_loaded	cht_nwo9918vlmltg5skt	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://127.0.0.1:5501/index.html", "referrer": ""}	2026-02-19 12:38:23	2026-02-19 12:38:25	2026-02-19 12:38:25
87	widget_loaded	cht_kllyak5xhmltg9ies	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://127.0.0.1:5501/index.html", "referrer": ""}	2026-02-19 12:41:17	2026-02-19 12:41:17	2026-02-19 12:41:17
84	human_takeover_started	cht_nwo9918vlmltg5skt	1	\N	\N	\N	\N	\N	\N	{"agent_id": 1, "agent_name": "Suzie", "session_status": "handed_over"}	2026-02-19 12:39:32	2026-02-19 12:39:32	2026-02-19 12:39:32
95	message_sent	cht_nkf7ys8u0mltgcmp3	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"has_email": false, "message_count": 1, "message_length": 3, "session_duration_seconds": 28}	2026-02-19 12:44:10	2026-02-19 12:44:11	2026-02-19 12:44:11
105	message_received	cht_0s4mvy5g5mlti1y9a	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"response_time": 2000, "human_takeover": false, "response_length": 138}	2026-02-19 13:31:32	2026-02-19 13:31:32	2026-02-19 13:31:32
76	chat_opened	cht_nwo9918vlmltg5skt	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"has_email": false, "messages_count": 1}	2026-02-19 12:38:33	2026-02-19 12:38:34	2026-02-19 12:38:34
81	message_sent	cht_nwo9918vlmltg5skt	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"has_email": false, "message_count": 1, "message_length": 22, "session_duration_seconds": 24}	2026-02-19 12:38:46	2026-02-19 12:38:47	2026-02-19 12:38:47
83	human_takeover_started	cht_nwo9918vlmltg5skt	1	\N	\N	\N	\N	\N	\N	{"agent_id": 1, "agent_name": "Suzie", "takeover_time": "2026-02-19T12:39:32.435936Z"}	2026-02-19 12:39:32	2026-02-19 12:39:32	2026-02-19 12:39:32
85	message_sent	cht_nwo9918vlmltg5skt	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"has_email": false, "message_count": 2, "message_length": 48, "session_duration_seconds": 153}	2026-02-19 12:40:56	2026-02-19 12:40:57	2026-02-19 12:40:57
86	message_received	cht_nwo9918vlmltg5skt	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"response_time": 2000, "human_takeover": true, "response_length": 0}	2026-02-19 12:40:59	2026-02-19 12:40:59	2026-02-19 12:40:59
88	chat_opened	cht_kllyak5xhmltg9ies	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"has_email": false, "messages_count": 1}	2026-02-19 12:41:23	2026-02-19 12:41:24	2026-02-19 12:41:24
91	message_sent	cht_kllyak5xhmltg9ies	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"has_email": false, "message_count": 2, "message_length": 54, "session_duration_seconds": 50}	2026-02-19 12:42:05	2026-02-19 12:42:06	2026-02-19 12:42:06
98	widget_loaded	cht_heg5iu3m1mlti00qk	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/crm_dashboard"}	2026-02-19 13:29:53	2026-02-19 13:29:53	2026-02-19 13:29:53
99	chat_opened	cht_heg5iu3m1mlti00qk	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"has_email": false, "messages_count": 1}	2026-02-19 13:29:56	2026-02-19 13:29:56	2026-02-19 13:29:56
102	widget_loaded	cht_0s4mvy5g5mlti1y9a	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/crm_dashboard"}	2026-02-19 13:31:22	2026-02-19 13:31:22	2026-02-19 13:31:22
106	message_sent	cht_0s4mvy5g5mlti1y9a	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"has_email": false, "message_count": 2, "message_length": 11, "session_duration_seconds": 15}	2026-02-19 13:31:38	2026-02-19 13:31:38	2026-02-19 13:31:38
110	widget_loaded	cht_zrycfhm7bmltydm0o	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-19 21:08:20	2026-02-19 21:08:20	2026-02-19 21:08:20
112	widget_loaded	cht_288y12u3emlufm865	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-20 05:10:56	2026-02-20 05:10:56	2026-02-20 05:10:56
113	widget_loaded	cht_ftrd97t6amlug6i5s	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-20 05:26:43	2026-02-20 05:26:42	2026-02-20 05:26:42
82	message_received	cht_nwo9918vlmltg5skt	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"response_time": 2000, "human_takeover": false, "response_length": 191}	2026-02-19 12:38:52	2026-02-19 12:38:52	2026-02-19 12:38:52
89	message_sent	cht_kllyak5xhmltg9ies	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"has_email": false, "message_count": 1, "message_length": 42, "session_duration_seconds": 18}	2026-02-19 12:41:34	2026-02-19 12:41:35	2026-02-19 12:41:35
96	message_received	cht_nkf7ys8u0mltgcmp3	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"response_time": 2000, "human_takeover": false, "response_length": 140}	2026-02-19 12:44:15	2026-02-19 12:44:16	2026-02-19 12:44:16
101	message_received	cht_heg5iu3m1mlti00qk	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"response_time": 2000, "human_takeover": false, "response_length": 505}	2026-02-19 13:30:24	2026-02-19 13:30:24	2026-02-19 13:30:24
104	message_sent	cht_0s4mvy5g5mlti1y9a	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"has_email": false, "message_count": 1, "message_length": 3, "session_duration_seconds": 4}	2026-02-19 13:31:26	2026-02-19 13:31:26	2026-02-19 13:31:26
108	widget_loaded	cht_dg5um64i1mltlhmbd	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-19 15:07:34	2026-02-19 15:07:34	2026-02-19 15:07:34
111	widget_loaded	cht_uxgmxvwcqmluf3rr3	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-20 04:56:35	2026-02-20 04:56:36	2026-02-20 04:56:36
115	widget_loaded	cht_xzlbjl67pmlugadx2	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-20 05:29:43	2026-02-20 05:29:44	2026-02-20 05:29:44
90	message_received	cht_kllyak5xhmltg9ies	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"response_time": 2000, "human_takeover": false, "response_length": 246}	2026-02-19 12:41:39	2026-02-19 12:41:39	2026-02-19 12:41:39
103	chat_opened	cht_0s4mvy5g5mlti1y9a	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"has_email": false, "messages_count": 1}	2026-02-19 13:31:24	2026-02-19 13:31:24	2026-02-19 13:31:24
92	message_received	cht_kllyak5xhmltg9ies	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"response_time": 2000, "human_takeover": false, "response_length": 261}	2026-02-19 12:42:10	2026-02-19 12:42:11	2026-02-19 12:42:11
93	widget_loaded	cht_nkf7ys8u0mltgcmp3	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://127.0.0.1:5501/index.html", "referrer": ""}	2026-02-19 12:43:43	2026-02-19 12:43:43	2026-02-19 12:43:43
94	chat_opened	cht_nkf7ys8u0mltgcmp3	1	\N	\N	http://127.0.0.1:5501/index.html	http://127.0.0.1:5501/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"has_email": false, "messages_count": 1}	2026-02-19 12:44:06	2026-02-19 12:44:07	2026-02-19 12:44:07
114	widget_loaded	cht_x4uxwrvmtmlug6v3r	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-20 05:26:59	2026-02-20 05:27:00	2026-02-20 05:27:00
100	message_sent	cht_heg5iu3m1mlti00qk	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"has_email": false, "message_count": 1, "message_length": 18, "session_duration_seconds": 25}	2026-02-19 13:30:17	2026-02-19 13:30:17	2026-02-19 13:30:17
107	message_received	cht_0s4mvy5g5mlti1y9a	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"response_time": 2000, "human_takeover": false, "response_length": 520}	2026-02-19 13:31:43	2026-02-19 13:31:43	2026-02-19 13:31:43
109	widget_loaded	cht_aihgh70skmltlt2gz	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-19 15:16:27	2026-02-19 15:16:28	2026-02-19 15:16:28
117	widget_loaded	cht_rjkg7x7a2mlui59wp	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-20 06:21:44	2026-02-20 06:21:45	2026-02-20 06:21:45
118	widget_loaded	cht_p71k2c379mluihvne	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-20 06:31:33	2026-02-20 06:31:33	2026-02-20 06:31:33
119	chat_closed	cht_0s4mvy5g5mlti1y9a	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"user_messages": 2, "messages_exchanged": 5, "session_duration_seconds": 61637}	2026-02-20 06:38:40	2026-02-20 06:38:41	2026-02-20 06:38:41
120	widget_loaded	cht_vn29mj7r0mlujar7r	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-20 06:54:00	2026-02-20 06:53:59	2026-02-20 06:53:59
121	widget_loaded	cht_e1jugzpermlulkmor	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-20 07:57:39	2026-02-20 07:57:40	2026-02-20 07:57:40
122	widget_loaded	cht_ip978kcs5mlulzjnr	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-20 08:09:16	2026-02-20 08:09:17	2026-02-20 08:09:17
123	widget_loaded	cht_gj2rmf1remlum0pjq	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-20 08:10:10	2026-02-20 08:10:10	2026-02-20 08:10:10
124	widget_loaded	cht_zv83vd50imlun2f9p	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-20 08:39:29	2026-02-20 08:39:30	2026-02-20 08:39:30
125	widget_loaded	cht_yaupqk593mluobc95	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-20 09:14:25	2026-02-20 09:14:26	2026-02-20 09:14:26
126	widget_loaded	cht_rh158uf4xmlup4bkq	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.google.com/"}	2026-02-20 09:36:57	2026-02-20 09:36:57	2026-02-20 09:36:57
127	widget_loaded	cht_aqka86j8dmlupec85	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-20 09:44:49	2026-02-20 09:44:50	2026-02-20 09:44:50
128	widget_loaded	cht_qxsv7dreqmluphnfk	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-20 09:47:19	2026-02-20 09:47:20	2026-02-20 09:47:20
129	widget_loaded	cht_highcwdzbmlurbgfv	1	\N	\N	https://www.michaelmunavu.com/	\N	Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/136.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-20 10:38:28	2026-02-20 10:38:29	2026-02-20 10:38:29
130	widget_loaded	cht_ewbug1wk1mlu4idcr	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7559.132 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-20 00:00:00	2026-02-20 11:43:13	2026-02-20 11:43:13
131	widget_loaded	cht_yyk5k6op0mluugy2j	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-20 12:06:43	2026-02-20 12:06:43	2026-02-20 12:06:43
132	widget_loaded	cht_8eb0tapcxmluv2v9t	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-20 12:23:48	2026-02-20 12:23:51	2026-02-20 12:23:51
133	widget_loaded	cht_6xpko5j6umluwr9py	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-20 13:10:45	2026-02-20 13:10:45	2026-02-20 13:10:45
134	widget_loaded	cht_nyho35albmluxlfg5	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-20 13:34:12	2026-02-20 13:34:12	2026-02-20 13:34:12
135	widget_loaded	cht_glbavbt6umluxo937	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-20 13:36:24	2026-02-20 13:36:25	2026-02-20 13:36:25
136	widget_loaded	cht_tyko72db9mluxxb44	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-20 13:43:26	2026-02-20 13:43:27	2026-02-20 13:43:27
137	widget_loaded	cht_25esnth0cmluz2z40	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-20 14:15:50	2026-02-20 14:15:51	2026-02-20 14:15:51
139	chat_closed	cht_25esnth0cmluz2z40	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"user_messages": 0, "messages_exchanged": 1, "session_duration_seconds": 9}	2026-02-20 14:15:59	2026-02-20 14:15:59	2026-02-20 14:15:59
144	widget_loaded	cht_mh1cuov3kmlv5raq7	1	\N	\N	http://www.michaelmunavu.com/project/?id=10	http://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://www.michaelmunavu.com/project/?id=10", "referrer": ""}	2026-02-20 17:22:44	2026-02-20 17:22:45	2026-02-20 17:22:45
168	widget_loaded	cht_ezl577pc0mlx5roos	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeA9K22-4jBaeRjrEqhL9GXSqxpefHAdfmM4du7S2bpYoSsMsPu4DnRBCCEYM_aem_EXRgoXa26zl3qX0uooY9xw	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeA9K22-4jBaeRjrEqhL9GXSqxpefHAdfmM4du7S2bpYoSsMsPu4DnRBCCEYM_aem_EXRgoXa26zl3qX0uooY9xw", "referrer": "http://m.facebook.com"}	2026-02-22 02:58:33	2026-02-22 02:58:33	2026-02-22 02:58:33
169	widget_loaded	cht_3f62uxdo7mlx5rpb3	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEe3DcMlygrcg1-UdZY-ne4K5NWhYT078Sf9Zo59_OWKwBYBEs9V9d1BoXEE-I_aem_NPbVjOoGnOxqyYgU5tNoCQ	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEe3DcMlygrcg1-UdZY-ne4K5NWhYT078Sf9Zo59_OWKwBYBEs9V9d1BoXEE-I_aem_NPbVjOoGnOxqyYgU5tNoCQ", "referrer": "http://m.facebook.com"}	2026-02-22 02:58:34	2026-02-22 02:58:34	2026-02-22 02:58:34
177	widget_loaded	cht_hxpehxzxumlx5xi3i	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeSRmOOHEnm8JMSAVRuhXNu7fM_3TZlp5Ng13WZP6qHhLEAPxjvZTjffwtnGE_aem_DhF95UGuL-8tKq8kPd6kqQ	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeSRmOOHEnm8JMSAVRuhXNu7fM_3TZlp5Ng13WZP6qHhLEAPxjvZTjffwtnGE_aem_DhF95UGuL-8tKq8kPd6kqQ", "referrer": "http://m.facebook.com"}	2026-02-22 03:03:04	2026-02-22 03:03:04	2026-02-22 03:03:04
180	widget_loaded	cht_oaajnfswpmlxgyawg	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7559.132 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-22 08:11:37	2026-02-22 08:11:38	2026-02-22 08:11:38
187	widget_loaded	cht_4pj32r38vmlxvl7vg	1	\N	\N	https://www.michaelmunavu.com/about/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/about/", "referrer": "https://www.michaelmunavu.com/contact/"}	2026-02-22 15:01:21	2026-02-22 15:01:21	2026-02-22 15:01:21
138	chat_opened	cht_25esnth0cmluz2z40	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"has_email": false, "messages_count": 1}	2026-02-20 14:15:54	2026-02-20 14:15:54	2026-02-20 14:15:54
140	widget_loaded	cht_5n920tk7qmluzlttk	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-20 14:30:30	2026-02-20 14:30:31	2026-02-20 14:30:31
141	widget_loaded	cht_gryj4brhpmluzodpn	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-20 14:32:29	2026-02-20 14:32:30	2026-02-20 14:32:30
152	widget_loaded	cht_1mtvk2u44mlvvvrtr	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 5.0) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; Bytespider; https://zhanzhang.toutiao.com/)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-21 05:34:02	2026-02-21 05:34:02	2026-02-21 05:34:02
154	widget_loaded	cht_kqwxdxcawmlw8syhy	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-21 11:35:46	2026-02-21 11:35:48	2026-02-21 11:35:48
155	widget_loaded	cht_7zb1qsiscmlwdldmf	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-21 13:49:50	2026-02-21 13:49:50	2026-02-21 13:49:50
156	widget_loaded	cht_cgcwndh8umlwiny41	1	\N	\N	https://www.michaelmunavu.com/project/?id=8	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=8", "referrer": "https://www.michaelmunavu.com/"}	2026-02-21 16:11:52	2026-02-21 16:11:54	2026-02-21 16:11:54
157	widget_loaded	cht_7rxmw1m5omlwmq2p3	1	\N	\N	http://www.michaelmunavu.com/project/?id=10	http://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://www.michaelmunavu.com/project/?id=10", "referrer": ""}	2026-02-21 18:05:26	2026-02-21 18:05:27	2026-02-21 18:05:27
158	widget_loaded	cht_2g1b99z4bmlwplaaa	1	\N	\N	http://michaelmunavu.com/about/	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.81 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/about/", "referrer": ""}	2026-02-21 19:25:42	2026-02-21 19:25:43	2026-02-21 19:25:43
162	widget_loaded	cht_pd46ckazgmlwyyxss	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-21 23:48:14	2026-02-21 23:48:15	2026-02-21 23:48:15
164	widget_loaded	cht_6x8eifj9smlx5qzdg	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeb11Oh30ySE0HZ-IOVTEu5sEiuCk3ZAcrX9iIB8bHkE9Y1JmHm9G-Zw7Mi4g_aem_Z3U6unH2NjeN0iqgxGxVMA	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeb11Oh30ySE0HZ-IOVTEu5sEiuCk3ZAcrX9iIB8bHkE9Y1JmHm9G-Zw7Mi4g_aem_Z3U6unH2NjeN0iqgxGxVMA", "referrer": "http://m.facebook.com"}	2026-02-22 02:58:00	2026-02-22 02:58:00	2026-02-22 02:58:00
170	widget_loaded	cht_4fdeiym59mlx5rotm	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEe56Lrd7hiNmp4kJ4CpIWWrJ-xNmYYdxgBos5-WdtEmzfRtqYmLNVfmIPh6ks_aem_VpMqgb_fHaMMCugbuUat7Q	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEe56Lrd7hiNmp4kJ4CpIWWrJ-xNmYYdxgBos5-WdtEmzfRtqYmLNVfmIPh6ks_aem_VpMqgb_fHaMMCugbuUat7Q", "referrer": "http://m.facebook.com"}	2026-02-22 02:58:33	2026-02-22 02:58:34	2026-02-22 02:58:34
171	widget_loaded	cht_e94ssm3hvmlx5rqgm	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeWdMr9MvObSIkPtbCptSoWcUsKJ4Sjqyf_ahEdds6WUv6zlvH1GhtQMLKPIs_aem_wfs-5_j6GSFJmzcLEayzHQ	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeWdMr9MvObSIkPtbCptSoWcUsKJ4Sjqyf_ahEdds6WUv6zlvH1GhtQMLKPIs_aem_wfs-5_j6GSFJmzcLEayzHQ", "referrer": "http://m.facebook.com"}	2026-02-22 02:58:35	2026-02-22 02:58:35	2026-02-22 02:58:35
172	widget_loaded	cht_w1743ws33mlx5rudp	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeFFz6i_P6he-kYtDYUTJj_uplAb1ZWrQjNA8dLaglXRxYEpbuFcbrDsfxvnM_aem_Ri7_T-Gl2L2LtCPMwegl-Q	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeFFz6i_P6he-kYtDYUTJj_uplAb1ZWrQjNA8dLaglXRxYEpbuFcbrDsfxvnM_aem_Ri7_T-Gl2L2LtCPMwegl-Q", "referrer": "http://m.facebook.com"}	2026-02-22 02:58:40	2026-02-22 02:58:40	2026-02-22 02:58:40
178	widget_loaded	cht_o5geizk4wmlx80gy1	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-22 04:01:22	2026-02-22 04:01:22	2026-02-22 04:01:22
179	widget_loaded	cht_guqnew97pmlxeqrsx	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-22 07:09:47	2026-02-22 07:09:48	2026-02-22 07:09:48
181	widget_loaded	cht_fv1whh6s7mlxgyave	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Chrome/144.0.7559.132 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-22 08:11:37	2026-02-22 08:11:38	2026-02-22 08:11:38
182	widget_loaded	cht_ncom9cdjemlxijghb	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-22 08:56:05	2026-02-22 08:56:08	2026-02-22 08:56:08
142	widget_loaded	cht_kngbhhog3mlv1dfpw	1	\N	\N	http://michaelmunavu.com/project/?id=8	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.3	127.0.0.1	{"page_url": "http://michaelmunavu.com/project/?id=8", "referrer": ""}	2026-02-20 15:19:59	2026-02-20 15:20:00	2026-02-20 15:20:00
143	widget_loaded	cht_z074ny7grmlv4xjig	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-20 16:59:35	2026-02-20 16:59:36	2026-02-20 16:59:36
145	widget_loaded	cht_hcmm2eczlmlvmeus6	1	\N	\N	http://michaelmunavu.com/about/	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/about/", "referrer": ""}	2026-02-21 01:08:57	2026-02-21 01:08:59	2026-02-21 01:08:59
146	widget_loaded	cht_69xzakg7fmlvohe5x	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-21 02:06:54	2026-02-21 02:06:57	2026-02-21 02:06:57
147	widget_loaded	cht_x1lkcr3l3mlvqmret	1	\N	\N	https://www.michaelmunavu.com/project/?id=7	https://www.michaelmunavu.com/	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=7", "referrer": ""}	2026-02-21 03:07:02	2026-02-21 03:07:03	2026-02-21 03:07:03
148	widget_loaded	cht_ehjy8bpzsmlvqnens	1	\N	\N	https://www.michaelmunavu.com/project/?id=7	https://www.michaelmunavu.com/	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=7", "referrer": ""}	2026-02-21 03:07:34	2026-02-21 03:07:36	2026-02-21 03:07:36
149	widget_loaded	cht_m47473i36mlvqn9pg	1	\N	\N	https://www.michaelmunavu.com/project/?id=7	https://www.michaelmunavu.com/	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=7", "referrer": ""}	2026-02-21 03:07:31	2026-02-21 03:07:36	2026-02-21 03:07:36
150	widget_loaded	cht_6h76ow7bemlvr3l5n	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-21 03:20:07	2026-02-21 03:20:07	2026-02-21 03:20:07
151	widget_loaded	cht_0xs7ia08smlvuspdu	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-21 05:03:39	2026-02-21 05:03:40	2026-02-21 05:03:40
153	widget_loaded	cht_e9chbj57fmlw6rrln	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-21 10:38:52	2026-02-21 10:38:53	2026-02-21 10:38:53
159	widget_loaded	cht_qxti660utmlwqyrv0	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-21 20:04:09	2026-02-21 20:04:09	2026-02-21 20:04:09
160	widget_loaded	cht_wpqgox4ftmlws58x7	2	\N	\N	https://www.gs1kenya.org/panel	https://www.gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://www.gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/users/log_in"}	2026-02-21 20:37:12	2026-02-21 20:37:13	2026-02-21 20:37:13
161	widget_loaded	cht_i294gkv6tmlwt7b65	1	\N	\N	http://michaelmunavu.com/project/?id=8	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/project/?id=8", "referrer": ""}	2026-02-21 21:06:48	2026-02-21 21:06:49	2026-02-21 21:06:49
163	widget_loaded	cht_93zc0zgi0mlx5qy6i	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEerlnzTHwzZRxlhGs5mdxBbk3oXcSYTPsB_m1391QQJ-_egnZiPo-wpAKbNOM_aem_mE5danqU4exs-zBHyDy7ww	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEerlnzTHwzZRxlhGs5mdxBbk3oXcSYTPsB_m1391QQJ-_egnZiPo-wpAKbNOM_aem_mE5danqU4exs-zBHyDy7ww", "referrer": "http://m.facebook.com"}	2026-02-22 02:57:59	2026-02-22 02:57:59	2026-02-22 02:57:59
165	widget_loaded	cht_w2kb8nle7mlx5qzd9	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEe9Cw4AgsGdbZc9X7ehhm7daJc44zLYvTk0avwi84W9pzXa2TMMMSzmNPhbHk_aem_ykOm3pyifHLrZKeMZWzJsw	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEe9Cw4AgsGdbZc9X7ehhm7daJc44zLYvTk0avwi84W9pzXa2TMMMSzmNPhbHk_aem_ykOm3pyifHLrZKeMZWzJsw", "referrer": "http://m.facebook.com"}	2026-02-22 02:58:00	2026-02-22 02:58:01	2026-02-22 02:58:01
166	widget_loaded	cht_x57ptxx17mlx5qzut	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeWMqJ-uAQLW3nPpySellZIvIcRz9s8N4SvIGsKq1UIATHWcvsjQ4g_SuuXBc_aem_G32ZvXYobUHddDHvzG-ISA	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeWMqJ-uAQLW3nPpySellZIvIcRz9s8N4SvIGsKq1UIATHWcvsjQ4g_SuuXBc_aem_G32ZvXYobUHddDHvzG-ISA", "referrer": "http://m.facebook.com"}	2026-02-22 02:58:01	2026-02-22 02:58:01	2026-02-22 02:58:01
167	widget_loaded	cht_rb5rdvf3pmlx5r1py	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEedXhv4-yDiW6PY_DdoeKIb17Adn_-a7ehQ1XRytjfqMiyb_l6UKCFGt1ZGxw_aem_TKMpDz2dT4-4bxUSejmt7Q	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEedXhv4-yDiW6PY_DdoeKIb17Adn_-a7ehQ1XRytjfqMiyb_l6UKCFGt1ZGxw_aem_TKMpDz2dT4-4bxUSejmt7Q", "referrer": "http://m.facebook.com"}	2026-02-22 02:58:03	2026-02-22 02:58:04	2026-02-22 02:58:04
184	widget_loaded	cht_1nmyen38cmlxvjwbk	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-22 15:00:20	2026-02-22 15:00:21	2026-02-22 15:00:21
173	widget_loaded	cht_ljcqib7samlx5sgbm	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeebzYcSnHoPUZ-PgLu4b_rACdXBNqIoAvk6a7HQX-4YgvanL0eT4pn_oij74_aem_WOfMbdTUF0-Fdiq1CKFn4A	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeebzYcSnHoPUZ-PgLu4b_rACdXBNqIoAvk6a7HQX-4YgvanL0eT4pn_oij74_aem_WOfMbdTUF0-Fdiq1CKFn4A", "referrer": "http://m.facebook.com"}	2026-02-22 02:59:09	2026-02-22 02:59:09	2026-02-22 02:59:09
174	widget_loaded	cht_jy2ycrv98mlx5tgls	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEebMcUPKN0EzXUBzc0VUu0Cms8tFxHEUfoBwySCtbUJXQa9ubsiHwsQQ8niCQ_aem_CppM53yoJtHJYMnICEiP9A	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEebMcUPKN0EzXUBzc0VUu0Cms8tFxHEUfoBwySCtbUJXQa9ubsiHwsQQ8niCQ_aem_CppM53yoJtHJYMnICEiP9A", "referrer": "http://m.facebook.com"}	2026-02-22 02:59:56	2026-02-22 02:59:56	2026-02-22 02:59:56
183	widget_loaded	cht_7jivaoj8zmlxsgdx2	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-22 13:33:36	2026-02-22 13:33:36	2026-02-22 13:33:36
175	widget_loaded	cht_xmjg16jm4mlx5tx98	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeFWrDkhM6wIgfLDykoGQ9sssxk8ZLeQ4_sLLwxiwOaP7sBFEn7IgfJ1TQ58c_aem_V-Pt-fc0g0jeFenTYtEgpg	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeFWrDkhM6wIgfLDykoGQ9sssxk8ZLeQ4_sLLwxiwOaP7sBFEn7IgfJ1TQ58c_aem_V-Pt-fc0g0jeFenTYtEgpg", "referrer": "http://m.facebook.com"}	2026-02-22 03:00:17	2026-02-22 03:00:17	2026-02-22 03:00:17
186	widget_loaded	cht_m2jyitnkxmlxvknax	1	\N	\N	https://www.michaelmunavu.com/contact/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36 (compatible; Google-Read-Aloud; +https://support.google.com/webmasters/answer/1061943)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/contact/", "referrer": ""}	2026-02-22 15:00:54	2026-02-22 15:00:55	2026-02-22 15:00:55
176	widget_loaded	cht_ruoetgvmimlx5w8uc	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeRazFc6C0GwZz0KlU71CsCssyzIWQve_1an5sFFSibv5NUjUFWHkZ46fiOww_aem_CS19Fa8U_34_HI9gKYahJw	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEeRazFc6C0GwZz0KlU71CsCssyzIWQve_1an5sFFSibv5NUjUFWHkZ46fiOww_aem_CS19Fa8U_34_HI9gKYahJw", "referrer": "http://m.facebook.com"}	2026-02-22 03:02:06	2026-02-22 03:02:06	2026-02-22 03:02:06
185	widget_loaded	cht_8d80o2uq1mlxvkmvm	1	\N	\N	https://www.michaelmunavu.com/contact/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/contact/", "referrer": "https://www.michaelmunavu.com/"}	2026-02-22 15:00:54	2026-02-22 15:00:54	2026-02-22 15:00:54
188	widget_loaded	cht_g5qmkg8x3mlxvs7us	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-22 15:06:48	2026-02-22 15:06:49	2026-02-22 15:06:49
189	widget_loaded	cht_en49gciuymlxykgne	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-22 16:24:45	2026-02-22 16:24:45	2026-02-22 16:24:45
190	widget_loaded	cht_98shpzigkmlxyvufb	1	\N	\N	https://www.michaelmunavu.com/	\N	Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/136.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-22 16:33:36	2026-02-22 16:33:38	2026-02-22 16:33:38
191	widget_loaded	cht_laui0nre9mly4e8j7	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-22 19:07:52	2026-02-22 19:07:53	2026-02-22 19:07:53
192	widget_loaded	cht_oyb2glubsmly4ejt9	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-22 19:08:06	2026-02-22 19:08:06	2026-02-22 19:08:06
193	widget_loaded	cht_15fgwa5rimly4eqhz	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-22 19:08:15	2026-02-22 19:08:15	2026-02-22 19:08:15
194	widget_loaded	cht_hpk5p1zn3mly54d8h	1	\N	\N	http://michaelmunavu.com/project/?id=7	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/project/?id=7", "referrer": ""}	2026-02-22 19:28:12	2026-02-22 19:28:14	2026-02-22 19:28:14
195	widget_loaded	cht_m8fsolk8dmlyh5gko	1	\N	\N	http://michaelmunavu.com/project/?id=8	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/project/?id=8", "referrer": ""}	2026-02-23 01:04:59	2026-02-23 01:05:00	2026-02-23 01:05:00
196	widget_loaded	cht_awbfflh7emlyn9dm4	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-23 03:55:58	2026-02-23 03:55:59	2026-02-23 03:55:59
197	widget_loaded	cht_9l0ki809jmlynx8eg	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-23 04:14:32	2026-02-23 04:14:32	2026-02-23 04:14:32
198	widget_loaded	cht_duhtcwxo3mlyowv8p	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-23 04:42:14	2026-02-23 04:42:15	2026-02-23 04:42:15
199	widget_loaded	cht_pd9tneeuhmlyqpq2j	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-23 05:32:41	2026-02-23 05:32:43	2026-02-23 05:32:43
200	widget_loaded	cht_5f1bpmzzwmlyrohv4	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-23 05:59:47	2026-02-23 05:59:49	2026-02-23 05:59:49
201	widget_loaded	cht_ymakl037mmlyrzpit	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-23 06:08:25	2026-02-23 06:08:28	2026-02-23 06:08:28
202	widget_loaded	cht_w396plp4amlytau9j	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-23 06:45:05	2026-02-23 06:45:05	2026-02-23 06:45:05
203	widget_loaded	cht_loddrigdbmlytukcn	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-23 07:00:24	2026-02-23 07:00:24	2026-02-23 07:00:24
204	widget_loaded	cht_1iytz7hvgmlyumwuh	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-23 07:22:27	2026-02-23 07:22:28	2026-02-23 07:22:28
205	widget_loaded	cht_mi7mbwh36mlyvhbku	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-23 07:46:06	2026-02-23 07:46:04	2026-02-23 07:46:04
206	widget_loaded	cht_zex5ot7g5mlyvqwfa	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-23 07:53:32	2026-02-23 07:53:32	2026-02-23 07:53:32
207	widget_loaded	cht_1gpaxyvhxmlywa52n	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-23 08:08:31	2026-02-23 08:08:31	2026-02-23 08:08:31
208	widget_loaded	cht_a2q1gbxt2mlyws33d	1	\N	\N	http://michaelmunavu.com/project/?id=7	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/project/?id=7", "referrer": ""}	2026-02-23 08:22:29	2026-02-23 08:22:30	2026-02-23 08:22:30
209	widget_loaded	cht_obd754175mlyx19d7	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-23 08:29:36	2026-02-23 08:29:37	2026-02-23 08:29:37
232	widget_loaded	cht_9stdmdbpjmlz42vcw	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-23 11:46:49	2026-02-23 11:46:50	2026-02-23 11:46:50
234	widget_loaded	cht_xa4ipieqcmlz5a5r9	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-23 12:20:28	2026-02-23 12:20:29	2026-02-23 12:20:29
210	widget_loaded	cht_inu99s0wemlyx1jh5	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/panel"}	2026-02-23 08:29:48	2026-02-23 08:29:49	2026-02-23 08:29:49
211	widget_loaded	cht_vp2nqmhrvmlyy848u	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "http://localhost:4600/"}	2026-02-23 09:02:55	2026-02-23 09:02:56	2026-02-23 09:02:56
238	widget_loaded	cht_oixx93qrnmlzdh7gx	1	\N	\N	https://www.michaelmunavu.com/project/?id=3	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=3", "referrer": "https://www.michaelmunavu.com/"}	2026-02-23 16:09:59	2026-02-23 16:09:59	2026-02-23 16:09:59
248	widget_loaded	cht_bgqcnm0ksmm05bbcl	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 05:09:08	2026-02-24 05:09:07	2026-02-24 05:09:07
212	widget_loaded	cht_tak4ote77mlyy8cap	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "http://localhost:4600/"}	2026-02-23 09:03:05	2026-02-23 09:03:05	2026-02-23 09:03:05
217	widget_loaded	cht_ksy2quyi8mlyzy01o	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-23 09:51:02	2026-02-23 09:51:02	2026-02-23 09:51:02
223	widget_loaded	cht_cizcuopztmlz1405r	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-23 10:23:42	2026-02-23 10:23:43	2026-02-23 10:23:43
231	widget_loaded	cht_qio0ueifpmlz2dutv	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-23 10:59:21	2026-02-23 10:59:21	2026-02-23 10:59:21
213	widget_loaded	cht_gvj59xyn3mlyyxfd4	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-23 09:22:36	2026-02-23 09:22:37	2026-02-23 09:22:37
225	widget_loaded	cht_fdcov19mmmlz1d7rq	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-23 10:30:52	2026-02-23 10:30:52	2026-02-23 10:30:52
233	widget_loaded	cht_6xdu4pns9mlz52d55	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-23 12:14:24	2026-02-23 12:14:25	2026-02-23 12:14:25
242	widget_loaded	cht_139a39e21mlzsakah	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-23 23:04:37	2026-02-23 23:04:38	2026-02-23 23:04:38
214	widget_loaded	cht_dorw0rchsmlyzn5w6	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-23 09:42:37	2026-02-23 09:42:38	2026-02-23 09:42:38
221	widget_loaded	cht_pwqt8a39bmlz0cjc3	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-23 10:02:20	2026-02-23 10:02:21	2026-02-23 10:02:21
236	widget_loaded	cht_4pw6nkfz7mlzdetwp	1	\N	\N	https://www.michaelmunavu.com/project/?id=7	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=7", "referrer": "https://www.michaelmunavu.com/"}	2026-02-23 16:08:15	2026-02-23 16:08:15	2026-02-23 16:08:15
246	widget_loaded	cht_c3js1ntj7mm03io76	1	\N	\N	http://www.michaelmunavu.com/project/?id=11	http://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://www.michaelmunavu.com/project/?id=11", "referrer": ""}	2026-02-24 04:18:53	2026-02-24 04:18:54	2026-02-24 04:18:54
215	widget_loaded	cht_9lgsl4sfgmlyzxtuu	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-23 09:50:55	2026-02-23 09:50:56	2026-02-23 09:50:56
216	chat_opened	cht_9lgsl4sfgmlyzxtuu	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"has_email": false, "messages_count": 1}	2026-02-23 09:50:59	2026-02-23 09:50:59	2026-02-23 09:50:59
218	chat_opened	cht_inu99s0wemlyx1jh5	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"has_email": false, "messages_count": 1}	2026-02-23 09:54:33	2026-02-23 09:54:42	2026-02-23 09:54:42
219	chat_closed	cht_inu99s0wemlyx1jh5	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"user_messages": 0, "messages_exchanged": 1, "session_duration_seconds": 5094}	2026-02-23 09:54:43	2026-02-23 09:54:43	2026-02-23 09:54:43
220	widget_loaded	cht_c1l6hw0uymlz0c2n7	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-23 10:01:59	2026-02-23 10:02:00	2026-02-23 10:02:00
222	widget_loaded	cht_d6x8mmuu8mlz13dim	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-23 10:23:13	2026-02-23 10:23:14	2026-02-23 10:23:14
224	widget_loaded	cht_ah3rlbsuqmlz14euj	2	\N	\N	http://localhost:4600/panel	http://localhost:4600/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:4600/panel", "referrer": "http://localhost:4600/users/log_in"}	2026-02-23 10:24:01	2026-02-23 10:24:02	2026-02-23 10:24:02
230	widget_loaded	cht_sxgnq9prtmlz2bj3x	2	\N	\N	https://gs1kenya.org/hrm_dashboard	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/hrm_dashboard", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-23 10:57:34	2026-02-23 10:57:34	2026-02-23 10:57:34
235	widget_loaded	cht_0i190i28nmlzd8t9s	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-23 16:03:26	2026-02-23 16:03:27	2026-02-23 16:03:27
237	widget_loaded	cht_4upemdsremlzdgkuv	1	\N	\N	https://www.michaelmunavu.com/project/?id=15	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=15", "referrer": "https://www.michaelmunavu.com/"}	2026-02-23 16:09:24	2026-02-23 16:09:25	2026-02-23 16:09:25
239	widget_loaded	cht_2nl2w3n27mlzdh7lo	1	\N	\N	https://www.michaelmunavu.com/project/?id=1	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=1", "referrer": "https://www.michaelmunavu.com/"}	2026-02-23 16:09:59	2026-02-23 16:09:59	2026-02-23 16:09:59
240	widget_loaded	cht_vb9iuuzagmlzdgvfe	1	\N	\N	https://www.michaelmunavu.com/project/?id=11	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=11", "referrer": "https://www.michaelmunavu.com/"}	2026-02-23 16:10:02	2026-02-23 16:10:02	2026-02-23 16:10:02
243	widget_loaded	cht_q6wuby0v4mlzui4d1	1	\N	\N	http://michaelmunavu.com/	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/", "referrer": ""}	2026-02-24 00:06:31	2026-02-24 00:06:33	2026-02-24 00:06:33
245	widget_loaded	cht_nddzzubuvmm02x5ff	1	\N	\N	http://michaelmunavu.com/project/?id=2	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.81 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/project/?id=2", "referrer": ""}	2026-02-24 04:02:09	2026-02-24 04:02:10	2026-02-24 04:02:10
226	widget_loaded	cht_eozxjduynmlz1fhm4	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/about"}	2026-02-23 10:32:38	2026-02-23 10:32:39	2026-02-23 10:32:39
227	widget_loaded	cht_be7xcgah6mlz1outj	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-23 10:39:55	2026-02-23 10:39:56	2026-02-23 10:39:56
241	widget_loaded	cht_vm983sqa8mlzl5mft	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-23 19:44:51	2026-02-23 19:44:52	2026-02-23 19:44:52
228	widget_loaded	cht_sl0eiysybmlz1y1xe	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/confirm/b6FIy5fa4MexaIYjBChOqJgKyclQMteWJ_oHpx9vl9c"}	2026-02-23 10:47:04	2026-02-23 10:47:05	2026-02-23 10:47:05
229	widget_loaded	cht_yzie360ojmlz211f5	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-23 10:49:23	2026-02-23 10:49:25	2026-02-23 10:49:25
244	widget_loaded	cht_im75r46hxmlzzmytc	1	\N	\N	http://www.michaelmunavu.com/project/?id=7	http://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.5249.119 Safari/537.36	127.0.0.1	{"page_url": "http://www.michaelmunavu.com/project/?id=7", "referrer": ""}	2026-02-24 02:30:16	2026-02-24 02:30:17	2026-02-24 02:30:17
247	widget_loaded	cht_kgbcvbzhfmm04ljpb	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 04:49:06	2026-02-24 04:49:04	2026-02-24 04:49:04
249	widget_loaded	cht_viaij0mzkmm05v6rc	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-24 05:24:38	2026-02-24 05:24:39	2026-02-24 05:24:39
250	widget_loaded	cht_hjt2m7rremm068354	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 05:34:37	2026-02-24 05:34:38	2026-02-24 05:34:38
251	widget_loaded	cht_7dm2c3p5wmm069qaq	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "http://localhost:4600/"}	2026-02-24 05:35:54	2026-02-24 05:35:54	2026-02-24 05:35:54
252	widget_loaded	cht_coq6s4miwmm06gals	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 05:41:00	2026-02-24 05:41:00	2026-02-24 05:41:00
253	widget_loaded	cht_h8peql207mm06lic6	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 05:45:03	2026-02-24 05:45:06	2026-02-24 05:45:06
254	widget_loaded	cht_rlcmw1w65mm06ml15	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-24 05:45:52	2026-02-24 05:45:53	2026-02-24 05:45:53
255	widget_loaded	cht_2lvhly9yymm06mni7	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-24 05:45:56	2026-02-24 05:45:56	2026-02-24 05:45:56
256	widget_loaded	cht_qt131j1dsmm06myos	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 05:46:10	2026-02-24 05:46:10	2026-02-24 05:46:10
257	widget_loaded	cht_21q7iw6lamm06y5lb	2	\N	\N	https://gs1kenya.org//panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org//panel", "referrer": ""}	2026-02-24 05:54:53	2026-02-24 05:54:54	2026-02-24 05:54:54
258	widget_loaded	cht_fj74592qzmm072dt1	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 05:58:11	2026-02-24 05:58:12	2026-02-24 05:58:12
259	widget_loaded	cht_f15vkr637mm07ktms	2	\N	\N	https://gs1kenya.org/hrm_dashboard	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/hrm_dashboard", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 06:12:31	2026-02-24 06:12:32	2026-02-24 06:12:32
260	widget_loaded	cht_45vc8sim7mm07qjq6	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-24 06:16:58	2026-02-24 06:16:59	2026-02-24 06:16:59
261	widget_loaded	cht_o7nyj3usfmm08n9zw	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 06:42:36	2026-02-24 06:42:36	2026-02-24 06:42:36
262	widget_loaded	cht_q8dps0demmm08otiw	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-24 06:43:37	2026-02-24 06:43:36	2026-02-24 06:43:36
263	widget_loaded	cht_x2q2afgg1mm08tfge	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-24 06:47:14	2026-02-24 06:47:16	2026-02-24 06:47:16
264	widget_loaded	cht_rf8104fhjmm08zmu7	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-24 06:52:02	2026-02-24 06:52:01	2026-02-24 06:52:01
265	widget_loaded	cht_ep3lbv8jymm0a3ph4	1	\N	\N	http://michaelmunavu.com/	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/", "referrer": ""}	2026-02-24 07:23:12	2026-02-24 07:23:13	2026-02-24 07:23:13
413	widget_loaded	cht_krpghrlw3mm3hp796	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-26 13:19:09	2026-02-26 13:19:10	2026-02-26 13:19:10
266	widget_loaded	cht_w646wtik3mm0auw0y	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 07:44:19	2026-02-24 07:44:20	2026-02-24 07:44:20
273	widget_loaded	cht_if6dp4u1vmm0d5on4	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/member/login/portal"}	2026-02-24 08:48:42	2026-02-24 08:48:42	2026-02-24 08:48:42
279	widget_loaded	cht_2jnrsaro0mm0e0zx9	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 09:13:02	2026-02-24 09:13:02	2026-02-24 09:13:02
285	widget_loaded	cht_q4wdffobumm0embij	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-24 09:29:38	2026-02-24 09:29:39	2026-02-24 09:29:39
288	widget_loaded	cht_mnug3gidgmm0feckw	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 09:51:26	2026-02-24 09:51:26	2026-02-24 09:51:26
295	widget_loaded	cht_3wummkyd5mm0gapl1	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 10:16:36	2026-02-24 10:16:37	2026-02-24 10:16:37
298	widget_loaded	cht_f6i16fe9cmm0ghpzc	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/users/log_in"}	2026-02-24 10:22:02	2026-02-24 10:22:02	2026-02-24 10:22:02
302	widget_loaded	cht_1abhpwd86mm0gyxcu	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 10:35:25	2026-02-24 10:35:25	2026-02-24 10:35:25
304	widget_loaded	cht_pbsxerhu7mm0h6zlv	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 10:41:41	2026-02-24 10:41:42	2026-02-24 10:41:42
311	widget_loaded	cht_a2eg4qaltmm0hiio3	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 10:50:39	2026-02-24 10:50:40	2026-02-24 10:50:40
315	widget_loaded	cht_4lshcw5zsmm0i54wg	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 11:08:14	2026-02-24 11:08:15	2026-02-24 11:08:15
267	widget_loaded	cht_ued1ijz1emm0b9gk7	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/phones"}	2026-02-24 07:55:45	2026-02-24 07:55:49	2026-02-24 07:55:49
270	widget_loaded	cht_f9re1a2ecmm0cpqkl	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-24 08:36:18	2026-02-24 08:36:17	2026-02-24 08:36:17
281	widget_loaded	cht_mox0kxe2dmm0e1yg4	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/users/log_in"}	2026-02-24 09:13:47	2026-02-24 09:13:47	2026-02-24 09:13:47
284	widget_loaded	cht_en3j0trjbmm0eh3pg	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/users/log_in"}	2026-02-24 09:25:34	2026-02-24 09:25:34	2026-02-24 09:25:34
287	widget_loaded	cht_q45bpyrtsmm0ep7rw	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 09:31:52	2026-02-24 09:31:51	2026-02-24 09:31:51
290	widget_loaded	cht_11jwgkr7emm0ftmuo	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 10:03:19	2026-02-24 10:03:19	2026-02-24 10:03:19
307	widget_loaded	cht_t10jr3u62mm0hh8ev	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/users/log_in"}	2026-02-24 10:49:39	2026-02-24 10:49:39	2026-02-24 10:49:39
309	widget_loaded	cht_h960i9w1bmm0hhymv	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/users/log_in"}	2026-02-24 10:50:13	2026-02-24 10:50:13	2026-02-24 10:50:13
310	widget_loaded	cht_2sbf74pmcmm0hi5fd	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/users/log_in"}	2026-02-24 10:50:22	2026-02-24 10:50:23	2026-02-24 10:50:23
268	widget_loaded	cht_c4wrisihbmm0ccjnj	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member_details/7421/barcodes"}	2026-02-24 08:26:02	2026-02-24 08:26:01	2026-02-24 08:26:01
269	widget_loaded	cht_1y58b5yobmm0cfzcm	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 08:28:43	2026-02-24 08:28:48	2026-02-24 08:28:48
274	widget_loaded	cht_xge02f00emm0d5v2x	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-24 08:48:51	2026-02-24 08:48:51	2026-02-24 08:48:51
277	widget_loaded	cht_f4h0jsem6mm0do91p	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 09:03:08	2026-02-24 09:03:08	2026-02-24 09:03:08
282	widget_loaded	cht_m5pqzhk5bmm0e6u02	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 09:17:39	2026-02-24 09:17:41	2026-02-24 09:17:41
283	widget_loaded	cht_ja25s05qfmm0eg2ka	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/users/log_in"}	2026-02-24 09:24:47	2026-02-24 09:24:47	2026-02-24 09:24:47
300	widget_loaded	cht_589eypykzmm0grpzq	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 10:29:53	2026-02-24 10:29:53	2026-02-24 10:29:53
306	widget_loaded	cht_dd5gqb9p1mm0hab56	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/panel"}	2026-02-24 10:44:16	2026-02-24 10:44:16	2026-02-24 10:44:16
271	widget_loaded	cht_mk77cgjn2mm0csyrq	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 08:38:49	2026-02-24 08:38:49	2026-02-24 08:38:49
291	widget_loaded	cht_xxw77a4uomm0g3bhe	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-24 10:10:50	2026-02-24 10:10:51	2026-02-24 10:10:51
299	widget_loaded	cht_whfp44dojmm0gnuly	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/receipts/11544539?query=sandino"}	2026-02-24 10:26:49	2026-02-24 10:26:48	2026-02-24 10:26:48
301	widget_loaded	cht_a392etiybmm0gxcdh	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 10:34:11	2026-02-24 10:34:11	2026-02-24 10:34:11
272	widget_loaded	cht_qp4utpzhdmm0d257g	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/member/login/portal"}	2026-02-24 08:45:57	2026-02-24 08:45:57	2026-02-24 08:45:57
289	widget_loaded	cht_s429h2eksmm0fn6d7	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 09:58:18	2026-02-24 09:58:18	2026-02-24 09:58:18
294	widget_loaded	cht_4b8nnz2thmm0g6cog	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 10:13:11	2026-02-24 10:13:12	2026-02-24 10:13:12
297	widget_loaded	cht_gfygth15rmm0gh89u	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/users/log_in"}	2026-02-24 10:21:46	2026-02-24 10:21:46	2026-02-24 10:21:46
312	widget_loaded	cht_et9vv08yqmm0hmdmt	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 10:53:39	2026-02-24 10:53:39	2026-02-24 10:53:39
275	widget_loaded	cht_emjsuw4htmm0dachv	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/users/log_in"}	2026-02-24 08:52:19	2026-02-24 08:52:20	2026-02-24 08:52:20
276	widget_loaded	cht_ahq5x7zoymm0ddv8k	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/users/log_in"}	2026-02-24 08:55:03	2026-02-24 08:55:04	2026-02-24 08:55:04
292	widget_loaded	cht_s79gv7ru4mm0g3jih	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/panel"}	2026-02-24 10:11:00	2026-02-24 10:11:00	2026-02-24 10:11:00
278	widget_loaded	cht_373ofeybgmm0e0vyh	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 09:12:58	2026-02-24 09:12:58	2026-02-24 09:12:58
280	widget_loaded	cht_lnxj2j8ojmm0e1wky	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/users/log_in"}	2026-02-24 09:13:45	2026-02-24 09:13:45	2026-02-24 09:13:45
286	widget_loaded	cht_1ya33wja9mm0ep63l	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 09:31:51	2026-02-24 09:31:50	2026-02-24 09:31:50
293	widget_loaded	cht_ef6cwj4nvmm0g677h	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/panel"}	2026-02-24 10:13:04	2026-02-24 10:13:05	2026-02-24 10:13:05
305	widget_loaded	cht_ao834zg6zmm0ha93u	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-24 10:44:14	2026-02-24 10:44:14	2026-02-24 10:44:14
308	widget_loaded	cht_lgvabe9vomm0hhpa3	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/panel"}	2026-02-24 10:50:00	2026-02-24 10:50:01	2026-02-24 10:50:01
313	widget_loaded	cht_55voomvatmm0hmsbc	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 10:53:58	2026-02-24 10:53:58	2026-02-24 10:53:58
296	widget_loaded	cht_aotoprfcwmm0gfn0b	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": "http://localhost:9100/users/log_in"}	2026-02-24 10:20:26	2026-02-24 10:20:26	2026-02-24 10:20:26
303	widget_loaded	cht_elovrk7itmm0h6sah	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 10:41:31	2026-02-24 10:41:32	2026-02-24 10:41:32
314	widget_loaded	cht_kin4uh7nzmm0ho8gy	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 10:55:06	2026-02-24 10:55:08	2026-02-24 10:55:08
316	widget_loaded	cht_stajr2m9imm0i93fp	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 11:11:20	2026-02-24 11:11:20	2026-02-24 11:11:20
317	widget_loaded	cht_jm6qnb679mm0ihq8e	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 11:18:02	2026-02-24 11:18:03	2026-02-24 11:18:03
318	widget_loaded	cht_qv08wfbb3mm0ioniu	1	\N	\N	https://www.michaelmunavu.com/project/?id=7	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.5249.119 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=7", "referrer": ""}	2026-02-24 11:23:26	2026-02-24 11:23:28	2026-02-24 11:23:28
319	widget_loaded	cht_ag6gskly9mm0jx2si	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-24 11:57:58	2026-02-24 11:57:59	2026-02-24 11:57:59
320	widget_loaded	cht_0wsldth6pmm0mxnvo	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-24 13:22:24	2026-02-24 13:22:25	2026-02-24 13:22:25
321	widget_loaded	cht_fv1whh6s7mlzu9s0r	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7559.132 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-24 00:00:00	2026-02-24 14:18:14	2026-02-24 14:18:14
322	widget_loaded	cht_ewbug1wk1mm0oxq86	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Chrome/144.0.7559.132 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-24 14:18:25	2026-02-24 14:18:34	2026-02-24 14:18:34
323	widget_loaded	cht_ewbug1wk1mm0oxq7r	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7559.132 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-24 14:18:25	2026-02-24 14:18:38	2026-02-24 14:18:38
324	widget_loaded	cht_ajx52j5cymm0t4dz6	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-24 16:15:35	2026-02-24 16:15:35	2026-02-24 16:15:35
325	widget_loaded	cht_wdhufjy1vmm10bkxg	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-24 19:37:09	2026-02-24 19:37:10	2026-02-24 19:37:10
326	widget_loaded	cht_m45qyzoi0mm1iiitd	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Chrome/144.0.7559.132 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-25 04:06:24	2026-02-25 04:06:29	2026-02-25 04:06:29
327	widget_loaded	cht_fv1whh6s7mm1iiio3	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7559.132 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-25 04:06:24	2026-02-25 04:06:31	2026-02-25 04:06:31
328	widget_loaded	cht_4f7tohbcymm1kr5oe	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-25 05:09:08	2026-02-25 05:09:07	2026-02-25 05:09:07
329	widget_loaded	cht_lbnn7sz35mm1lkmb9	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "http://102.220.22.83:4800/"}	2026-02-25 05:32:02	2026-02-25 05:32:03	2026-02-25 05:32:03
330	chat_opened	cht_lbnn7sz35mm1lkmb9	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"has_email": false, "messages_count": 1}	2026-02-25 05:32:14	2026-02-25 05:32:14	2026-02-25 05:32:14
331	chat_closed	cht_lbnn7sz35mm1lkmb9	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"user_messages": 0, "messages_exchanged": 1, "session_duration_seconds": 15}	2026-02-25 05:32:17	2026-02-25 05:32:17	2026-02-25 05:32:17
332	widget_loaded	cht_tmb77fvsrmm1lmj1p	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "http://102.220.22.83:4800/"}	2026-02-25 05:33:31	2026-02-25 05:33:31	2026-02-25 05:33:31
333	widget_loaded	cht_tuomkkkg3mm1lnpc7	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-25 05:34:26	2026-02-25 05:34:26	2026-02-25 05:34:26
334	widget_loaded	cht_ixvjmb32dmm1lqwzc	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-25 05:36:56	2026-02-25 05:36:56	2026-02-25 05:36:56
335	widget_loaded	cht_f516r3wssmm1m4adf	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-25 05:47:20	2026-02-25 05:47:20	2026-02-25 05:47:20
336	widget_loaded	cht_ibc3u4uu0mm1mp2e8	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-25 06:03:31	2026-02-25 06:03:32	2026-02-25 06:03:32
337	widget_loaded	cht_51zpp118xmm1mtwm7	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-25 06:07:15	2026-02-25 06:07:16	2026-02-25 06:07:16
338	widget_loaded	cht_vqujqjczymm1mx0zp	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-25 06:09:41	2026-02-25 06:09:43	2026-02-25 06:09:43
340	widget_loaded	cht_20qrqkl6lmm1nw1dm	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-25 06:36:54	2026-02-25 06:36:55	2026-02-25 06:36:55
343	widget_loaded	cht_d2wfj6trumm1p9bct	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-25 07:15:13	2026-02-25 07:15:12	2026-02-25 07:15:12
345	widget_loaded	cht_7f7cl4cwfmm1qaefd	1	\N	\N	https://www.michaelmunavu.com/project/?id=8	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=8", "referrer": "https://www.michaelmunavu.com/"}	2026-02-25 07:44:03	2026-02-25 07:44:03	2026-02-25 07:44:03
347	widget_loaded	cht_kj8gkwn3bmm1qsgi9	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-25 07:58:06	2026-02-25 07:58:06	2026-02-25 07:58:06
355	widget_loaded	cht_wtf3xfnmymm1um9i7	2	\N	\N	http://localhost:4600/panel	http://localhost:4600/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:4600/panel", "referrer": "http://localhost:4600/users/log_in"}	2026-02-25 09:45:16	2026-02-25 09:45:16	2026-02-25 09:45:16
357	widget_loaded	cht_1mahin04rmm1we7nz	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEePgqv9ESuylh1no23dGyI7KvuGTXX5rUZ85IvfWGFcLNY1ur3w7L0QTmdVRE_aem_2Eoq_Zqyd8wzJFAXcOiLbg	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEePgqv9ESuylh1no23dGyI7KvuGTXX5rUZ85IvfWGFcLNY1ur3w7L0QTmdVRE_aem_2Eoq_Zqyd8wzJFAXcOiLbg", "referrer": "http://m.facebook.com"}	2026-02-25 10:34:59	2026-02-25 10:34:59	2026-02-25 10:34:59
358	widget_loaded	cht_iyd6l89exmm1yiu02	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-25 11:34:42	2026-02-25 11:34:43	2026-02-25 11:34:43
359	widget_loaded	cht_i1xh5fvjxmm1yxsr0	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEePsqSy2rk--PdVqRDulmiRBfE2XDEtJmbdqkhZ3ul8kfZbmPCZVmKJRb2N0w_aem_DccKjypiZcIsKf_ykKETAA	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEePsqSy2rk--PdVqRDulmiRBfE2XDEtJmbdqkhZ3ul8kfZbmPCZVmKJRb2N0w_aem_DccKjypiZcIsKf_ykKETAA", "referrer": "http://m.facebook.com"}	2026-02-25 11:46:12	2026-02-25 11:46:12	2026-02-25 11:46:12
360	widget_loaded	cht_hmelqng2nmm209hul	1	\N	\N	http://michaelmunavu.com/portfolio/	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/portfolio/", "referrer": ""}	2026-02-25 12:23:18	2026-02-25 12:23:20	2026-02-25 12:23:20
365	widget_loaded	cht_y3dmkf7fwmm22q4kk	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEe1cHaV3AxG-96Cktq1rAu8oMhCqWu7tvzWfku5aaim88GwHY2tmfa4321QDY_aem_IkWNpZTuQTDNcn8pP2pAkg	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEe1cHaV3AxG-96Cktq1rAu8oMhCqWu7tvzWfku5aaim88GwHY2tmfa4321QDY_aem_IkWNpZTuQTDNcn8pP2pAkg", "referrer": "http://m.facebook.com"}	2026-02-25 13:32:12	2026-02-25 13:32:12	2026-02-25 13:32:12
368	widget_loaded	cht_zjj6dsrromm23jt6a	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEez4WhJN6k6HJVux3zu3_sCacf2DN0jYp0yR3il5l1BGP0A8oEv0QjgXra3OE_aem_6YV25p1tRvgkFzL2IfEIfQ	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEez4WhJN6k6HJVux3zu3_sCacf2DN0jYp0yR3il5l1BGP0A8oEv0QjgXra3OE_aem_6YV25p1tRvgkFzL2IfEIfQ", "referrer": "http://m.facebook.com"}	2026-02-25 13:55:17	2026-02-25 13:55:17	2026-02-25 13:55:17
374	widget_loaded	cht_jp6wofvk2mm24dcnd	1	\N	\N	https://www.michaelmunavu.com/project/?id=8	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=8", "referrer": "https://www.michaelmunavu.com/"}	2026-02-25 14:18:16	2026-02-25 14:18:16	2026-02-25 14:18:16
376	widget_loaded	cht_gsalowe9nmm28lzgd	1	\N	\N	http://www.michaelmunavu.com/project/?id=3	http://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://www.michaelmunavu.com/project/?id=3", "referrer": ""}	2026-02-25 16:16:58	2026-02-25 16:16:59	2026-02-25 16:16:59
378	widget_loaded	cht_6iqx4njwvmm2axdna	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEexXiic12kH8gWhMJwGks9cc5HdBPcH4oZ4920yvD4NcT9mHDJCs04P4KvdHU_aem_crzN-UmKO3AHcovuTaJb2A	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEexXiic12kH8gWhMJwGks9cc5HdBPcH4oZ4920yvD4NcT9mHDJCs04P4KvdHU_aem_crzN-UmKO3AHcovuTaJb2A", "referrer": "http://m.facebook.com"}	2026-02-25 17:21:48	2026-02-25 17:21:48	2026-02-25 17:21:48
339	widget_loaded	cht_h83037ounmm1n8rnu	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-25 06:18:48	2026-02-25 06:18:49	2026-02-25 06:18:49
348	widget_loaded	cht_kxtr8pieemm1r5yhy	1	\N	\N	http://127.0.0.1:5500/index.html	http://127.0.0.1:5500/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://127.0.0.1:5500/index.html", "referrer": ""}	2026-02-25 08:08:36	2026-02-25 08:08:36	2026-02-25 08:08:36
380	widget_loaded	cht_ayzti57admm2b14sb	1	\N	\N	https://www.michaelmunavu.com/project/?id=16	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=16", "referrer": ""}	2026-02-25 17:24:44	2026-02-25 17:24:45	2026-02-25 17:24:45
387	widget_loaded	cht_hhi99sehomm30gqz8	2	\N	\N	https://gs1kenya.org/hubdashboard	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/hubdashboard", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-26 05:16:50	2026-02-26 05:16:50	2026-02-26 05:16:50
341	widget_loaded	cht_gyevrjlgemm1o0ee6	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-25 06:40:18	2026-02-25 06:40:18	2026-02-25 06:40:18
342	widget_loaded	cht_6d2rzszsfmm1osnbb	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-25 07:02:16	2026-02-25 07:02:16	2026-02-25 07:02:16
346	widget_loaded	cht_9wjb26424mm1qekqv	1	\N	\N	https://www.michaelmunavu.com/project/?id=15	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=15", "referrer": "https://www.michaelmunavu.com/"}	2026-02-25 07:47:18	2026-02-25 07:47:18	2026-02-25 07:47:18
349	widget_loaded	cht_nna7on71imm1r635y	1	\N	\N	http://127.0.0.1:5500/project/?id=16	http://127.0.0.1:5500/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://127.0.0.1:5500/project/?id=16", "referrer": "http://127.0.0.1:5500/index.html"}	2026-02-25 08:08:41	2026-02-25 08:08:42	2026-02-25 08:08:42
356	widget_loaded	cht_v1blwdq5emm1v6vyo	1	\N	\N	https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEe4_eAZbEdzZ7islZJDkuHb_L0goZSl0hdMWzqF5NMw8pXtuKaY-vQzQn28EU_aem_7UqMd1aZqub7a75SihfyMg	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/?fbclid=IwZXh0bgNhZW0CMTEAc3J0YwZhcHBfaWQMMjU2MjgxMDQwNTU4AAEe4_eAZbEdzZ7islZJDkuHb_L0goZSl0hdMWzqF5NMw8pXtuKaY-vQzQn28EU_aem_7UqMd1aZqub7a75SihfyMg", "referrer": "http://m.facebook.com"}	2026-02-25 10:01:17	2026-02-25 10:01:18	2026-02-25 10:01:18
361	widget_loaded	cht_rulam8iddmm20ao8n	1	\N	\N	http://michaelmunavu.com/project/?id=16	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/project/?id=16", "referrer": ""}	2026-02-25 12:24:15	2026-02-25 12:24:16	2026-02-25 12:24:16
362	widget_loaded	cht_tcsgwpsmjmm21dqui	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "http://localhost:4600/"}	2026-02-25 12:54:35	2026-02-25 12:54:37	2026-02-25 12:54:37
369	widget_loaded	cht_eavl56oeemm23mmk5	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-25 13:57:29	2026-02-25 13:57:29	2026-02-25 13:57:29
375	widget_loaded	cht_fcmv6pdymmm286xnp	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-25 16:05:14	2026-02-25 16:05:14	2026-02-25 16:05:14
379	widget_loaded	cht_exjgsvtmemm2azkpj	1	\N	\N	https://www.michaelmunavu.com/project/?id=10	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=10", "referrer": ""}	2026-02-25 17:23:31	2026-02-25 17:23:33	2026-02-25 17:23:33
381	widget_loaded	cht_oaajnfswpmm19pmqd	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7559.132 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-25 00:00:00	2026-02-25 18:46:43	2026-02-25 18:46:43
384	widget_loaded	cht_oaajnfswpmm2y63c7	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7559.132 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 04:12:25	2026-02-26 04:12:28	2026-02-26 04:12:28
344	widget_loaded	cht_aevgfy8qdmm1q9roc	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-25 07:43:34	2026-02-25 07:43:35	2026-02-25 07:43:35
371	widget_loaded	cht_f46l240m4mm23xeuh	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": "https://www.thestageyard.com/"}	2026-02-25 14:05:53	2026-02-25 14:05:53	2026-02-25 14:05:53
373	widget_loaded	cht_3apxiy2gvmm24al6c	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": "https://ke.linkedin.com/"}	2026-02-25 14:16:07	2026-02-25 14:16:08	2026-02-25 14:16:08
382	widget_loaded	cht_0b2cav5zcmm2jytqs	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-25 21:34:53	2026-02-25 21:34:53	2026-02-25 21:34:53
350	widget_loaded	cht_rzg9o7xz7mm1r6byc	1	\N	\N	http://127.0.0.1:5500/	http://127.0.0.1:5500/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://127.0.0.1:5500/", "referrer": "http://127.0.0.1:5500/project/?id=16"}	2026-02-25 08:08:53	2026-02-25 08:08:53	2026-02-25 08:08:53
352	widget_loaded	cht_y1lpmuwszmm1scjhw	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-25 08:41:43	2026-02-25 08:41:44	2026-02-25 08:41:44
354	widget_loaded	cht_32bbq035fmm1taa3b	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-25 09:07:58	2026-02-25 09:07:58	2026-02-25 09:07:58
351	widget_loaded	cht_5soeuvehdmm1s51ks	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-25 08:35:53	2026-02-25 08:35:55	2026-02-25 08:35:55
353	widget_loaded	cht_do4nvbszjmm1she8z	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-25 08:45:32	2026-02-25 08:45:33	2026-02-25 08:45:33
363	widget_loaded	cht_tp6jq3i24mm21dvho	2	\N	\N	http://localhost:4600/panel	http://localhost:4600/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:4600/panel", "referrer": ""}	2026-02-25 12:54:42	2026-02-25 12:54:43	2026-02-25 12:54:43
364	widget_loaded	cht_zckuqcltxmm22hhgc	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-25 13:25:30	2026-02-25 13:25:30	2026-02-25 13:25:30
370	widget_loaded	cht_8dn6gedhimm23ntvu	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-25 13:58:25	2026-02-25 13:58:25	2026-02-25 13:58:25
372	widget_loaded	cht_hfwu5h1qwmm23zhfh	1	\N	\N	https://www.michaelmunavu.com/portfolio/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/portfolio/", "referrer": "https://www.michaelmunavu.com/"}	2026-02-25 14:07:29	2026-02-25 14:07:29	2026-02-25 14:07:29
385	widget_loaded	cht_jxuve5tsbmm2ztheq	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-26 04:58:36	2026-02-26 04:58:37	2026-02-26 04:58:37
366	widget_loaded	cht_j3jqckqsomm22vj9y	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-25 13:36:25	2026-02-25 13:36:25	2026-02-25 13:36:25
367	widget_loaded	cht_khcez2mcxmm23jjnj	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.google.com/"}	2026-02-25 13:55:05	2026-02-25 13:55:06	2026-02-25 13:55:06
377	widget_loaded	cht_c77h9a2p6mm28ov0z	1	\N	\N	http://www.michaelmunavu.com/project/?id=16	http://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://www.michaelmunavu.com/project/?id=16", "referrer": ""}	2026-02-25 16:19:13	2026-02-25 16:19:15	2026-02-25 16:19:15
389	widget_loaded	cht_rv1zejye3mm312jq1	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-26 05:33:39	2026-02-26 05:33:40	2026-02-26 05:33:40
383	widget_loaded	cht_7ceq5nb6tmm2pgw1f	1	\N	\N	http://michaelmunavu.com/project/?id=3	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/project/?id=3", "referrer": ""}	2026-02-26 00:08:54	2026-02-26 00:08:55	2026-02-26 00:08:55
386	widget_loaded	cht_dxb5hdql0mm30dta0	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 05:14:25	2026-02-26 05:14:25	2026-02-26 05:14:25
388	widget_loaded	cht_dmoxtsc06mm30q74d	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-26 05:24:19	2026-02-26 05:24:19	2026-02-26 05:24:19
390	widget_loaded	cht_ewbug1wk1mm2p5hct	1	\N	\N	https://www.michaelmunavu.com/contact/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7559.132 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/contact/", "referrer": ""}	2026-02-26 00:00:00	2026-02-26 05:39:08	2026-02-26 05:39:08
391	widget_loaded	cht_bbkrpgqc3mm328q79	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-26 06:06:30	2026-02-26 06:06:30	2026-02-26 06:06:30
392	widget_loaded	cht_aai555y2lmm32b8fs	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/panel"}	2026-02-26 06:08:24	2026-02-26 06:08:23	2026-02-26 06:08:23
393	widget_loaded	cht_nekn1zw6nmm32fuir	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-26 06:12:01	2026-02-26 06:12:01	2026-02-26 06:12:01
394	widget_loaded	cht_c3iyiytw1mm32iey8	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-26 06:13:58	2026-02-26 06:13:59	2026-02-26 06:13:59
395	widget_loaded	cht_2q761ohcpmm32mkog	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.google.com/"}	2026-02-26 06:17:18	2026-02-26 06:17:19	2026-02-26 06:17:19
396	widget_loaded	cht_kk470u6qwmm330oep	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-26 06:28:11	2026-02-26 06:28:13	2026-02-26 06:28:13
397	widget_loaded	cht_8xxqv5o6fmm33hdl8	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-26 06:41:10	2026-02-26 06:41:10	2026-02-26 06:41:10
398	widget_loaded	cht_o13xnansvmm35clqd	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-26 07:33:27	2026-02-26 07:33:27	2026-02-26 07:33:27
399	widget_loaded	cht_t0hse3whwmm35l34i	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:148.0) Gecko/20100101 Firefox/148.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-26 07:40:03	2026-02-26 07:40:04	2026-02-26 07:40:04
400	widget_loaded	cht_kwlkzorflmm36cdti	2	\N	\N	http://localhost:9100/panel	http://localhost:9100/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://localhost:9100/panel", "referrer": ""}	2026-02-26 08:01:16	2026-02-26 08:01:16	2026-02-26 08:01:16
401	widget_loaded	cht_r512i87pymm36or0a	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-26 08:10:56	2026-02-26 08:10:56	2026-02-26 08:10:56
402	widget_loaded	cht_2mic7tp4kmm37h5vl	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-26 08:32:59	2026-02-26 08:32:59	2026-02-26 08:32:59
403	widget_loaded	cht_ru5bidy3zmm39kpnd	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-26 09:31:43	2026-02-26 09:31:44	2026-02-26 09:31:44
404	widget_loaded	cht_8disox3ekmm39lujs	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-26 09:32:37	2026-02-26 09:32:37	2026-02-26 09:32:37
405	widget_loaded	cht_b33fnpei3mm3bivmh	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-26 10:26:17	2026-02-26 10:26:17	2026-02-26 10:26:17
406	widget_loaded	cht_y40rqpeshmm3bldqz	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-26 10:28:16	2026-02-26 10:28:17	2026-02-26 10:28:17
407	widget_loaded	cht_jxyebwf4xmm3d1bic	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 11:08:37	2026-02-26 11:08:38	2026-02-26 11:08:38
408	widget_loaded	cht_oaajnfswpmm3feoe0	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7559.132 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 12:14:59	2026-02-26 12:15:02	2026-02-26 12:15:02
409	widget_loaded	cht_p9onkxkurmm3gqzxj	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.86 Safari/537.36 BitSightBot/1.0	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 12:52:33	2026-02-26 12:52:33	2026-02-26 12:52:33
415	widget_loaded	cht_4yfirv3p0mm3itex5	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:148.0) Gecko/20100101 Firefox/148.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-26 13:50:26	2026-02-26 13:50:27	2026-02-26 13:50:27
418	widget_loaded	cht_brcncwcuzmm3mdn24	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 15:30:12	2026-02-26 15:30:13	2026-02-26 15:30:13
419	widget_loaded	cht_5o6g0n7z4mm3mevll	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 15:31:06	2026-02-26 15:31:06	2026-02-26 15:31:06
424	widget_loaded	cht_r7d5fi6dwmm3vrddd	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 19:52:45	2026-02-26 19:52:45	2026-02-26 19:52:45
427	widget_loaded	cht_4i0gvjub1mm3wz0wy	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/28.0 Chrome/130.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 20:26:42	2026-02-26 20:26:42	2026-02-26 20:26:42
457	widget_loaded	cht_h8knchrykmm4i3lgg	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 06:18:07	2026-02-27 06:18:07	2026-02-27 06:18:07
459	widget_loaded	cht_1seqd10bqmm4itdf1	2	\N	\N	https://gs1kenya.org/live_dash	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/live_dash", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-27 06:38:15	2026-02-27 06:38:31	2026-02-27 06:38:31
464	widget_loaded	cht_zga437pa9mm4l0pb0	2	\N	\N	http://gs1kenya.org/panel	http://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://gs1kenya.org/panel", "referrer": "http://gs1kenya.org/panel"}	2026-02-27 07:39:51	2026-02-27 07:39:53	2026-02-27 07:39:53
467	widget_loaded	cht_ms2170q83mm4lgn97	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 07:52:16	2026-02-27 07:52:14	2026-02-27 07:52:14
469	chat_opened	cht_ms2170q83mm4lgn97	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"has_email": false, "messages_count": 1}	2026-02-27 07:52:21	2026-02-27 07:52:19	2026-02-27 07:52:19
471	message_received	cht_ms2170q83mm4lgn97	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"response_time": 2000, "human_takeover": false, "response_length": 160}	2026-02-27 07:52:32	2026-02-27 07:52:31	2026-02-27 07:52:31
410	widget_loaded	cht_aglsurr1dmm3hbn90	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-26 13:08:38	2026-02-26 13:08:38	2026-02-26 13:08:38
422	widget_loaded	cht_lnxhwhhu6mm3quex3	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7559.132 Mobile Safari/537.36 (compatible; GoogleOther)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 17:35:09	2026-02-26 17:35:20	2026-02-26 17:35:20
426	chat_opened	cht_49991ij9vmm3wxu0y	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/28.0 Chrome/130.0.0.0 Mobile Safari/537.36	127.0.0.1	{"has_email": false, "messages_count": 1}	2026-02-26 20:26:32	2026-02-26 20:26:33	2026-02-26 20:26:33
429	widget_loaded	cht_fsonbomivmm3xulrl	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 20:51:17	2026-02-26 20:51:17	2026-02-26 20:51:17
440	widget_loaded	cht_qouys587emm40vnpk	1	\N	\N	https://www.michaelmunavu.com/portfolio/	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/portfolio/", "referrer": ""}	2026-02-26 22:16:05	2026-02-26 22:16:06	2026-02-26 22:16:06
449	widget_loaded	cht_vnlbhmht7mm4j00gk	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 15; 23129RAA4G Build/AQ3A.240829.003; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.121 Mobile Safari/537.36 musical_ly_2024308030 AppName/musical_ly ByteLocale/en-GB	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 06:43:20	2026-02-27 05:44:06	2026-02-27 05:44:06
458	widget_loaded	cht_gpbzjnzglmm4i6wae	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; HD1900 Build/QKQ1.190716.003; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/75.0.3770.156 Mobile Safari/537.36  aweme_230400 JsSdk/1.0 NetType/WIFI  AppName/aweme app_version/23.4.0 ByteLocale/zh-CN Region/CN AppSkin/white AppTheme/light BytedanceWebview/d8a21c6 WebView/075113004008	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 06:20:45	2026-02-27 06:20:46	2026-02-27 06:20:46
463	widget_loaded	cht_f7ncsq9ejmm4kuw97	2	\N	\N	http://gs1kenya.org/phones	http://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://gs1kenya.org/phones", "referrer": "http://gs1kenya.org/member/login/portal"}	2026-02-27 07:35:24	2026-02-27 07:35:26	2026-02-27 07:35:26
411	widget_loaded	cht_q8fa9smobmm3hcsp8	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-26 13:09:30	2026-02-26 13:09:30	2026-02-26 13:09:30
417	widget_loaded	cht_fv1whh6s7mm2p5hcv	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7559.132 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 00:00:00	2026-02-26 15:28:59	2026-02-26 15:28:59
430	widget_loaded	cht_2c88d97o2mm3xwax8	1	\N	\N	https://www.michaelmunavu.com/project/?id=16	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=16", "referrer": "https://www.michaelmunavu.com/"}	2026-02-26 20:52:35	2026-02-26 20:52:36	2026-02-26 20:52:36
435	widget_loaded	cht_206kh3l4imm3yiftz	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-26 21:09:48	2026-02-26 21:09:49	2026-02-26 21:09:49
439	widget_loaded	cht_5l9hazo5fmm3zbr8f	1	\N	\N	https://www.michaelmunavu.com/project/?id=15	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=15", "referrer": "https://www.michaelmunavu.com/project/?id=16"}	2026-02-26 21:32:35	2026-02-26 21:32:37	2026-02-26 21:32:37
442	widget_loaded	cht_0cxnlf67emm4b6g8e	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 03:04:24	2026-02-27 03:04:24	2026-02-27 03:04:24
466	widget_loaded	cht_rtvhkxjv8mm4ld63h	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-27 07:49:33	2026-02-27 07:49:33	2026-02-27 07:49:33
473	message_received	cht_ms2170q83mm4lgn97	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"response_time": 2000, "human_takeover": false, "response_length": 347}	2026-02-27 07:52:49	2026-02-27 07:52:47	2026-02-27 07:52:47
412	widget_loaded	cht_j3sm78evvmm3himun	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-26 13:14:04	2026-02-26 13:14:03	2026-02-26 13:14:03
425	widget_loaded	cht_49991ij9vmm3wxu0y	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/28.0 Chrome/130.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 20:25:47	2026-02-26 20:25:48	2026-02-26 20:25:48
428	widget_loaded	cht_z4dt8bb8dmm3xevjw	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 20:39:03	2026-02-26 20:39:04	2026-02-26 20:39:04
437	widget_loaded	cht_78l833kflmm3zadfi	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": "https://www.linkedin.com/"}	2026-02-26 21:31:31	2026-02-26 21:31:34	2026-02-26 21:31:34
450	widget_loaded	cht_01ppfcu27mm4gvxc2	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; M2006C3MNG Build/QP1A.190711.020; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/87.0.4280.101 Mobile Safari/537.36 musical_ly_2023102050 JsSdk/1.0 NetType/4G Channel/googleplay AppName/musical_ly app_version/31.2.5 ByteLocale/ru-RU ByteFullLocale/ru-RU Region/US Spark/1.4.0.8-bugfix AppVersion/31.2.5 BytedanceWebview/d8a21c6	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 05:44:18	2026-02-27 05:44:19	2026-02-27 05:44:19
452	widget_loaded	cht_8s5aeoxm4mm4h6cnj	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-27 05:52:19	2026-02-27 05:52:20	2026-02-27 05:52:20
454	widget_loaded	cht_e3juqoeenmm4jboqi	1	\N	\N	https://www.michaelmunavu.com/portfolio/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 15; 23129RAA4G Build/AQ3A.240829.003; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.121 Mobile Safari/537.36 musical_ly_2024308030 AppName/musical_ly ByteLocale/en-GB	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/portfolio/", "referrer": "https://www.michaelmunavu.com/"}	2026-02-27 06:52:24	2026-02-27 05:53:09	2026-02-27 05:53:09
460	widget_loaded	cht_tgq2s9pqhmm4iv9ar	1	\N	\N	http://michaelmunavu.com/about/	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/about/", "referrer": ""}	2026-02-27 06:39:39	2026-02-27 06:39:41	2026-02-27 06:39:41
414	widget_loaded	cht_l8y04fwz1mm3iodw8	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-26 13:46:30	2026-02-26 13:46:31	2026-02-26 13:46:31
438	widget_loaded	cht_covkz2y9nmm3zaxrp	1	\N	\N	https://www.michaelmunavu.com/project/?id=16	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=16", "referrer": "https://www.michaelmunavu.com/"}	2026-02-26 21:31:57	2026-02-26 21:31:59	2026-02-26 21:31:59
445	widget_loaded	cht_w1rfb1f9mmm4czxah	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 03:55:18	2026-02-27 03:55:19	2026-02-27 03:55:19
453	widget_loaded	cht_nv6xatydsmm4jatpw	1	\N	\N	https://www.michaelmunavu.com/project/?id=11	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 15; 23129RAA4G Build/AQ3A.240829.003; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.121 Mobile Safari/537.36 musical_ly_2024308030 AppName/musical_ly ByteLocale/en-GB	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=11", "referrer": "https://www.michaelmunavu.com/portfolio/"}	2026-02-27 06:51:44	2026-02-27 05:52:30	2026-02-27 05:52:30
461	widget_loaded	cht_mu6tmtvjpmm4iy5iz	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-27 06:41:53	2026-02-27 06:41:55	2026-02-27 06:41:55
462	widget_loaded	cht_sfg054hw5mm4k4e7x	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-27 07:14:44	2026-02-27 07:14:45	2026-02-27 07:14:45
416	widget_loaded	cht_fv1whh6s7mm3l0ce7	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 14:51:48	2026-02-26 14:52:12	2026-02-26 14:52:12
420	widget_loaded	cht_yrc68i951mm3pp6oq	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 17:03:07	2026-02-26 17:03:08	2026-02-26 17:03:08
465	widget_loaded	cht_viau3fjdrmm4lcchu	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 07:48:55	2026-02-27 07:48:55	2026-02-27 07:48:55
421	widget_loaded	cht_9vu6evf9jmm3qtd85	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-26 17:34:21	2026-02-26 17:34:21	2026-02-26 17:34:21
432	widget_loaded	cht_xzo0neiy0mm3xy1aq	1	\N	\N	https://www.michaelmunavu.com/project/?id=15	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=15", "referrer": "https://www.michaelmunavu.com/"}	2026-02-26 20:53:55	2026-02-26 20:53:55	2026-02-26 20:53:55
456	chat_opened	cht_v6hntrl8omm4jbu29	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 15; 23129RAA4G Build/AQ3A.240829.003; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.121 Mobile Safari/537.36 musical_ly_2024308030 AppName/musical_ly ByteLocale/en-GB	127.0.0.1	{"has_email": false, "messages_count": 1}	2026-02-27 06:52:33	2026-02-27 05:53:19	2026-02-27 05:53:19
423	widget_loaded	cht_ztwmu04gimm3tzgiy	1	\N	\N	http://www.michaelmunavu.com/project/?id=3	http://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://www.michaelmunavu.com/project/?id=3", "referrer": ""}	2026-02-26 19:03:05	2026-02-26 19:03:06	2026-02-26 19:03:06
443	widget_loaded	cht_v54b1hd89mm4b6yyk	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 03:04:47	2026-02-27 03:04:47	2026-02-27 03:04:47
444	widget_loaded	cht_wvynoyxiqmm4cax3e	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 03:35:56	2026-02-27 03:35:58	2026-02-27 03:35:58
448	widget_loaded	cht_m6rvhik5pmm4gfdyg	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member_details/5081/barcodes"}	2026-02-27 05:31:18	2026-02-27 05:31:20	2026-02-27 05:31:20
470	message_sent	cht_ms2170q83mm4lgn97	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"has_email": false, "message_count": 1, "message_length": 6, "session_duration_seconds": 12}	2026-02-27 07:52:27	2026-02-27 07:52:25	2026-02-27 07:52:25
472	message_sent	cht_ms2170q83mm4lgn97	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"has_email": false, "message_count": 2, "message_length": 11, "session_duration_seconds": 30}	2026-02-27 07:52:45	2026-02-27 07:52:43	2026-02-27 07:52:43
431	widget_loaded	cht_od1z7aqcmmm3xxqad	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 20:53:41	2026-02-26 20:53:41	2026-02-26 20:53:41
446	widget_loaded	cht_syv0ywkffmm4fdvik	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-27 05:02:08	2026-02-27 05:02:10	2026-02-27 05:02:10
447	widget_loaded	cht_9v67aqr24mm4gece2	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-27 05:30:30	2026-02-27 05:30:31	2026-02-27 05:30:31
451	widget_loaded	cht_2hhtesukqmm4j4rlk	1	\N	\N	https://www.michaelmunavu.com/portfolio/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 15; 23129RAA4G Build/AQ3A.240829.003; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.121 Mobile Safari/537.36 musical_ly_2024308030 AppName/musical_ly ByteLocale/en-GB	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/portfolio/", "referrer": "https://www.michaelmunavu.com/"}	2026-02-27 06:47:02	2026-02-27 05:47:47	2026-02-27 05:47:47
433	widget_loaded	cht_3k43txzbomm3xz5fh	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 20:54:47	2026-02-26 20:54:47	2026-02-26 20:54:47
434	widget_loaded	cht_coo8jfw26mm3y9vqp	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (iPhone; CPU iPhone OS 26_3_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/145.0.7632.108 Mobile/15E148 Safari/604.1	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 21:03:08	2026-02-26 21:03:08	2026-02-26 21:03:08
436	widget_loaded	cht_2cp1d2evlmm3yuin0	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-26 21:19:12	2026-02-26 21:19:12	2026-02-26 21:19:12
441	widget_loaded	cht_k7lybyqizmm42xoct	1	\N	\N	http://michaelmunavu.com/project/?id=3	http://michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://michaelmunavu.com/project/?id=3", "referrer": ""}	2026-02-26 23:13:39	2026-02-26 23:13:41	2026-02-26 23:13:41
455	widget_loaded	cht_v6hntrl8omm4jbu29	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 15; 23129RAA4G Build/AQ3A.240829.003; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/145.0.7632.121 Mobile Safari/537.36 musical_ly_2024308030 AppName/musical_ly ByteLocale/en-GB	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 06:52:31	2026-02-27 05:53:16	2026-02-27 05:53:16
468	widget_loaded	cht_l3nt18vgkmm4lgp7u	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-27 07:52:18	2026-02-27 07:52:19	2026-02-27 07:52:19
474	chat_closed	cht_ms2170q83mm4lgn97	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36	127.0.0.1	{"user_messages": 2, "messages_exchanged": 5, "session_duration_seconds": 52}	2026-02-27 07:53:07	2026-02-27 07:53:05	2026-02-27 07:53:05
475	widget_loaded	cht_80qwszymzmm4liib4	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/135.0.7049.53 Mobile/15E148 Safari/604.1	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 07:53:42	2026-02-27 07:53:43	2026-02-27 07:53:43
476	chat_opened	cht_80qwszymzmm4liib4	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/135.0.7049.53 Mobile/15E148 Safari/604.1	127.0.0.1	{"has_email": false, "messages_count": 1}	2026-02-27 07:53:43	2026-02-27 07:53:44	2026-02-27 07:53:44
477	message_sent	cht_80qwszymzmm4liib4	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/135.0.7049.53 Mobile/15E148 Safari/604.1	127.0.0.1	{"has_email": false, "message_count": 1, "message_length": 3, "session_duration_seconds": 10}	2026-02-27 07:53:52	2026-02-27 07:53:52	2026-02-27 07:53:52
478	message_received	cht_80qwszymzmm4liib4	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/135.0.7049.53 Mobile/15E148 Safari/604.1	127.0.0.1	{"response_time": 2000, "human_takeover": false, "response_length": 164}	2026-02-27 07:53:58	2026-02-27 07:53:58	2026-02-27 07:53:58
479	widget_loaded	cht_sd3pk6zh6mm4m5cdk	2	\N	\N	http://gs1kenya.org/panel	http://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://gs1kenya.org/panel", "referrer": "http://gs1kenya.org/hrm_dashboard"}	2026-02-27 08:11:27	2026-02-27 08:11:29	2026-02-27 08:11:29
480	widget_loaded	cht_ocrz8nodemm4mfj5q	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.2 Mobile/15E148 Safari/604.1	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 08:19:23	2026-02-27 08:19:25	2026-02-27 08:19:25
481	widget_loaded	cht_3wnz96gwgmm4n22kk	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/135.0.7049.53 Mobile/15E148 Safari/604.1	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 08:36:54	2026-02-27 08:36:55	2026-02-27 08:36:55
482	widget_loaded	cht_c67q6awysmm4n8bql	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-27 08:41:46	2026-02-27 08:41:46	2026-02-27 08:41:46
483	widget_loaded	cht_w7yij20i0mm4ntre1	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-27 08:58:26	2026-02-27 08:58:28	2026-02-27 08:58:28
484	widget_loaded	cht_kwattyyetmm4oimxt	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-27 09:17:47	2026-02-27 09:17:47	2026-02-27 09:17:47
485	widget_loaded	cht_zkrz2jkh5mm4otiiw	1	\N	\N	http://www.michaelmunavu.com/project/?id=10	http://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "http://www.michaelmunavu.com/project/?id=10", "referrer": ""}	2026-02-27 09:26:15	2026-02-27 09:26:17	2026-02-27 09:26:17
486	widget_loaded	cht_t2tphql45mm4pvmev	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-27 09:55:53	2026-02-27 09:55:53	2026-02-27 09:55:53
487	widget_loaded	cht_78ivqxtuomm4q5hm8	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": "https://app.callwisely.ai/"}	2026-02-27 10:03:33	2026-02-27 10:03:34	2026-02-27 10:03:34
488	widget_loaded	cht_hk93ez40kmm4q68gw	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": "https://app.callwisely.ai/"}	2026-02-27 10:04:07	2026-02-27 10:04:07	2026-02-27 10:04:07
504	widget_loaded	cht_dj4v74qvzmm4trt1v	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 11:44:53	2026-02-27 11:44:54	2026-02-27 11:44:54
506	widget_loaded	cht_yo0utal92mm4vi5i4	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-27 12:33:36	2026-02-27 12:33:37	2026-02-27 12:33:37
512	widget_loaded	cht_3uwj46hkimm4wwugn	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-27 13:12:55	2026-02-27 13:12:54	2026-02-27 13:12:54
514	widget_loaded	cht_r2nhn0brwmm4x0fow	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/performance/19"}	2026-02-27 13:15:34	2026-02-27 13:15:32	2026-02-27 13:15:32
523	widget_loaded	cht_uusfqb2demm4zrbd5	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": "https://www.thestageyard.com/"}	2026-02-27 14:32:28	2026-02-27 14:32:29	2026-02-27 14:32:29
535	widget_loaded	cht_rcfjhse8zmm5v6hee	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1 (compatible; Baiduspider-render/2.0; +http://www.baidu.com/search/spider.html)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-28 05:12:05	2026-02-28 05:12:07	2026-02-28 05:12:07
539	widget_loaded	cht_k2j4b6862mm603ytr	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-28 07:30:03	2026-02-28 07:30:03	2026-02-28 07:30:03
541	widget_loaded	cht_jt1shhsqfmm60nw9k	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 5.0) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; Bytespider; https://zhanzhang.toutiao.com/)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-28 07:45:34	2026-02-28 07:45:35	2026-02-28 07:45:35
548	widget_loaded	cht_jtptbfkq1mm6uss4g	1	\N	\N	https://www.michaelmunavu.com/project/?id=8	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=8", "referrer": ""}	2026-02-28 21:49:11	2026-02-28 21:49:13	2026-02-28 21:49:13
489	widget_loaded	cht_m8p0380slmm4q8p7i	2	\N	\N	https://gs1kenya.org/member_details	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/member_details", "referrer": "https://gs1kenya.org/"}	2026-02-27 10:06:03	2026-02-27 10:06:02	2026-02-27 10:06:02
498	widget_loaded	cht_5vycha6eumm4r50v6	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-27 10:31:11	2026-02-27 10:31:11	2026-02-27 10:31:11
515	widget_loaded	cht_xpsc2e2jgmm4xrtis	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-27 13:36:52	2026-02-27 13:36:55	2026-02-27 13:36:55
531	widget_loaded	cht_oiw9gbc45mm5001i8	1	\N	\N	https://www.michaelmunavu.com/project/?id=10	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=10", "referrer": "https://www.michaelmunavu.com/"}	2026-02-27 14:39:15	2026-02-27 14:39:17	2026-02-27 14:39:17
533	widget_loaded	cht_91pyrwz1umm59a9d7	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Mobile/15E148 Safari/604.1	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 18:59:08	2026-02-27 18:59:08	2026-02-27 18:59:08
542	widget_loaded	cht_nczetzs79mm62gou8	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-28 08:36:12	2026-02-28 08:36:15	2026-02-28 08:36:15
544	widget_loaded	cht_h4gsuzafqmm65y872	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:148.0) Gecko/20100101 Firefox/148.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-28 10:13:34	2026-02-28 10:13:35	2026-02-28 10:13:35
490	widget_loaded	cht_nklwh12temm4qd48z	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 10:09:29	2026-02-27 10:09:30	2026-02-27 10:09:30
491	widget_loaded	cht_tst5frmewmm4qjq0b	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": "https://app.callwisely.ai/"}	2026-02-27 10:14:37	2026-02-27 10:14:37	2026-02-27 10:14:37
507	widget_loaded	cht_bhsnl9cuamm4vip3n	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-27 12:33:47	2026-02-27 12:33:47	2026-02-27 12:33:47
508	widget_loaded	cht_n29m1ux0zmm4vk0b5	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-27 12:34:49	2026-02-27 12:34:48	2026-02-27 12:34:48
513	widget_loaded	cht_9k21i3c0wmm4wx7z3	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/performance/18"}	2026-02-27 13:13:04	2026-02-27 13:13:02	2026-02-27 13:13:02
519	widget_loaded	cht_m3c0rsvrrmm4zmiwo	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 14:28:43	2026-02-27 14:28:43	2026-02-27 14:28:43
520	widget_loaded	cht_xzceiv4qtmm4zmmrv	11	\N	\N	https://www.michaelmunavu.com/contact/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/contact/", "referrer": ""}	2026-02-27 14:28:48	2026-02-27 14:28:49	2026-02-27 14:28:49
521	widget_loaded	cht_un85boazbmm4zmowu	1	\N	\N	https://www.michaelmunavu.com/about/	https://www.michaelmunavu.com/	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/about/", "referrer": ""}	2026-02-27 14:28:51	2026-02-27 14:28:51	2026-02-27 14:28:51
525	widget_loaded	cht_iwoml25srmm4zrxya	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": "https://www.thestageyard.com/"}	2026-02-27 14:32:57	2026-02-27 14:32:59	2026-02-27 14:32:59
527	widget_loaded	cht_ay8lb7dqvmm4zsp47	1	\N	\N	https://www.michaelmunavu.com/project/?id=15	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=15", "referrer": "https://www.michaelmunavu.com/"}	2026-02-27 14:33:31	2026-02-27 14:33:32	2026-02-27 14:33:32
534	widget_loaded	cht_rmxtwzx1dmm5b05fp	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-27 19:47:17	2026-02-27 19:47:18	2026-02-27 19:47:18
545	widget_loaded	cht_vpfvjx2qmmm6dhkf1	1	\N	\N	https://www.michaelmunavu.com/	\N	Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/136.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-28 13:44:33	2026-02-28 13:44:35	2026-02-28 13:44:35
546	widget_loaded	cht_2s3henbm7mm6jrr1k	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:148.0) Gecko/20100101 Firefox/148.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-28 16:40:28	2026-02-28 16:40:28	2026-02-28 16:40:28
547	widget_loaded	cht_x1ip3l2igmm6kr9dn	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-28 17:08:03	2026-02-28 17:08:05	2026-02-28 17:08:05
492	widget_loaded	cht_szvupbhmymm4ql0si	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-27 10:15:38	2026-02-27 10:15:37	2026-02-27 10:15:37
502	widget_loaded	cht_a8n8fx3a4mm4souqz	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 11:14:36	2026-02-27 11:14:37	2026-02-27 11:14:37
503	widget_loaded	cht_9hbet01hamm4st93x	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:148.0) Gecko/20100101 Firefox/148.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-27 11:18:01	2026-02-27 11:18:02	2026-02-27 11:18:02
518	widget_loaded	cht_u8eizriv3mm4yzb50	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 14:10:43	2026-02-27 14:10:44	2026-02-27 14:10:44
530	widget_loaded	cht_s5dbvq5p7mm4zxv8t	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": "https://www.michaelmunavu.com/"}	2026-02-27 14:37:33	2026-02-27 14:37:34	2026-02-27 14:37:34
493	widget_loaded	cht_mqsekxgb4mm4qlmot	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-27 10:16:05	2026-02-27 10:16:04	2026-02-27 10:16:04
496	widget_loaded	cht_nebc16uicmm4qqp18	2	\N	\N	http://102.220.22.83:4800/panel	http://102.220.22.83:4800/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "http://102.220.22.83:4800/panel", "referrer": "http://102.220.22.83:4800/users/log_in"}	2026-02-27 10:20:02	2026-02-27 10:20:03	2026-02-27 10:20:03
501	widget_loaded	cht_t4gje1v55mm4s7zdf	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 11:01:28	2026-02-27 11:01:27	2026-02-27 11:01:27
522	widget_loaded	cht_12tkfffg2mm4zqgky	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 14:31:48	2026-02-27 14:31:49	2026-02-27 14:31:49
528	widget_loaded	cht_vjjv4gk57mm4zuj1s	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": "https://www.thestageyard.com/"}	2026-02-27 14:34:57	2026-02-27 14:34:58	2026-02-27 14:34:58
532	widget_loaded	cht_nftfx95bwmm57gfwa	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-27 18:07:57	2026-02-27 18:07:58	2026-02-27 18:07:58
536	widget_loaded	cht_p1wmi0wn4mm5v6j4m	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (compatible; Baiduspider-render/2.0; +http://www.baidu.com/search/spider.html)	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-02-28 05:12:06	2026-02-28 05:12:08	2026-02-28 05:12:08
543	widget_loaded	cht_fluy4uqbpmm6539jc	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:148.0) Gecko/20100101 Firefox/148.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-28 09:49:30	2026-02-28 09:49:31	2026-02-28 09:49:31
494	widget_loaded	cht_jmda1vztbmm4qn40m	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-27 10:17:15	2026-02-27 10:17:16	2026-02-27 10:17:16
495	widget_loaded	cht_qs5h5djlsmm4qq812	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-27 10:19:40	2026-02-27 10:19:39	2026-02-27 10:19:39
526	widget_loaded	cht_qd1xe603emm4zsns1	1	\N	\N	https://www.michaelmunavu.com/project/?id=6	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=6", "referrer": "https://www.michaelmunavu.com/"}	2026-02-27 14:33:30	2026-02-27 14:33:30	2026-02-27 14:33:30
538	widget_loaded	cht_wa7rm14exmm5yavkx	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-28 06:39:28	2026-02-28 06:39:28	2026-02-28 06:39:28
497	widget_loaded	cht_kkt02pq32mm4r3cji	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-27 10:29:53	2026-02-27 10:29:53	2026-02-27 10:29:53
499	widget_loaded	cht_wcncspf35mm4r652b	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-27 10:32:03	2026-02-27 10:32:04	2026-02-27 10:32:04
500	widget_loaded	cht_d2mison0ymm4r660w	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/"}	2026-02-27 10:32:04	2026-02-27 10:32:04	2026-02-27 10:32:04
505	widget_loaded	cht_2e92uu991mm4v5rcu	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/23C71 Instagram 418.1.0.32.75 (iPhone13,2; iOS 26_2_1; en_GB; en-GB; scale=3.00; 1170x2532; IABMV/1; 890980569) Safari/604.1	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": "https://www.thestageyard.com/"}	2026-02-27 12:23:44	2026-02-27 12:23:44	2026-02-27 12:23:44
509	widget_loaded	cht_m3tk2d1y6mm4w9lcu	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-27 12:54:52	2026-02-27 12:55:08	2026-02-27 12:55:08
510	widget_loaded	cht_o7jdldiwimm4wbekg	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": ""}	2026-02-27 12:56:07	2026-02-27 12:56:06	2026-02-27 12:56:06
511	widget_loaded	cht_h6o90qstimm4wqd7g	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://www.gs1kenya.org/"}	2026-02-27 13:07:45	2026-02-27 13:07:46	2026-02-27 13:07:46
516	widget_loaded	cht_31g1x1g3tmm4xzy09	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-27 13:43:11	2026-02-27 13:43:11	2026-02-27 13:43:11
540	widget_loaded	cht_qg6bhvg2lmm60e5mb	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/users/log_in"}	2026-02-28 07:38:00	2026-02-28 07:38:00	2026-02-28 07:38:00
517	widget_loaded	cht_9hlx12qocmm4y2yqv	2	\N	\N	https://gs1kenya.org/panel	https://gs1kenya.org/	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:148.0) Gecko/20100101 Firefox/148.0	127.0.0.1	{"page_url": "https://gs1kenya.org/panel", "referrer": "https://gs1kenya.org/member/login/portal"}	2026-02-27 13:45:32	2026-02-27 13:45:33	2026-02-27 13:45:33
524	widget_loaded	cht_son09v3y7mm4zrl76	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": "https://www.thestageyard.com/"}	2026-02-27 14:32:40	2026-02-27 14:32:40	2026-02-27 14:32:40
529	widget_loaded	cht_5ajxqed1ymm4zuuth	1	\N	\N	https://www.michaelmunavu.com/about/	https://www.michaelmunavu.com/	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/about/", "referrer": "https://www.michaelmunavu.com/"}	2026-02-27 14:35:12	2026-02-27 14:35:13	2026-02-27 14:35:13
537	widget_loaded	cht_d3gwa034fmm5xlgnc	1	\N	\N	https://www.michaelmunavu.com/project/?id=10	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=10", "referrer": ""}	2026-02-28 06:19:42	2026-02-28 06:19:44	2026-02-28 06:19:44
549	widget_loaded	cht_b1p76ve2emm6wy1mq	1	\N	\N	https://www.michaelmunavu.com/project/?id=7	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/project/?id=7", "referrer": ""}	2026-02-28 22:49:16	2026-02-28 22:49:17	2026-02-28 22:49:17
550	widget_loaded	cht_cnk4ri4smmm7az5qg	1	\N	\N	https://www.michaelmunavu.com/	https://www.michaelmunavu.com/	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36	127.0.0.1	{"page_url": "https://www.michaelmunavu.com/", "referrer": ""}	2026-03-01 05:22:04	2026-03-01 05:22:05	2026-03-01 05:22:05
\.


--
-- Data for Name: chatbot_configs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chatbot_configs (id, product_id, is_enabled, welcome_message, chatbot_name, theme, primary_color, secondary_color, widget_position, custom_css, send_email_notifications, notification_emails, email_subject_template, collect_customer_email, response_delay, max_messages_per_session, enable_analytics, offline_message, always_available, business_hours_start, business_hours_end, timezone, embed_api_key, allowed_domains, inserted_at, updated_at) FROM stdin;
1	1	t	Hi! How can I help you today? 😊	Support Assistant	modern	#105efe	#051e4f	bottom-right	\N	f	\N	\N	f	2	50	t	We're currently offline. Please leave a message and we'll get back to you!	t	\N	\N	UTC	cb_e34671561d09d9e732948d9322bf67b0	\N	2026-02-19 12:34:29	2026-02-19 12:34:29
3	3	t	Hi! How can I help you today? 😊	Faiza	modern	#105efe	#051e4f	bottom-right	\N	f	\N	\N	f	2	50	f	We're currently offline. Please leave a message and we'll get back to you!	t	\N	\N	UTC	cb_f2098a148a881bfdbc75e4bbd5dbb339	\N	2026-02-19 13:27:16	2026-02-19 13:27:22
2	2	t	Hi! How can I help you today? 😊	Support Assistant	custom	#ff7800	#ff7800	bottom-right	\N	f	\N	\N	t	2	50	f	We're currently offline. Please leave a message and we'll get back to you!	t	\N	\N	UTC	cb_409acf5cf899586236c32771a39711d5	\N	2026-02-19 12:53:20	2026-02-19 13:31:13
4	11	t	Hi! How can I help you today? 😊	Assistant	modern	#105efe	#051e4f	bottom-right	\N	f	\N	\N	f	2	50	f	We're currently offline. Please leave a message and we'll get back to you!	t	\N	\N	UTC	cb_76b1c013a8047dd2a7cadd23390671cf	\N	2026-02-27 10:03:25	2026-02-27 10:04:04
\.


--
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contacts (id, email, name, source, status, subscribed_at, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: demo_configurations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.demo_configurations (id, user_phone_number, website_url, custom_context, company_name, scraped_content, ai_instructions, user_email, status, call_sid, demo_called_at, expires_at, inserted_at, updated_at, extracted_analysis) FROM stdin;
\.


--
-- Data for Name: generated_documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.generated_documents (id, product_id, user_id, workflow_execution_id, pending_approval_id, document_number, document_type, status, title, content_json, content_html, content_markdown, recipient_name, recipient_email, recipient_company, recipient_phone, currency, subtotal, tax_amount, discount_amount, total_amount, line_items, terms, notes, personalized_message, valid_from, valid_until, sent_at, sent_via, delivery_status, first_viewed_at, view_count, last_viewed_at, responded_at, response_type, response_notes, pdf_url, attachments, conversation_id, conversation_summary, version, parent_document_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: information_sources; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.information_sources (id, type, source, extracted_analysis, product_id, user_id, inserted_at, updated_at) FROM stdin;
1	website	https://gs1kenya.org	{"metadata": {"data_sources": ["https://gs1kenya.org", "https://gs1kenya.org/contacts", "https://gs1kenya.org/about", "https://gs1kenya.org/services", "https://gs1kenya.org/faqs", "https://gs1kenya.org/gs1/training", "https://gs1kenya.org/consultancy"], "missing_information": ["Founding year", "Employee count"]}, "analyzed_at": "2026-02-19T12:30:43.781070Z", "website_url": "https://gs1kenya.org", "scraped_urls": ["https://gs1kenya.org", "https://gs1kenya.org/contacts", "https://gs1kenya.org/about", "https://gs1kenya.org/images/company_profile.pdf", "https://gs1kenya.org/services", "https://gs1kenya.org/faqs", "https://gs1kenya.org#0", "https://gs1kenya.org/gs1/training", "https://gs1kenya.org/training-consultancy", "https://gs1kenya.org/consultancy"], "analysis_type": "comprehensive_synthesized", "pages_scraped": 10, "scraper_version": "5.4.0-customer-care", "customer_journey": {"support_model": "Ongoing support is provided through email, phone consultations, and scheduled follow-ups to assist clients in maximizing their use of GS1 standards.", "typical_questions": ["What services do you offer?", "How can I become a member?", "What are the benefits of GS1 standards?"], "onboarding_process": "New clients typically begin with an introductory consultation to understand their needs, followed by tailored training sessions and support in implementing GS1 standards."}, "comprehensive_faq": {"_data": [{"answer": "The membership fee includes a one-off joining fee and a recurring annual licence fee based on annual turnover.", "category": "Membership", "question": "What is the membership fee structure?"}]}, "products_services": [{"name": "Training Services", "category": "Training and Development", "use_cases": ["Employee onboarding for new standards", "Continuous professional development in supply chain management"], "description": "GS1 Kenya offers comprehensive training solutions including in-person, virtual training, and custom corporate training designed to empower businesses with the knowledge to implement GS1 standards effectively.", "key_features": ["In-Person Training: Hands-on sessions to enhance skills.", "E-Learning Portal: Flexible online learning options."], "pricing_summary": "Pricing details are not specified but may include membership fees and training costs.", "target_industries": ["Retail", "Manufacturing", "Logistics"]}, {"name": "Consultancy Services", "category": "Consulting", "use_cases": ["Implementing barcoding systems", "Improving traceability for product recalls"], "description": "GS1 Kenya provides expert consultancy services to help businesses optimize their supply chains through barcoding, data management, and traceability solutions.", "key_features": ["Supply Chain Optimization: Tailored strategies for efficiency.", "Data Quality Management: Ensuring accuracy in data handling."], "pricing_summary": "Consultancy pricing is based on project scope and client needs.", "target_industries": ["Food and Beverage", "Pharmaceuticals", "Consumer Goods"]}, {"name": "Consultancy Services", "category": "Barcoding Services", "use_cases": ["Implementing barcoding systems", "Improving traceability for product recalls"], "description": "GS1 Kenya provides expert barcodes services to help businesses optimize their supply chains through barcoding, data management, and traceability solutions.", "key_features": ["Supply Chain Optimization: Tailored strategies for efficiency.", "Data Quality Management: Ensuring accuracy in data handling."], "pricing_summary": "Consultancy pricing is based on project scope and client needs.", "target_industries": ["Food and Beverage", "Pharmaceuticals", "Consumer Goods"]}], "objection_handling": [{"category": "trust", "objection": "Why should I choose GS1 Kenya over other standards organizations?", "proof_points": ["GS1 standards are used by thousands of businesses globally.", "Success stories from local businesses that have improved efficiency."], "talking_points": ["GS1 Kenya is a recognized leader in supply chain standards.", "They provide tailored solutions that meet local and international needs."]}], "operational_details": {"business_hours": {"timezone": "EAT", "standard_hours": "Monday to Friday, 8:00 AM to 5:00 PM", "holiday_schedule": "Closed on public holidays"}}, "company_intelligence": {"name": "GS1 Kenya", "values": ["Integrity", "Innovation", "Collaboration"], "vision": "To be the trusted partner for businesses seeking to enhance their operational efficiency and product traceability.", "founded": "Year not specified", "history": "Founded to support businesses in implementing global standards, GS1 Kenya has evolved to offer a range of services including training, consultancy, and membership programs. The organization has played a pivotal role in enhancing supply chain management in Kenya.", "mission": "To drive efficiency and transparency in supply chains through global standards and innovative solutions.", "industry": "Information Technology and Standards", "locations": ["5th Floor, Room number 39, Nextgen Mall, Mombasa Road, Nairobi, Kenya"], "leadership": [], "description": "GS1 Kenya is a leading organization that provides standards and solutions to enhance efficiency in supply chains and business communication. They focus on traceability, data management solutions, and barcoding to help businesses optimize their operations. With a commitment to quality and compliance, GS1 Kenya empowers businesses to connect with consumers effectively and sustainably.", "company_size": "Medium-sized enterprise", "headquarters": "Nairobi, Kenya", "business_model": "B2B"}, "contact_intelligence": {"all_emails": ["info@gs1kenya.org"], "all_phones": ["+254 709226000", "+254 710122252"], "primary_email": "info@gs1kenya.org", "primary_phone": "+254 709226000", "_unused_all_emails": "", "physical_addresses": ["5th Floor, Room number 39, Nextgen Mall, Mombasa Road, Nairobi, Kenya", "P.O. Box 3243-00200, Nairobi, Kenya"], "_unused_primary_email": "", "_unused_primary_phone": "", "social_media_profiles": {"other": [{"url": "https://www.youtube.com/channel/UChMpKZMCVfOuWWc-a-Sb2YQ", "platform": "youtube"}], "twitter": "https://twitter.com/gs1kenya", "facebook": "https://www.facebook.com/gs1kenya.org/", "linkedin": "https://www.linkedin.com/company/gs1-kenya", "instagram": null}, "_unused_physical_addresses": ""}, "pricing_intelligence": {"all_plans": [{"name": "Membership Fee", "price": "Not specified", "limitations": [], "billing_cycle": "Annual", "target_customer": "Businesses seeking to implement GS1 standards", "included_features": ["One-off joining fee", "Recurring annual licence fee based on annual turnover"]}], "free_trial": {"duration": null, "available": false, "limitations": null}, "enterprise_pricing": {"available": true, "starting_price": "Not specified", "custom_features": []}, "pricing_philosophy": "GS1 Kenya adopts a value-based pricing approach, where fees are based on the value delivered through services and membership benefits."}, "portfolio_and_projects": {"summary": "GS1 Kenya works on various projects aimed at enhancing supply chain efficiency and product traceability.", "projects": [{"link": null, "name": "Shamba Ikonet", "description": "Connecting Farmers to Buyers through Trust, Traceability & Technology.", "technologies_used": []}, {"link": null, "name": "Archive Management", "description": "Organize Smarter. Retrieve Faster. Manage Records with Confidence.", "technologies_used": []}, {"link": null, "name": "Visitor Access Management", "description": "Smart Access. Verified Identity. Trusted Spaces.", "technologies_used": []}, {"link": null, "name": "Thamani Online", "description": "Smarter Supply Chains. Verified Products. Seamless Payments.", "technologies_used": []}, {"link": null, "name": "Sokopawa", "description": "Control and monitor your products with our integrated solutions.", "technologies_used": []}, {"link": null, "name": "Asset Management", "description": "Powered by GS1 Standards for Accuracy and Control.", "technologies_used": []}, {"link": null, "name": "Barcode Verification", "description": "Ensure Barcode Quality, Compliance & Global Readability.", "technologies_used": []}, {"link": null, "name": "Barcode Printing", "description": "Durable, High-Quality Labels You Can Trust.", "technologies_used": []}, {"link": null, "name": "Warehouse Management", "description": "Enhance Accuracy. Boost Efficiency. Gain Full Visibility.", "technologies_used": []}]}, "generated_agent_instructions": "You are an expert customer care representative for GS1 Kenya.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer."}	1	1	2026-02-19 12:29:38	2026-02-19 12:33:57
2	website	https://gs1kenya.org	{"metadata": {"data_sources": ["https://gs1kenya.org", "https://gs1kenya.org/contacts", "https://gs1kenya.org/about", "https://gs1kenya.org/services", "https://gs1kenya.org/faqs"], "missing_information": ["Year founded", "Company size specifics"]}, "analyzed_at": "2026-02-19T12:51:28.746613Z", "website_url": "https://gs1kenya.org", "scraped_urls": ["https://gs1kenya.org", "https://gs1kenya.org/contacts", "https://gs1kenya.org/about", "https://gs1kenya.org/images/company_profile.pdf", "https://gs1kenya.org/services", "https://gs1kenya.org/faqs", "https://gs1kenya.org#0", "https://gs1kenya.org/gs1/training", "https://gs1kenya.org/training-consultancy", "https://gs1kenya.org/consultancy"], "analysis_type": "comprehensive_synthesized", "pages_scraped": 10, "scraper_version": "5.4.0-customer-care", "customer_journey": {"support_model": "Ongoing support is available through email and phone, with dedicated consultants for members requiring in-depth assistance.", "typical_questions": ["How do I register my barcode?", "What are the benefits of membership?"], "onboarding_process": "Upon joining, members receive a welcome package that includes resources on how to utilize GS1 services effectively. Training sessions are scheduled based on the member's needs."}, "comprehensive_faq": [{"answer": "The membership fee includes a one-off joining fee and a recurring annual license fee based on your annual turnover.", "category": "Membership", "question": "What is included in the membership fee?"}, {"answer": "We offer in-person training, virtual training, and e-learning options tailored to various industry needs.", "category": "Training", "question": "What types of training do you offer?"}], "products_services": [{"name": "Training & Capacity Building", "category": "Training Services", "use_cases": ["Corporate training for businesses", "Skill enhancement for supply chain professionals"], "description": "GS1 Kenya offers comprehensive training programs designed to enhance the skills of professionals in areas like supply chain management, data quality, and barcoding. Their training is available in various formats including in-person, virtual, and e-learning.", "key_features": ["In-Person Training - Hands-on sessions to develop practical skills", "Virtual Training - Flexible online courses for remote learning"], "pricing_summary": "Pricing details vary based on training type and duration.", "target_industries": ["Retail", "Manufacturing", "Logistics"]}, {"name": "Consultancy Services", "category": "Consultancy", "use_cases": ["Improving operational efficiency", "Implementing traceability systems"], "description": "GS1 Kenya provides expert consultancy services to help businesses optimize their supply chains through the implementation of global standards and best practices.", "key_features": ["Supply Chain Optimization - Tailored solutions for enhanced efficiency", "Data Quality Management - Ensuring accuracy and reliability of data"], "pricing_summary": "Consultancy fees are customized based on project scope.", "target_industries": ["Food and Beverage", "Pharmaceuticals", "Consumer Goods"]}, {"name": "Membership Services", "category": "Membership", "use_cases": ["Businesses needing barcode registration", "Organizations looking to comply with global standards"], "description": "Joining GS1 Kenya as a member provides businesses with access to essential resources, including barcode numbers, compliance support, and networking opportunities.", "key_features": ["One-off joining fee - Initial cost to become a member", "Recurring annual license fee - Based on annual turnover"], "pricing_summary": "Membership includes a one-off joining fee and an annual license fee based on turnover.", "target_industries": ["All industries requiring barcoding"]}], "objection_handling": [{"category": "price", "objection": "The membership fee seems high.", "proof_points": ["Members report improved operational efficiency and compliance."], "talking_points": ["Membership provides access to essential resources and support.", "The fee is based on annual turnover, making it scalable."]}], "operational_details": {"business_hours": {"timezone": "EAT", "standard_hours": "Monday to Friday, 9 AM to 5 PM", "holiday_schedule": "Closed on public holidays"}}, "company_intelligence": {"name": "GS1 Kenya", "values": ["Integrity", "Innovation", "Collaboration"], "vision": "To be the trusted partner in supply chain solutions and a leader in providing standards for business communication.", "founded": "Year not specified", "history": "Founded to support businesses in Kenya, GS1 Kenya has been instrumental in promoting the use of barcodes and standards to enhance product traceability and supply chain management. The organization has evolved to offer a range of services and projects aimed at connecting various stakeholders in the supply chain.", "mission": "To enhance the efficiency and visibility of supply chains through the adoption of global standards.", "industry": "Standards and Technology Solutions", "locations": ["5th Floor, Room number 39, Nextgen Mall, Mombasa Road, Nairobi, Kenya"], "leadership": [{"name": "Arnold Polycarp Okello", "title": "CEO", "expertise": "Supply chain optimization, business consultancy", "background": "Extensive experience in supply chain management and standards implementation."}, {"name": "James Macharia", "title": "Director", "expertise": "Operational efficiency, project management", "background": "Expert in operational management and strategic planning."}, {"name": "Gerald O Nyamboga", "title": "Technical Manager", "expertise": "Technology integration, data management", "background": "Specializes in technology solutions for supply chains."}, {"name": "Paschal Kasimu", "title": "Training Manager", "expertise": "Training development, corporate education", "background": "Experienced in capacity building and training programs."}], "description": "GS1 Kenya is a leading organization focused on improving supply chain efficiency through global standards for business communication. They provide various services including training, consultancy, and membership to support businesses in areas like traceability, data management, and product identification. Their commitment to quality and compliance ensures that businesses can operate with confidence in a competitive marketplace.", "company_size": "50-100 employees", "headquarters": "Nairobi, Kenya", "business_model": "B2B/B2C"}, "contact_intelligence": {"all_emails": ["info@gs1kenya.org"], "all_phones": ["+254 709226000", "+254 710122252"], "primary_email": "info@gs1kenya.org", "primary_phone": "+254 709226000", "physical_addresses": ["5th Floor, Room number 39, Nextgen Mall, Mombasa Road, Nairobi, Kenya", "P.O. Box 3243-00200, Nairobi, Kenya"], "social_media_profiles": {"other": [{"url": "https://www.youtube.com/channel/UChMpKZMCVfOuWWc-a-Sb2YQ", "platform": "youtube"}], "twitter": "https://twitter.com/gs1kenya", "facebook": "https://www.facebook.com/gs1kenya.org/", "linkedin": "https://www.linkedin.com/company/gs1-kenya", "instagram": null}}, "pricing_intelligence": {"all_plans": [{"name": "Membership Fee", "price": null, "limitations": [], "billing_cycle": "annual", "target_customer": "Businesses needing barcode registration and compliance support", "included_features": ["One-off joining fee", "Recurring annual licence fee based on annual turnover"]}], "free_trial": {"available": false}, "enterprise_pricing": {"available": false}, "pricing_philosophy": "GS1 Kenya adopts a value-based pricing approach, ensuring that businesses get the best return on their investment through quality services."}, "portfolio_and_projects": {"summary": "GS1 Kenya undertakes various projects aimed at enhancing supply chain efficiency and traceability through technology and standards.", "projects": [{"link": null, "name": "Shamba Ikonet", "description": "Connecting Farmers to Buyers through Trust, Traceability & Technology.", "technologies_used": ["Mobile Applications", "Blockchain"]}, {"link": null, "name": "Archive Management", "description": "Organize Smarter. Retrieve Faster. Manage Records with Confidence.", "technologies_used": ["Document Management Systems"]}, {"link": null, "name": "Visitor Access Management", "description": "Smart Access. Verified Identity. Trusted Spaces.", "technologies_used": ["Access Control Systems"]}, {"link": null, "name": "Thamani Online", "description": "Smarter Supply Chains. Verified Products. Seamless Payments.", "technologies_used": ["E-commerce Platforms"]}, {"link": null, "name": "Sokopawa", "description": "Control and monitor your products with our integrated solutions.", "technologies_used": ["Inventory Management Software"]}, {"link": null, "name": "Asset Management", "description": "Powered by GS1 Standards for Accuracy and Control.", "technologies_used": ["Asset Tracking Systems"]}, {"link": null, "name": "Barcode Verification", "description": "Ensure Barcode Quality, Compliance & Global Readability.", "technologies_used": ["Verification Software"]}, {"link": null, "name": "Barcode Printing", "description": "Durable, High-Quality Labels You Can Trust.", "technologies_used": ["Label Printing Technology"]}, {"link": null, "name": "Warehouse Management", "description": "Enhance Accuracy. Boost Efficiency. Gain Full Visibility.", "technologies_used": ["Warehouse Management Systems"]}]}, "generated_agent_instructions": "You are an expert customer care representative for GS1 Kenya.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer."}	2	2	2026-02-19 12:50:42	2026-02-19 12:51:28
3	website	https://ihub.gs1kenya.org	{"metadata": {"data_sources": ["https://ihub.gs1kenya.org"], "missing_information": ["Year founded"]}, "analyzed_at": "2026-02-19T13:26:38.762377Z", "website_url": "https://ihub.gs1kenya.org", "scraped_urls": ["https://ihub.gs1kenya.org", "https://ihub.gs1kenya.org#contact", "https://ihub.gs1kenya.org#about", "https://ihub.gs1kenya.org/registration/form/members"], "analysis_type": "comprehensive_synthesized", "pages_scraped": 4, "scraper_version": "5.4.0-customer-care", "customer_journey": {"support_model": "Ongoing support is provided through email and phone, with a dedicated team available for assistance.", "typical_questions": ["What amenities are included in the workspace?", "How do I book a meeting room?"], "onboarding_process": "New members can sign up online, choose their plan, and receive a welcome orientation upon arrival at the iHub."}, "comprehensive_faq": [{"answer": "GS1 Kenya iHub offers various pricing plans, including Private Rooms for KSH 30,000/Month, Open Desks for KSH 15,000/Month, and Boardroom rentals at KSH 2,500/Person.", "category": "Pricing", "question": "What are the pricing options available?"}, {"answer": "Amenities include high-speed internet, comfortable workstations, a break-out lounge, and complimentary beverages.", "category": "Amenities", "question": "What amenities are available at the iHub?"}], "products_services": [{"name": "Private Room", "category": "Office Space", "use_cases": ["Freelancers needing a quiet workspace", "Small teams requiring privacy"], "description": "A dedicated private space designed for individuals or small teams, offering a conducive environment for focused work.", "key_features": ["Dedicated private space with comfortable seating", "High-speed internet access", "Well designed and furnished workstation", "Fresh self-served brewed black coffee, black tea, and drinking water", "Access to a furnished break-out lounge area", "Top-notch security with CCTV"], "pricing_summary": "KSH 30,000/Month", "target_industries": ["Startups", "Freelancers", "Remote Workers"]}, {"name": "Open Desk", "category": "Co-working Space", "use_cases": ["Freelancers looking for networking opportunities", "Individuals needing a flexible work option"], "description": "A flexible workspace option ideal for individuals seeking a collaborative environment.", "key_features": ["Flexible workspace with high-speed internet", "Community environment fostering networking", "Well designed and furnished workstation", "Unlimited high-speed internet access", "Fresh self-served brewed black coffee, black tea, and drinking water", "Access to a furnished break-out lounge area", "4 hours of complimentary boardroom meeting per month for monthly members"], "pricing_summary": "KSH 15,000/Month", "target_industries": ["Freelancers", "Remote Workers", "Entrepreneurs"]}, {"name": "Boardroom", "category": "Meeting Space", "use_cases": ["Corporate meetings", "Workshops", "Team briefings"], "description": "A professional meeting setup designed for teams and businesses to conduct meetings effectively.", "key_features": ["Wide 4k TV display console", "Professional meeting setup with unlimited high-speed internet access", "Well designed, ventilated space", "Writing materials & whiteboard", "Complementary tea, coffee, and water", "Technical support available"], "pricing_summary": "KSH 2,500/Person (Full Day)", "target_industries": ["Corporations", "Startups", "Educational Institutions"]}], "objection_handling": [{"category": "price", "objection": "The pricing seems high compared to other options.", "proof_points": ["Testimonials from satisfied customers highlight the value of our services.", "Our facilities are designed to enhance productivity and collaboration."], "talking_points": ["Our pricing reflects the quality of our facilities and services.", "We offer a range of plans to suit different budgets."]}], "operational_details": {"business_hours": {"timezone": "EAT", "standard_hours": "Monday to Friday, 9 AM to 5 PM", "holiday_schedule": "Closed on public holidays"}}, "company_intelligence": {"name": "GS1 Kenya iHub", "values": ["Community", "Innovation", "Customer Satisfaction"], "vision": "To be the leading co-working space in Kenya, known for exceptional service and a vibrant community.", "founded": "Not specified", "history": "Founded to address the growing need for flexible workspaces in Nairobi, GS1 Kenya iHub has established itself as a go-to destination for professionals seeking a collaborative and resourceful environment. Over the years, it has expanded its services and amenities to meet the diverse needs of its clientele.", "mission": "To provide a conducive environment for innovation and collaboration among professionals and businesses.", "industry": "Co-working and Shared Office Spaces", "locations": ["Nextgen Mall, 5th Floor, along Mombasa Road, Nairobi, Kenya"], "leadership": [], "description": "GS1 Kenya iHub is a premier co-working space located in Nairobi, providing a dynamic environment tailored for productivity and collaboration. With a focus on high-speed internet, comfortable workstations, and exceptional customer service, it caters to freelancers, startups, and established businesses alike. The iHub aims to foster innovation and community among its members through various services and amenities.", "company_size": "Medium-sized", "headquarters": "Nextgen Mall, Nairobi, Kenya", "business_model": "B2B/B2C"}, "contact_intelligence": {"all_emails": ["ihub@gs1kenya.org"], "all_phones": ["+254 709 226 099"], "primary_email": "ihub@gs1kenya.org", "primary_phone": "+254 709 226 099", "physical_addresses": ["Nextgen Mall, 5th Floor, along Mombasa Road, Nairobi, Kenya"], "social_media_profiles": {"other": [], "twitter": "https://twitter.com/gs1kenyaihub", "facebook": "https://www.facebook.com/profile.php?id=61550782007249", "linkedin": "https://www.linkedin.com/company/gs1kenyaihub/about/", "instagram": "Not available"}}, "pricing_intelligence": {"all_plans": [{"name": "Private Room", "price": "KSH 30,000/Month", "limitations": [], "billing_cycle": "Monthly", "target_customer": "Individuals or small teams", "included_features": ["Dedicated private space", "High-speed internet", "Comfortable seating", "Access to break-out lounge"]}, {"name": "Open Desk", "price": "KSH 15,000/Month", "limitations": [], "billing_cycle": "Monthly", "target_customer": "Freelancers and remote workers", "included_features": ["Flexible workspace", "Unlimited high-speed internet", "Access to break-out lounge"]}, {"name": "Boardroom", "price": "KSH 2,500/Person (Full Day)", "limitations": [], "billing_cycle": "Daily", "target_customer": "Businesses and teams", "included_features": ["Professional meeting setup", "Unlimited high-speed internet", "Writing materials & whiteboard"]}], "free_trial": {"duration": "", "available": false, "limitations": ""}, "enterprise_pricing": {"available": false, "starting_price": "", "custom_features": []}, "pricing_philosophy": "GS1 Kenya iHub adopts a competitive pricing strategy that reflects the quality and range of services provided, ensuring accessibility for both individuals and businesses."}, "portfolio_and_projects": {"summary": "GS1 Kenya iHub offers a variety of services aimed at enhancing productivity and collaboration among professionals. The company is focused on providing high-quality workspaces and meeting environments.", "projects": []}, "generated_agent_instructions": "You are an expert customer care representative for GS1 Kenya iHub.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer."}	3	1	2026-02-19 13:25:45	2026-02-19 13:26:38
4	website	https://glocalhealthcentre.org/	{"metadata": {"data_sources": ["https://glocalhealthcentre.org/"], "missing_information": ["Company founding year", "Leadership details", "Detailed pricing information", "Onboarding process", "Business hours"]}, "analyzed_at": "2026-02-19T14:19:31.479034Z", "website_url": "https://glocalhealthcentre.org/", "scraped_urls": ["https://glocalhealthcentre.org/"], "analysis_type": "comprehensive_synthesized", "pages_scraped": 1, "scraper_version": "5.4.0-customer-care", "customer_journey": {"support_model": "Not specified.", "typical_questions": [], "onboarding_process": "Not specified."}, "comprehensive_faq": [], "products_services": [{"name": "Healthcare Tracking Systems", "category": "Healthcare Technology", "use_cases": ["Improving medication adherence through tracking.", "Enhancing communication among healthcare providers."], "description": "GHC Excellence offers a suite of healthcare tracking systems designed to improve patient care and operational efficiency. These systems include features for medication tracking, electronic health records, and laboratory sample tracking, which allow healthcare providers to deliver coordinated and informed care.", "key_features": ["Traceability Standards: Ensures that all medical processes are compliant with established standards.", "Patient Identification: Streamlines patient registration and identification to prevent errors."], "pricing_summary": "Pricing details are not specified.", "target_industries": ["Healthcare", "Pharmaceuticals"]}], "objection_handling": [], "operational_details": {"business_hours": {"timezone": "Not specified", "standard_hours": "Not specified", "holiday_schedule": "Not specified"}}, "company_intelligence": {"name": "GHC Excellence", "values": ["Patient-centered care", "Innovation", "Integrity"], "vision": "To be a leading healthcare provider recognized for excellence in patient care and innovative healthcare solutions.", "founded": "Not specified", "history": "GHC Excellence has a strong foundation in healthcare services, focusing on technology-driven solutions to improve patient outcomes. Over the years, they have developed various tracking systems that streamline patient care and enhance communication among healthcare providers.", "mission": "To provide comprehensive and coordinated healthcare services that enhance patient safety and satisfaction.", "industry": "Healthcare", "locations": ["Nairobi-Namanga Road, Kajiado"], "leadership": [], "description": "GHC Excellence is a healthcare provider focused on improving patient care through innovative tracking systems. Their services enhance the coordination of care among healthcare providers and ensure patients have access to their medical histories, medication records, and lab results in real-time. They are committed to delivering high-quality healthcare solutions that prioritize patient safety and satisfaction.", "company_size": "Small to Medium", "headquarters": "Kajiado, Kenya", "business_model": "B2C"}, "contact_intelligence": {"all_emails": ["info@ghcexcellence.co.ke"], "all_phones": ["+254 726 776 293", "+254 739 371 657"], "primary_email": "info@ghcexcellence.co.ke", "primary_phone": "+254 726 776 293", "physical_addresses": ["Nairobi-Namanga Road, Kajiado"], "social_media_profiles": {"other": [], "twitter": null, "facebook": null, "linkedin": null, "instagram": null}}, "pricing_intelligence": {"all_plans": [], "free_trial": {"duration": null, "available": false, "limitations": null}, "enterprise_pricing": {"available": false, "starting_price": null, "custom_features": []}, "pricing_philosophy": "Not specified."}, "portfolio_and_projects": {"summary": "GHC Excellence has developed various healthcare tracking systems that enhance patient care and operational efficiency.", "projects": []}, "generated_agent_instructions": "You are an expert customer care representative for GHC Excellence.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer."}	4	1	2026-02-19 14:19:05	2026-02-19 14:19:31
5	website	https://ihub.gs1kenya.org/	{"metadata": {"data_sources": ["https://ihub.gs1kenya.org/", "https://ihub.gs1kenya.org/#contact", "https://ihub.gs1kenya.org/#about"], "missing_information": ["Year founded", "Leadership details"]}, "analyzed_at": "2026-02-20T06:00:52.065232Z", "website_url": "https://ihub.gs1kenya.org/", "scraped_urls": ["https://ihub.gs1kenya.org/", "https://ihub.gs1kenya.org/#contact", "https://ihub.gs1kenya.org/#about", "https://ihub.gs1kenya.org/registration/form/members"], "analysis_type": "comprehensive_synthesized", "pages_scraped": 4, "scraper_version": "5.4.0-customer-care", "customer_journey": {"support_model": "Ongoing support is provided via email and phone, with a dedicated team available for on-site assistance.", "typical_questions": ["What are the available workspace options?", "How can I book a meeting room?"], "onboarding_process": "New customers can start by selecting their desired workspace option and completing the registration process online or in-person. They will receive a tour of the facilities and an introduction to available services."}, "comprehensive_faq": [{"answer": "GS1 Kenya iHub offers private office spaces, open-desks, boardroom meetings, and access to a break-out lounge.", "category": "General", "question": "What services does GS1 Kenya iHub offer?"}, {"answer": "The private room is available for KSH 30,000 per month.", "category": "Pricing", "question": "What is the pricing for the private room?"}], "products_services": [{"name": "Private Room", "category": "Office Space", "use_cases": ["Freelancers needing a quiet space", "Teams requiring privacy for meetings"], "description": "A dedicated private workspace designed for individuals or teams requiring a focused environment. Features include high-speed internet and comfortable seating.", "key_features": ["Dedicated private space", "High-speed internet", "Comfortable seating", "Access to furnished break-out lounge area"], "pricing_summary": "KSH 30,000/Month", "target_industries": ["Freelancers", "Startups", "Small Businesses"]}, {"name": "Open Desk", "category": "Co-working Space", "use_cases": ["Casual workers", "Entrepreneurs looking for networking opportunities"], "description": "A flexible workspace option that allows individuals to work in a community environment. It includes high-speed internet and access to shared amenities.", "key_features": ["Flexible workspace", "Community environment", "Unlimited high-speed internet access", "Access to furnished break-out lounge area"], "pricing_summary": "KSH 15,000/Month", "target_industries": ["Freelancers", "Small Businesses"]}, {"name": "Boardroom", "category": "Meeting Space", "use_cases": ["Corporate meetings", "Workshops", "Training sessions"], "description": "A professional meeting room equipped with a wide 4k TV display console and technical support, ideal for presentations and collaborative meetings.", "key_features": ["Professional meeting setup", "Unlimited high-speed internet access", "Technical support available"], "pricing_summary": "KSH 2,500/Person (Full Day)", "target_industries": ["Corporates", "Training Providers"]}], "objection_handling": [{"category": "price", "objection": "The pricing seems high.", "proof_points": ["High-speed internet and professional meeting setups are included in all plans."], "talking_points": ["Our pricing reflects the quality of services and amenities provided.", "We offer flexible plans to suit different budgets."]}], "operational_details": {"business_hours": {"timezone": "EAT", "standard_hours": "Monday to Friday, 8 AM to 6 PM", "holiday_schedule": "Closed on public holidays"}}, "company_intelligence": {"name": "GS1 Kenya iHub", "values": ["Collaboration", "Innovation", "Customer Satisfaction"], "vision": "To be the leading co-working space in Kenya, fostering innovation and collaboration among professionals.", "founded": "Not specified", "history": "Founded to meet the growing demand for flexible working environments in Nairobi, GS1 Kenya iHub has established itself as a premier destination for entrepreneurs, freelancers, and businesses. The facility has continually evolved to provide state-of-the-art amenities and services.", "mission": "To provide innovative and flexible workspace solutions that empower individuals and businesses to thrive.", "industry": "Co-working Spaces", "locations": ["Nextgen Mall, 5th Floor, along Mombasa Road, Nairobi, Kenya"], "leadership": [], "description": "GS1 Kenya iHub offers a dynamic co-working environment designed to foster collaboration and productivity. Located in Nairobi, the iHub provides various workspace options including private offices, open desks, and well-equipped meeting rooms. With a focus on high-speed internet and comfortable facilities, it aims to support professionals and teams seeking a conducive working atmosphere.", "company_size": "Small to Medium", "headquarters": "Nairobi, Kenya", "business_model": "B2C"}, "contact_intelligence": {"all_emails": ["ihub@gs1kenya.org"], "all_phones": ["+254 709 226 099"], "primary_email": "ihub@gs1kenya.org", "primary_phone": "+254 709 226 099", "physical_addresses": ["Nextgen Mall, 5th Floor, along Mombasa Road, Nairobi, Kenya"], "social_media_profiles": {"other": [], "twitter": "https://twitter.com/gs1kenyaihub", "facebook": "https://www.facebook.com/profile.php?id=61550782007249", "linkedin": "https://www.linkedin.com/company/gs1kenyaihub/about/", "instagram": ""}}, "pricing_intelligence": {"all_plans": [{"name": "Private Room", "price": "KSH 30,000/Month", "limitations": [], "billing_cycle": "Monthly", "target_customer": "Individuals and teams seeking privacy", "included_features": ["Dedicated private space", "High-speed internet", "Access to break-out lounge"]}, {"name": "Open Desk", "price": "KSH 15,000/Month", "limitations": [], "billing_cycle": "Monthly", "target_customer": "Freelancers and casual workers", "included_features": ["Flexible workspace", "Community environment", "Unlimited internet access"]}, {"name": "Boardroom", "price": "KSH 2,500/Person (Full Day)", "limitations": [], "billing_cycle": "Daily", "target_customer": "Corporates and teams needing meeting space", "included_features": ["Professional setup", "Technical support", "Unlimited internet access"]}], "free_trial": {"available": false}, "enterprise_pricing": {"available": false}, "pricing_philosophy": "GS1 Kenya iHub offers competitive pricing to ensure accessibility for individuals and businesses while maintaining high-quality services."}, "portfolio_and_projects": {"summary": "GS1 Kenya iHub provides a range of workspace solutions tailored to meet the needs of professionals and businesses in Nairobi.", "projects": []}, "generated_agent_instructions": "You are an expert customer care representative for GS1 Kenya iHub.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer."}	5	2	2026-02-20 06:00:00	2026-02-20 06:00:52
6	website	https://shambaikonet.com/	{"metadata": {"data_sources": ["About page", "Contact page", "Products page", "Portfolio page"], "missing_information": ["Year founded", "Details on leadership"]}, "analyzed_at": "2026-02-20T06:02:47.477237Z", "website_url": "https://shambaikonet.com/", "scraped_urls": ["https://shambaikonet.com/", "https://shambaikonet.com/#contactform", "https://shambaikonet.com/#aboutus", "https://shambaikonet.com/#products", "https://shambaikonet.com/buy_products", "https://shambaikonet.com/#joinus", "https://shambaikonet.com/farmer_dashboard", "https://shambaikonet.com/logistic_dashboard"], "analysis_type": "comprehensive_synthesized", "pages_scraped": 8, "scraper_version": "5.4.0-customer-care", "customer_journey": {"support_model": "Ongoing support is provided through email and phone, with a focus on resolving inquiries related to orders and logistics.", "typical_questions": ["What products do you offer?", "How do I place an order?"], "onboarding_process": "Users can create an account through the website to start ordering products. Additional guidance may be provided via customer support."}, "comprehensive_faq": [], "products_services": [{"name": "Agricultural Products", "category": "Fresh Produce", "use_cases": ["Farmers seeking direct sales channels.", "Consumers looking for fresh, locally sourced produce."], "description": "ShambaIkonet offers a wide range of fresh agricultural products, ensuring quality and timely delivery from farmers to consumers. Their services include connecting farmers to buyers, streamlining the agricultural supply chain, and providing logistics support.", "key_features": ["Direct connection between farmers and buyers, enhancing market access.", "Logistics support to ensure timely delivery of fresh produce."], "pricing_summary": "Pricing varies by product, with minimum order quantities typically starting at 5 KG.", "target_industries": ["Agriculture", "Food Distribution"]}], "objection_handling": [], "operational_details": {"business_hours": {"timezone": "EAT", "standard_hours": "8 AM - 5 PM", "holiday_schedule": "Closed on public holidays"}}, "company_intelligence": {"name": "ShambaIkonet", "values": ["Integrity", "Innovation", "Sustainability"], "vision": "To be the leading agricultural logistics platform in Africa, transforming the way food is distributed and consumed.", "founded": "Year not provided", "history": "Founded in [year not provided], ShambaIkonet has rapidly established itself as a vital link between farmers and markets in Kenya, leveraging technology to enhance agricultural productivity and market access.", "mission": "To empower farmers by connecting them directly with buyers and improving the agricultural supply chain.", "industry": "Agriculture and Logistics", "locations": ["NextGen floor 5, Mombasa Rd, Nairobi, Kenya"], "leadership": [], "description": "ShambaIkonet is a platform dedicated to connecting farmers with buyers, streamlining the agricultural supply chain, and providing logistics support. The company focuses on enhancing the efficiency of agricultural transactions and ensuring that fresh farm products reach consumers effectively. With a commitment to supporting local farmers, ShambaIkonet aims to improve food security and promote sustainable agricultural practices.", "company_size": "Small to Medium", "headquarters": "Nairobi, Kenya", "business_model": "B2B/B2C"}, "contact_intelligence": {"all_emails": ["info@shambaikonet.com"], "all_phones": ["+254709226000"], "primary_email": "info@shambaikonet.com", "primary_phone": "+254709226000", "physical_addresses": ["NextGen floor 5, Mombasa Rd, Nairobi, Kenya"], "social_media_profiles": {"other": [], "twitter": null, "facebook": null, "linkedin": null, "instagram": null}}, "pricing_intelligence": {"all_plans": [{"name": "Cabbage", "price": "KSH 42.0 per Kg", "limitations": [], "billing_cycle": "N/A", "target_customer": "General consumers and retailers", "included_features": ["Min. order: 5 KG"]}, {"name": "Arrow Roots", "price": "KSH 204.0 per Kg", "limitations": [], "billing_cycle": "N/A", "target_customer": "General consumers and retailers", "included_features": ["Min. order: 5 KG"]}, {"name": "Green Capsicum", "price": "KSH 129.0 per Kg", "limitations": [], "billing_cycle": "N/A", "target_customer": "General consumers and retailers", "included_features": ["Min. order: 5 KG"]}, {"name": "Pawpaw", "price": "KSH 41.0/Kg", "limitations": [], "billing_cycle": "N/A", "target_customer": "General consumers and retailers", "included_features": ["Min. order: 50 KG"]}, {"name": "Kent Mango", "price": "KSH 38.0/Kg", "limitations": [], "billing_cycle": "N/A", "target_customer": "General consumers and retailers", "included_features": ["Min. order: 100 KG"]}], "free_trial": {"duration": null, "available": false, "limitations": null}, "enterprise_pricing": {"available": false, "starting_price": null, "custom_features": []}, "pricing_philosophy": "ShambaIkonet adopts a competitive pricing strategy aimed at supporting farmers while providing value to consumers."}, "portfolio_and_projects": {"summary": "ShambaIkonet focuses on facilitating agricultural transactions and logistics for fresh farm products.", "projects": []}, "generated_agent_instructions": "You are an expert customer care representative for ShambaIkonet.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer."}	6	2	2026-02-20 06:02:04	2026-02-20 06:02:47
7	website	https://www.sokopawa.co.ke/	{"metadata": {"data_sources": ["https://www.sokopawa.co.ke/", "https://www.sokopawa.co.ke/contact", "https://www.sokopawa.co.ke/faqs"], "missing_information": ["Year founded", "Detailed company history"]}, "analyzed_at": "2026-02-20T06:05:13.166845Z", "website_url": "https://www.sokopawa.co.ke/", "scraped_urls": ["https://www.sokopawa.co.ke/", "https://www.sokopawa.co.ke/contact", "https://www.sokopawa.co.ke/categories/Cleaning%2520%26%2520household%2520supplies/sub/household%2520paper%2520products%2520%26%2520paper%2520towels", "https://www.sokopawa.co.ke/products/174", "https://www.sokopawa.co.ke/products/172", "https://www.sokopawa.co.ke/products/170", "https://www.sokopawa.co.ke/products/175", "https://www.sokopawa.co.ke/products/171", "https://www.sokopawa.co.ke/faqs", "https://www.sokopawa.co.ke/#!"], "analysis_type": "comprehensive_synthesized", "pages_scraped": 10, "scraper_version": "5.4.0-customer-care", "customer_journey": {"support_model": "Ongoing support is available via email at support@sokopawa.com, and customers can also contact support through various call-to-action prompts on the website.", "typical_questions": ["What types of products do you offer?", "How can I contact support?"], "onboarding_process": "Customers can register on the website to start shopping for products. Upon registration, they can log in to their accounts to view products, make purchases, and manage their orders."}, "comprehensive_faq": [{"answer": "We offer a variety of health and beauty products, including natural skincare items made from organic ingredients like shea butter and essential oils.", "category": "General", "question": "What types of products do you offer?"}, {"answer": "You can reach our support team via email at support@sokopawa.com.", "category": "Support", "question": "How can I contact support?"}], "products_services": [{"name": "Shea Butter Fantasy with Lavender 250g", "category": "Skincare", "use_cases": ["Moisturizing dry skin", "Daily skincare routine"], "description": "A soothing and high moisturizing body butter made with organic shea butter, suitable for extremely dry and rough skin.", "key_features": ["Soothing and high moisturizing nature", "Suitable for extremely dry and rough skin", "Made with Organic Shea Butter"], "pricing_summary": "KSH 600", "target_industries": ["Health & Beauty"]}, {"name": "Shea Butter Fantasy Ylang Ylang 250g", "category": "Skincare", "use_cases": ["Daily moisturizer", "Skin treatment for dryness"], "description": "Luxurious and soothing body butter that provides deep hydration for various skin types, enriched with Lavender and Ylang Ylang essential oils.", "key_features": ["Luxurious and soothing body butter", "Deep hydration for various skin types", "Contains Lavender and Ylang Ylang essential oils"], "pricing_summary": "KSH 600", "target_industries": ["Health & Beauty"]}, {"name": "Shea Nilotica Vanilla & Orange 250g", "category": "Skincare", "use_cases": ["Skin repair", "Moisturizing"], "description": "A sweet-smelling butter that promotes healthy skin and reverses skin damage, infused with Vanilla & Orange essential oils.", "key_features": ["Sweet smelling butter", "Promotes healthy skin", "Contains Vanilla & Orange essential oils"], "pricing_summary": "KSH 600", "target_industries": ["Health & Beauty"]}, {"name": "Shea Fantasy Hair Growth 120ml", "category": "Hair Care", "use_cases": ["Hair treatment", "Scalp care"], "description": "A nourishing oil blend that promotes hair growth and prevents breakage, providing hydration for the scalp.", "key_features": ["Promotes new hair growth", "Prevents breakage", "Hydrating oil blend"], "pricing_summary": "KSH 650", "target_industries": ["Health & Beauty"]}, {"name": "Shea Fantasy Avocado oil 100ml", "category": "Skincare", "use_cases": ["Skin treatment", "Moisturizing"], "description": "An excellent skin softener with curative effects to repair skin, packed with antioxidants and vitamins.", "key_features": ["Excellent skin softener", "Curative effect to repair skin", "Moisturizes and softens skin"], "pricing_summary": "KSH 850", "target_industries": ["Health & Beauty"]}, {"name": "Shea Fantasy Jojoba Oil 100ml", "category": "Skincare", "use_cases": ["Makeup removal", "Skin hydration"], "description": "A liquid wax resembling skin sebum, rich in vitamin E, that moisturizes skin and can be used as a makeup remover.", "key_features": ["Liquid wax resembling skin sebum", "Rich in vitamin E", "Moisturizes skin"], "pricing_summary": "KSH 1,000", "target_industries": ["Health & Beauty"]}, {"name": "Shea Fantasy Black Castor Oil 100ml", "category": "Hair Care", "use_cases": ["Hair growth", "Skin hydration"], "description": "A natural humectant that promotes hydration and is rich in Vitamin E and fatty acids.", "key_features": ["Natural humectant", "Promotes hydration", "Rich in Vitamin E and Fatty Acids"], "pricing_summary": "KSH 550", "target_industries": ["Health & Beauty"]}, {"name": "Shea Fantasy Virgin Olive Oil", "category": "Skincare", "use_cases": ["Hair treatment", "Skin nourishment"], "description": "Nourishing oil rich in vitamins that repairs and smooths damaged hair and is suitable for various applications.", "key_features": ["Nourishing oil rich in vitamins", "Repairs and smooths damaged hair", "Suitable for various applications"], "pricing_summary": "KSH 450", "target_industries": ["Health & Beauty"]}, {"name": "Shea Butter Fantasy 2kgs", "category": "Skincare", "use_cases": ["Body moisturizer", "Skin treatment"], "description": "A nutrient-rich cosmetics butter that deeply moisturizes and repairs skin, safe for all skin types.", "key_features": ["Nutrient-rich cosmetics butter", "Deeply moisturizes and repairs skin", "Safe for all skin types"], "pricing_summary": "KSH 2,900", "target_industries": ["Health & Beauty"]}], "objection_handling": [{"category": "price", "objection": "The prices seem high compared to other products.", "proof_points": ["Our customers report significant improvements in their skin health after using our products."], "talking_points": ["Our products are made from high-quality, natural ingredients.", "We prioritize customer satisfaction and product effectiveness."]}], "operational_details": {"business_hours": {"timezone": "EAT", "standard_hours": "9 AM - 5 PM", "holiday_schedule": "Closed on public holidays"}}, "company_intelligence": {"name": "Sokopawa", "values": ["Quality", "Customer Satisfaction", "Sustainability"], "vision": "To be a leading online destination for natural beauty and wellness products in Kenya.", "founded": "Year not specified", "history": "Founded in recent years, Sokopawa has quickly established itself as a trusted name in the e-commerce space in Kenya, focusing on delivering high-quality products directly to consumers. The company has expanded its product offerings to include various categories, ensuring a comprehensive shopping experience.", "mission": "To provide high-quality, natural skincare products that promote healthy skin and well-being.", "industry": "E-commerce/Health & Beauty", "locations": ["Nairobi, Kilimani"], "leadership": [], "description": "Sokopawa is an online marketplace that specializes in a diverse range of products, particularly focusing on health and beauty items. The company offers a variety of skincare products made from natural ingredients, including organic shea butter and essential oils. With a commitment to quality and customer satisfaction, Sokopawa aims to provide effective solutions for skincare and personal care needs.", "company_size": "Small to Medium", "headquarters": "Nairobi, Kenya", "business_model": "B2C"}, "contact_intelligence": {"all_emails": ["support@sokopawa.com"], "all_phones": [], "primary_email": "support@sokopawa.com", "primary_phone": null, "physical_addresses": ["Nairobi, Kilimani"], "social_media_profiles": {"other": [], "twitter": null, "facebook": null, "linkedin": null, "instagram": "https://www.instagram.com/sokopawa/?hl=en"}}, "pricing_intelligence": {"all_plans": [{"name": "Shea Butter Fantasy with Lavender 250g", "price": "KSH 600", "limitations": [], "billing_cycle": "one-time purchase", "target_customer": "Individuals with extremely dry skin", "included_features": ["Soothing and high moisturizing nature", "Suitable for extremely dry and rough skin"]}, {"name": "Shea Butter Fantasy Ylang Ylang 250g", "price": "KSH 600", "limitations": [], "billing_cycle": "one-time purchase", "target_customer": "Individuals seeking deep hydration", "included_features": ["Luxurious and soothing body butter", "Deep hydration for various skin types"]}, {"name": "Shea Nilotica Vanilla & Orange 250g", "price": "KSH 600", "limitations": [], "billing_cycle": "one-time purchase", "target_customer": "Individuals wanting to promote healthy skin", "included_features": ["Sweet smelling butter", "Promotes healthy skin"]}], "free_trial": {"duration": null, "available": false, "limitations": null}, "enterprise_pricing": {"available": false, "starting_price": null, "custom_features": []}, "pricing_philosophy": "Sokopawa aims to offer affordable pricing for high-quality, natural skincare products, ensuring accessibility for all customers."}, "portfolio_and_projects": {"summary": "Sokopawa focuses on delivering high-quality natural skincare and beauty products, with a commitment to customer satisfaction and product effectiveness.", "projects": []}, "generated_agent_instructions": "You are an expert customer care representative for Sokopawa.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer."}	7	2	2026-02-20 06:04:00	2026-02-20 06:05:13
8	website	https://datem.co.ke/	{"metadata": {"data_sources": ["https://datem.co.ke/", "https://datem.co.ke/#contact", "https://datem.co.ke/#about", "https://datem.co.ke/#services"], "missing_information": ["Year founded", "Leadership team details"]}, "analyzed_at": "2026-02-20T06:07:22.735524Z", "website_url": "https://datem.co.ke/", "scraped_urls": ["https://datem.co.ke/", "https://datem.co.ke/#contact", "https://datem.co.ke/#about", "https://datem.co.ke/#services"], "analysis_type": "comprehensive_synthesized", "pages_scraped": 4, "scraper_version": "5.4.0-customer-care", "customer_journey": {"support_model": "Ongoing support is provided through email and phone, ensuring that clients can receive assistance as needed.", "typical_questions": ["What services do you offer?", "How can I improve my security setup?"], "onboarding_process": "The onboarding process typically includes an initial consultation to assess security needs, followed by a demonstration of services and setup of the chosen systems."}, "comprehensive_faq": [], "products_services": [{"name": "Visitor Management System", "category": "Security Services", "use_cases": ["Corporate offices", "Residential complexes"], "description": "A comprehensive system designed to streamline visitor check-ins and enhance security protocols. It ensures that all visitors are logged efficiently, promoting a safer environment.", "key_features": ["Fast and efficient security check-ins - Reduces wait times and improves visitor experience.", "Visitor and residents logs - Maintains accurate records for security audits."], "pricing_summary": "Pricing details are not specified.", "target_industries": ["Corporate", "Residential"]}, {"name": "Digital Marketing", "category": "Marketing Services", "use_cases": ["Brand awareness campaigns", "Lead generation"], "description": "Services aimed at promoting security solutions through various digital platforms, helping clients reach a broader audience.", "key_features": [], "pricing_summary": "Pricing details are not specified.", "target_industries": ["Security", "Corporate"]}, {"name": "Market Analysis", "category": "Consulting Services", "use_cases": ["Market entry strategies", "Competitive analysis"], "description": "In-depth analysis of market trends and consumer behavior to inform strategic decisions for clients in the security sector.", "key_features": [], "pricing_summary": "Pricing details are not specified.", "target_industries": ["Security", "Corporate"]}], "objection_handling": [], "operational_details": {"business_hours": {"timezone": "EAT", "standard_hours": "9 AM - 5 PM", "holiday_schedule": "Closed on public holidays"}}, "company_intelligence": {"name": "Datem Security", "values": ["Integrity", "Customer Focus", "Innovation"], "vision": "To be the leading provider of security solutions in the region, recognized for exceptional service and cutting-edge technology.", "founded": "Not specified", "history": "Founded with the aim of addressing security challenges in urban environments, Datem Security has grown to offer a variety of services tailored to meet the needs of diverse clients. The company has continually adapted to the changing landscape of security services, integrating technology and customer feedback into their offerings.", "mission": "To provide innovative security solutions that ensure the safety of individuals and properties while enhancing customer experiences.", "industry": "Security Services", "locations": ["5th Floor Nextgen Mall, Mombasa Road, Nairobi, Kenya"], "leadership": [], "description": "Datem Security specializes in providing comprehensive security solutions, including visitor management systems and efficient security check-in processes. With a focus on enhancing safety and security for both residents and visitors, the company also offers digital marketing and market analysis services to support its clients' needs. Their commitment to innovation and customer satisfaction sets them apart in the security industry.", "company_size": "Small to Medium", "headquarters": "Nairobi, Kenya", "business_model": "B2B/B2C"}, "contact_intelligence": {"all_emails": ["info@uideck.com", "support@uideck.com"], "all_phones": ["+254 700 1111 555", "+254 799 5555 444"], "primary_email": "info@uideck.com", "primary_phone": "+254 700 1111 555", "physical_addresses": ["5th Floor Nextgen Mall, Mombasa Road, Nairobi, Kenya"], "social_media_profiles": {"other": [], "twitter": null, "facebook": null, "linkedin": null, "instagram": null}}, "pricing_intelligence": {"all_plans": [], "free_trial": {"available": false}, "enterprise_pricing": {"available": false}, "pricing_philosophy": "Datem Security emphasizes value-driven pricing, ensuring clients receive quality services that meet their security needs."}, "portfolio_and_projects": {"summary": "Datem Security provides a range of projects focused on enhancing security through technology and strategic consulting.", "projects": []}, "generated_agent_instructions": "You are an expert customer care representative for Datem Security.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer."}	8	2	2026-02-20 06:06:47	2026-02-20 06:07:22
9	website	https://glocalmodels.co.ke/	{"metadata": {"data_sources": ["https://glocalmodels.co.ke/", "https://glocalmodels.co.ke/#about", "https://glocalmodels.co.ke/#how-it-works"], "missing_information": ["Specific contact information", "Detailed pricing plans"]}, "analyzed_at": "2026-02-20T06:10:28.639230Z", "website_url": "https://glocalmodels.co.ke/", "scraped_urls": ["https://glocalmodels.co.ke/", "https://glocalmodels.co.ke/#about", "https://glocalmodels.co.ke/#how-it-works", "https://glocalmodels.co.ke/profile", "https://glocalmodels.co.ke/users/register"], "analysis_type": "comprehensive_synthesized", "pages_scraped": 5, "scraper_version": "5.4.0-customer-care", "customer_journey": {"support_model": "Support details are not specified; users may need to rely on the platform's help section or contact forms.", "typical_questions": ["How do I create a modeling profile?", "What are the benefits of joining Glocal Models?"], "onboarding_process": "Users can join as models by creating a free profile on the Glocal Models platform, where they can verify their identity and connect with agencies."}, "comprehensive_faq": [], "products_services": [{"name": "Modeling Profile Creation", "category": "Modeling Services", "use_cases": ["Aspiring models looking to create a professional profile", "Agencies searching for verified models"], "description": "Glocal Models offers a streamlined process for creating professional modeling profiles that help models showcase their skills and connect with potential clients.", "key_features": ["Verification with GS1 Standards - Ensures authenticity of profiles", "Connection with Clients and Agencies - Facilitates opportunities for models", "Sustainable Fashion Opportunities - Promotes eco-friendly modeling options"], "pricing_summary": "Pricing details are not specified on the website.", "target_industries": ["Fashion", "Advertising", "Entertainment"]}], "objection_handling": [], "operational_details": {"business_hours": {"timezone": "EAT", "standard_hours": "9 AM - 5 PM", "holiday_schedule": "Closed on public holidays"}}, "company_intelligence": {"name": "Glocal Models", "values": ["Empowerment", "Sustainability", "Authenticity"], "vision": "To be the leading platform for models and agencies, fostering a community that values authenticity and sustainability in fashion.", "founded": "2020", "history": "Glocal Models was founded to bridge the gap between models and industry professionals, ensuring that models have access to opportunities that align with their values and aspirations.", "mission": "To empower aspiring models by providing them with the tools and connections necessary to succeed in the fashion industry while promoting sustainable practices.", "industry": "Modeling and Fashion", "locations": [], "leadership": [], "description": "Glocal Models is a platform that connects aspiring models with clients and agencies, promoting sustainable fashion opportunities. They focus on creating verified modeling profiles that meet GS1 standards to ensure authenticity and quality in the modeling industry.", "company_size": "Small", "headquarters": "Nairobi, Kenya", "business_model": "B2C"}, "contact_intelligence": {"all_emails": [], "all_phones": [], "primary_email": null, "primary_phone": null, "physical_addresses": [], "social_media_profiles": {"other": [], "twitter": null, "facebook": null, "linkedin": null, "instagram": null}}, "pricing_intelligence": {"all_plans": [], "free_trial": {"available": false}, "enterprise_pricing": {"available": false}, "pricing_philosophy": "Glocal Models has not publicly detailed its pricing philosophy or specific pricing plans."}, "portfolio_and_projects": {"summary": "Glocal Models focuses on connecting models with various clients and agencies while promoting sustainable fashion initiatives.", "projects": []}, "generated_agent_instructions": "You are an expert customer care representative for Glocal Models.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer."}	9	2	2026-02-20 06:10:04	2026-02-20 06:10:28
10	website	https://glocalhealthcentre.org/	{"metadata": {"data_sources": ["https://glocalhealthcentre.org/"], "missing_information": ["Founding year", "Specific leadership details"]}, "analyzed_at": "2026-02-20T06:11:56.307611Z", "website_url": "https://glocalhealthcentre.org/", "scraped_urls": ["https://glocalhealthcentre.org/"], "analysis_type": "comprehensive_synthesized", "pages_scraped": 1, "scraper_version": "5.4.0-customer-care", "customer_journey": {"support_model": "Ongoing support is provided via email and phone for any inquiries regarding services and patient tracking.", "typical_questions": ["How do I access my electronic health records?", "What should I do if I miss a medication dose?"], "onboarding_process": "Patients can schedule appointments through the contact information provided, and will receive guidance on how to utilize the tracking systems."}, "comprehensive_faq": [], "products_services": [{"name": "Patient Tracking Services", "category": "Healthcare Services", "use_cases": ["Chronic disease management", "Pre-operative assessments"], "description": "GHC Excellence offers a range of patient tracking services designed to improve the efficiency of healthcare delivery. This includes medication tracking, electronic health records, and laboratory sample tracking, which ensures that patients remain informed about their health and treatment.", "key_features": ["Patient Identification: Streamlines patient data management to enhance care coordination.", "Medication Tracking: Provides real-time updates on medication schedules and adherence.", "Electronic Health Records: Centralizes patient information for easy access by healthcare providers.", "Laboratory Sample Tracking: Keeps patients informed about their test results through notifications."], "pricing_summary": "Pricing details are not specified.", "target_industries": ["Healthcare", "Pharmaceuticals"]}], "objection_handling": [], "operational_details": {"business_hours": {"timezone": "EAT", "standard_hours": "Monday to Friday, 8 AM - 5 PM", "holiday_schedule": "Closed on public holidays"}}, "company_intelligence": {"name": "GHC Excellence", "values": ["Integrity", "Compassion", "Innovation", "Collaboration"], "vision": "To be the leading healthcare provider in the region, recognized for our commitment to quality care and patient-centered services.", "founded": "Not specified", "history": "GHC Excellence has established itself as a trusted healthcare provider in Kajiado, Kenya, focusing on modernizing healthcare delivery through technology. The company has achieved significant milestones in improving patient care and enhancing health outcomes.", "mission": "To provide exceptional healthcare services that prioritize patient safety and satisfaction through innovative solutions.", "industry": "Healthcare", "locations": ["Nairobi-Namanga Road, Kajiado"], "leadership": [], "description": "GHC Excellence is a healthcare provider focused on enhancing patient care through innovative tracking systems. Their services include patient identification, medication tracking, and electronic health records management, ensuring that patients receive coordinated and efficient care. The company is committed to improving health outcomes by leveraging technology to keep patients informed and engaged in their healthcare journey.", "company_size": "Medium-sized enterprise", "headquarters": "Kajiado, Kenya", "business_model": "B2C"}, "contact_intelligence": {"all_emails": ["info@ghcexcellence.co.ke"], "all_phones": ["+254 726 776 293", "+254 739 371 657"], "primary_email": "info@ghcexcellence.co.ke", "primary_phone": "+254 726 776 293", "physical_addresses": ["Nairobi-Namanga Road, Kajiado"], "social_media_profiles": {"other": [], "twitter": "", "facebook": "", "linkedin": "", "instagram": ""}}, "pricing_intelligence": {"all_plans": [], "free_trial": {"duration": "", "available": false, "limitations": ""}, "enterprise_pricing": {"available": false, "starting_price": "", "custom_features": []}, "pricing_philosophy": "GHC Excellence focuses on providing value-driven healthcare services, though specific pricing details are currently unavailable."}, "portfolio_and_projects": {"summary": "GHC Excellence has implemented various innovative tracking systems to enhance patient care and streamline healthcare operations.", "projects": []}, "generated_agent_instructions": "You are an expert customer care representative for GHC Excellence.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer."}	10	2	2026-02-20 06:11:30	2026-02-20 06:11:56
11	website	https://michaelmunavu.com	{"metadata": {"data_sources": ["https://michaelmunavu.com", "https://michaelmunavu.com/contact/", "https://michaelmunavu.com/portfolio/", "https://michaelmunavu.com/about/"], "missing_information": ["Company size", "Year founded", "Headquarters location"]}, "analyzed_at": "2026-02-27T10:02:57.400530Z", "website_url": "https://michaelmunavu.com", "scraped_urls": ["https://michaelmunavu.com", "https://michaelmunavu.com/contact/", "https://michaelmunavu.com/portfolio/", "https://michaelmunavu.com/about/"], "analysis_type": "comprehensive_synthesized", "pages_scraped": 4, "scraper_version": "5.4.0-customer-care", "customer_journey": {"support_model": "Ongoing support through email and phone consultations.", "typical_questions": ["What services do you offer?", "How can you help my business?"], "onboarding_process": "Initial consultation to understand client needs, followed by project scoping and timeline establishment."}, "comprehensive_faq": [], "products_services": [{"name": "Full-Stack Development", "category": "Development Services", "use_cases": ["E-commerce websites", "Corporate applications"], "description": "Comprehensive development services covering both frontend and backend technologies to create robust web applications.", "key_features": ["Custom Web Solutions", "Scalable Architecture"], "pricing_summary": "Pricing details not specified.", "target_industries": ["Retail", "Education", "Agriculture"]}, {"name": "AI Applications Development", "category": "Development Services", "use_cases": ["AI customer support agents", "Predictive analytics tools"], "description": "Development of AI-driven applications to enhance customer engagement and operational efficiency.", "key_features": ["Machine Learning Integration", "Natural Language Processing"], "pricing_summary": "Pricing details not specified.", "target_industries": ["Customer Service", "Healthcare"]}, {"name": "Tech Consulting", "category": "Consultation Services", "use_cases": ["Technology audits", "System optimization"], "description": "Expert guidance on technology strategy, implementation, and performance optimization.", "key_features": ["Tailored Solutions", "Expert Insights"], "pricing_summary": "Pricing details not specified.", "target_industries": ["Various"]}], "objection_handling": [], "operational_details": {"business_hours": {"timezone": "Not specified", "standard_hours": "Not specified", "holiday_schedule": "Not specified"}}, "company_intelligence": {"name": "Michael Munavu", "values": ["Innovation", "Integrity", "Customer Success"], "vision": "To be a leading provider of technology solutions that drive transformation and efficiency in various industries.", "founded": "Not specified", "history": "Michael Munavu has built a strong portfolio over the years, contributing to numerous projects that impact various sectors including education, agriculture, and customer service. His commitment to quality and performance optimization has established him as a trusted partner in the tech community.", "mission": "To empower businesses through innovative software solutions and exceptional tech consulting.", "industry": "Software Development", "locations": [], "leadership": [{"name": "Michael Munavu", "title": "Senior Software Engineer / Full-Stack Developer", "expertise": "Full-Stack Development, AI Applications, Tech Consulting", "background": "Extensive experience in full-stack development, with a focus on AI applications and web development."}], "description": "Michael Munavu is a seasoned software engineer specializing in full-stack development, AI applications, and web solutions. He offers a range of services including tech consulting and ongoing support, focusing on delivering scalable and efficient systems. With a strong background in various technologies, he is dedicated to helping businesses leverage technology for growth and efficiency.", "company_size": "Small (1-10 employees)", "headquarters": "Not specified", "business_model": "B2B/B2C"}, "contact_intelligence": {"all_emails": ["michaelmunavu83@gmail.com"], "all_phones": ["+254 740769596"], "primary_email": "michaelmunavu83@gmail.com", "primary_phone": "+254 740769596", "physical_addresses": [], "social_media_profiles": {"other": [{"url": "https://github.com/MICHAELMUNAVU83", "platform": "GitHub"}], "twitter": "https://twitter.com/MichaelTrance1", "facebook": "", "linkedin": "https://www.linkedin.com/in/michael-munavu/", "instagram": "https://www.instagram.com/michael_munavu"}}, "pricing_intelligence": {"all_plans": [], "free_trial": {"duration": null, "available": false, "limitations": null}, "enterprise_pricing": {"available": false, "starting_price": null, "custom_features": []}, "pricing_philosophy": "Pricing details are not explicitly stated, suggesting a tailored approach based on project requirements."}, "portfolio_and_projects": {"summary": "Michael has worked on a diverse range of projects that demonstrate his expertise in software development and impact on various sectors.", "projects": [{"link": "", "name": "CallWisely AI", "description": "Building AI customer care support agents.", "technologies_used": ["AI", "Machine Learning"]}, {"link": "", "name": "African Management Institute", "description": "Worked on building features for their learning management platform impacting over 100,000 businesses in Africa.", "technologies_used": ["Web Development", "Backend Development"]}, {"link": "", "name": "Podii HQ", "description": "Worked on innovative management solutions for agriculture and education sectors using Elixir and Phoenix LiveView.", "technologies_used": ["Elixir", "Phoenix LiveView"]}, {"link": "", "name": "GS1 Kenya", "description": "Contributed to the development of their ERP system using Elixir, focusing on scalable solutions for barcode processing.", "technologies_used": ["Elixir"]}, {"link": "", "name": "Amaris Digital Solutions", "description": "Designed and developed systems using Ruby and React, focusing on scalable and efficient backend systems.", "technologies_used": ["Ruby", "React"]}, {"link": "", "name": "Uamuzi", "description": "Led a team of software engineers in developing a system that connects citizens with their leaders.", "technologies_used": ["Web Development"]}]}, "generated_agent_instructions": "You are an expert customer care representative for Michael Munavu.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer."}	11	1	2026-02-27 10:02:17	2026-02-27 10:02:57
\.


--
-- Data for Name: invitation_workspaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invitation_workspaces (id, team_invitation_id, product_id, role, inserted_at) FROM stdin;
1	1	2	admin	2026-02-20 05:55:45+00
2	2	2	admin	2026-02-20 05:55:56+00
3	3	2	admin	2026-02-20 05:56:05+00
4	4	2	admin	2026-02-20 05:57:31+00
5	5	5	admin	2026-02-20 06:13:26+00
6	6	7	admin	2026-02-20 06:13:38+00
7	7	2	admin	2026-02-20 06:14:46+00
8	8	6	admin	2026-02-20 06:15:52+00
9	9	6	admin	2026-02-20 06:16:11+00
10	10	7	admin	2026-02-20 06:23:06+00
11	11	2	admin	2026-02-20 06:45:11+00
12	11	5	admin	2026-02-20 06:45:11+00
13	11	6	admin	2026-02-20 06:45:11+00
14	11	7	admin	2026-02-20 06:45:11+00
15	11	8	admin	2026-02-20 06:45:11+00
16	11	9	admin	2026-02-20 06:45:11+00
17	11	10	admin	2026-02-20 06:45:11+00
\.


--
-- Data for Name: pending_approvals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pending_approvals (id, workflow_id, product_id, user_id, action_type, status, document_type, document_data, preview_url, rendered_content, recipient_email, recipient_name, recipient_company, recipient_phone, conversation_id, conversation_summary, execution_context, requested_at, expires_at, decided_at, decided_by_id, decision_notes, user_edits, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: product_contexts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_contexts (id, product_id, version, status, master_context, custom_overrides, source_metadata, inserted_at, updated_at) FROM stdin;
3	3	4	draft	{"faqs": [{"answer": "GS1 Kenya iHub offers various pricing plans, including Private Rooms for KSH 30,000/Month, Open Desks for KSH 15,000/Month, and Boardroom rentals at KSH 2,500/Person.", "category": "Pricing", "question": "What are the pricing options available?"}, {"answer": "Amenities include high-speed internet, comfortable workstations, a break-out lounge, and complimentary beverages.", "category": "Amenities", "question": "What amenities are available at the iHub?"}], "company": {"name": "GS1 Kenya iHub", "values": ["Community", "Innovation", "Customer Satisfaction"], "vision": "To be the leading co-working space in Kenya, known for exceptional service and a vibrant community.", "founded": "Not specified", "history": "Founded to address the growing need for flexible workspaces in Nairobi, GS1 Kenya iHub has established itself as a go-to destination for professionals seeking a collaborative and resourceful environment. Over the years, it has expanded its services and amenities to meet the diverse needs of its clientele.", "mission": "To provide a conducive environment for innovation and collaboration among professionals and businesses.", "industry": "Co-working and Shared Office Spaces", "locations": ["Nextgen Mall, 5th Floor, along Mombasa Road, Nairobi, Kenya"], "leadership": [], "description": "GS1 Kenya iHub is a premier co-working space located in Nairobi, providing a dynamic environment tailored for productivity and collaboration. With a focus on high-speed internet, comfortable workstations, and exceptional customer service, it caters to freelancers, startups, and established businesses alike. The iHub aims to foster innovation and community among its members through various services and amenities.", "company_size": "Medium-sized", "headquarters": "Nextgen Mall, Nairobi, Kenya", "business_model": "B2B/B2C"}, "contact": {"all_emails": ["ihub@gs1kenya.org"], "all_phones": ["+254 709 226 099"], "primary_email": "ihub@gs1kenya.org", "primary_phone": "+254 709 226 099", "business_hours": {"timezone": "EAT", "standard_hours": "Monday to Friday, 9 AM to 5 PM", "holiday_schedule": "Closed on public holidays"}, "physical_addresses": ["Nextgen Mall, 5th Floor, along Mombasa Road, Nairobi, Kenya"], "social_media_profiles": {"other": [], "twitter": "https://twitter.com/gs1kenyaihub", "facebook": "https://www.facebook.com/profile.php?id=61550782007249", "linkedin": "https://www.linkedin.com/company/gs1kenyaihub/about/", "instagram": "Not available"}}, "pricing": {"all_plans": [{"name": "Private Room", "price": "KSH 30,000/Month", "limitations": [], "billing_cycle": "Monthly", "target_customer": "Individuals or small teams", "included_features": ["Dedicated private space", "High-speed internet", "Comfortable seating", "Access to break-out lounge"]}, {"name": "Open Desk", "price": "KSH 15,000/Month", "limitations": [], "billing_cycle": "Monthly", "target_customer": "Freelancers and remote workers", "included_features": ["Flexible workspace", "Unlimited high-speed internet", "Access to break-out lounge"]}, {"name": "Boardroom", "price": "KSH 2,500/Person (Full Day)", "limitations": [], "billing_cycle": "Daily", "target_customer": "Businesses and teams", "included_features": ["Professional meeting setup", "Unlimited high-speed internet", "Writing materials & whiteboard"]}], "free_trial": {"duration": "", "available": false, "limitations": ""}, "enterprise_pricing": {"available": false, "starting_price": "", "custom_features": []}, "pricing_philosophy": "GS1 Kenya iHub adopts a competitive pricing strategy that reflects the quality and range of services provided, ensuring accessibility for both individuals and businesses."}, "portfolio": {"summary": "GS1 Kenya iHub offers a variety of services aimed at enhancing productivity and collaboration among professionals. The company is focused on providing high-quality workspaces and meeting environments.", "projects": []}, "customer_journey": {"support_model": "Ongoing support is provided through email and phone, with a dedicated team available for assistance.", "typical_questions": ["What amenities are included in the workspace?", "How do I book a meeting room?"], "onboarding_process": "New members can sign up online, choose their plan, and receive a welcome orientation upon arrival at the iHub."}, "products_services": [{"name": "Private Room", "category": "Office Space", "use_cases": ["Freelancers needing a quiet workspace", "Small teams requiring privacy"], "description": "A dedicated private space designed for individuals or small teams, offering a conducive environment for focused work.", "key_features": ["Dedicated private space with comfortable seating", "High-speed internet access", "Well designed and furnished workstation", "Fresh self-served brewed black coffee, black tea, and drinking water", "Access to a furnished break-out lounge area", "Top-notch security with CCTV"], "pricing_summary": "KSH 30,000/Month", "target_industries": ["Startups", "Freelancers", "Remote Workers"]}, {"name": "Open Desk", "category": "Co-working Space", "use_cases": ["Freelancers looking for networking opportunities", "Individuals needing a flexible work option"], "description": "A flexible workspace option ideal for individuals seeking a collaborative environment.", "key_features": ["Flexible workspace with high-speed internet", "Community environment fostering networking", "Well designed and furnished workstation", "Unlimited high-speed internet access", "Fresh self-served brewed black coffee, black tea, and drinking water", "Access to a furnished break-out lounge area", "4 hours of complimentary boardroom meeting per month for monthly members"], "pricing_summary": "KSH 15,000/Month", "target_industries": ["Freelancers", "Remote Workers", "Entrepreneurs"]}, {"name": "Boardroom", "category": "Meeting Space", "use_cases": ["Corporate meetings", "Workshops", "Team briefings"], "description": "A professional meeting setup designed for teams and businesses to conduct meetings effectively.", "key_features": ["Wide 4k TV display console", "Professional meeting setup with unlimited high-speed internet access", "Well designed, ventilated space", "Writing materials & whiteboard", "Complementary tea, coffee, and water", "Technical support available"], "pricing_summary": "KSH 2,500/Person (Full Day)", "target_industries": ["Corporations", "Startups", "Educational Institutions"]}], "agent_instructions": "You are an expert customer care representative for GS1 Kenya iHub.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer.", "objection_handling": [{"category": "price", "objection": "The pricing seems high compared to other options.", "proof_points": ["Testimonials from satisfied customers highlight the value of our services.", "Our facilities are designed to enhance productivity and collaboration."], "talking_points": ["Our pricing reflects the quality of our facilities and services.", "We offer a range of plans to suit different budgets."]}]}	{"pricing": {"all_plans": [{"name": "Boardroom", "price": "KSH 2,500/Person (Full Day)", "limitations": [], "billing_cycle": "Daily", "target_customer": "Businesses and teams", "included_features": ["Professional meeting setup", "Unlimited high-speed internet", "Writing materials & whiteboard"]}]}}	{"source_ids": [3], "source_count": 1, "last_merged_at": "2026-02-19T13:26:38.767596Z", "detected_conflicts": []}	2026-02-19 13:25:45	2026-02-19 13:30:56
1	1	8	draft	{"faqs": [{"answer": "The membership fee includes a one-off joining fee and a recurring annual licence fee based on annual turnover.", "category": "Membership", "question": "What is the membership fee structure?"}], "company": {"name": "GS1 Kenya", "values": ["Integrity", "Innovation", "Collaboration"], "vision": "To be the trusted partner for businesses seeking to enhance their operational efficiency and product traceability.", "founded": "Year not specified", "history": "Founded to support businesses in implementing global standards, GS1 Kenya has evolved to offer a range of services including training, consultancy, and membership programs. The organization has played a pivotal role in enhancing supply chain management in Kenya.", "mission": "To drive efficiency and transparency in supply chains through global standards and innovative solutions.", "industry": "Information Technology and Standards", "locations": ["5th Floor, Room number 39, Nextgen Mall, Mombasa Road, Nairobi, Kenya"], "leadership": [], "description": "GS1 Kenya is a leading organization that provides standards and solutions to enhance efficiency in supply chains and business communication. They focus on traceability, data management solutions, and barcoding to help businesses optimize their operations. With a commitment to quality and compliance, GS1 Kenya empowers businesses to connect with consumers effectively and sustainably.", "company_size": "Medium-sized enterprise", "headquarters": "Nairobi, Kenya", "business_model": "B2B"}, "contact": {"all_emails": ["info@gs1kenya.org"], "all_phones": ["+254 709226000", "+254 710122252"], "primary_email": "info@gs1kenya.org", "primary_phone": "+254 709226000", "business_hours": {"timezone": "EAT", "standard_hours": "Monday to Friday, 8:00 AM to 5:00 PM", "holiday_schedule": "Closed on public holidays"}, "_unused_all_emails": "", "physical_addresses": ["5th Floor, Room number 39, Nextgen Mall, Mombasa Road, Nairobi, Kenya", "P.O. Box 3243-00200, Nairobi, Kenya"], "_unused_primary_email": "", "_unused_primary_phone": "", "social_media_profiles": {"other": [{"url": "https://www.youtube.com/channel/UChMpKZMCVfOuWWc-a-Sb2YQ", "platform": "youtube"}], "twitter": "https://twitter.com/gs1kenya", "facebook": "https://www.facebook.com/gs1kenya.org/", "linkedin": "https://www.linkedin.com/company/gs1-kenya", "instagram": null}, "_unused_physical_addresses": ""}, "pricing": {"all_plans": [{"name": "Membership Fee", "price": "Not specified", "limitations": [], "billing_cycle": "Annual", "target_customer": "Businesses seeking to implement GS1 standards", "included_features": ["One-off joining fee", "Recurring annual licence fee based on annual turnover"]}], "free_trial": {"duration": null, "available": false, "limitations": null}, "enterprise_pricing": {"available": true, "starting_price": "Not specified", "custom_features": []}, "pricing_philosophy": "GS1 Kenya adopts a value-based pricing approach, where fees are based on the value delivered through services and membership benefits."}, "portfolio": {"summary": "GS1 Kenya works on various projects aimed at enhancing supply chain efficiency and product traceability.", "projects": [{"link": null, "name": "Shamba Ikonet", "description": "Connecting Farmers to Buyers through Trust, Traceability & Technology.", "technologies_used": []}, {"link": null, "name": "Archive Management", "description": "Organize Smarter. Retrieve Faster. Manage Records with Confidence.", "technologies_used": []}, {"link": null, "name": "Visitor Access Management", "description": "Smart Access. Verified Identity. Trusted Spaces.", "technologies_used": []}, {"link": null, "name": "Thamani Online", "description": "Smarter Supply Chains. Verified Products. Seamless Payments.", "technologies_used": []}, {"link": null, "name": "Sokopawa", "description": "Control and monitor your products with our integrated solutions.", "technologies_used": []}, {"link": null, "name": "Asset Management", "description": "Powered by GS1 Standards for Accuracy and Control.", "technologies_used": []}, {"link": null, "name": "Barcode Verification", "description": "Ensure Barcode Quality, Compliance & Global Readability.", "technologies_used": []}, {"link": null, "name": "Barcode Printing", "description": "Durable, High-Quality Labels You Can Trust.", "technologies_used": []}, {"link": null, "name": "Warehouse Management", "description": "Enhance Accuracy. Boost Efficiency. Gain Full Visibility.", "technologies_used": []}]}, "customer_journey": {"support_model": "Ongoing support is provided through email, phone consultations, and scheduled follow-ups to assist clients in maximizing their use of GS1 standards.", "typical_questions": ["What services do you offer?", "How can I become a member?", "What are the benefits of GS1 standards?"], "onboarding_process": "New clients typically begin with an introductory consultation to understand their needs, followed by tailored training sessions and support in implementing GS1 standards."}, "products_services": [{"name": "Training Services", "category": "Training and Development", "use_cases": ["Employee onboarding for new standards", "Continuous professional development in supply chain management"], "description": "GS1 Kenya offers comprehensive training solutions including in-person, virtual training, and custom corporate training designed to empower businesses with the knowledge to implement GS1 standards effectively.", "key_features": ["In-Person Training: Hands-on sessions to enhance skills.", "E-Learning Portal: Flexible online learning options."], "pricing_summary": "Pricing details are not specified but may include membership fees and training costs.", "target_industries": ["Retail", "Manufacturing", "Logistics"]}, {"name": "Consultancy Services", "category": "Consulting", "use_cases": ["Implementing barcoding systems", "Improving traceability for product recalls"], "description": "GS1 Kenya provides expert consultancy services to help businesses optimize their supply chains through barcoding, data management, and traceability solutions.", "key_features": ["Supply Chain Optimization: Tailored strategies for efficiency.", "Data Quality Management: Ensuring accuracy in data handling."], "pricing_summary": "Consultancy pricing is based on project scope and client needs.", "target_industries": ["Food and Beverage", "Pharmaceuticals", "Consumer Goods"]}], "agent_instructions": "You are an expert customer care representative for GS1 Kenya.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer.", "objection_handling": [{"category": "trust", "objection": "Why should I choose GS1 Kenya over other standards organizations?", "proof_points": ["GS1 standards are used by thousands of businesses globally.", "Success stories from local businesses that have improved efficiency."], "talking_points": ["GS1 Kenya is a recognized leader in supply chain standards.", "They provide tailored solutions that meet local and international needs."]}]}	{"contact": {"business_hours": {"timezone": "EAT", "standard_hours": "Monday to Friday, 9:00 AM to 5:00 PM", "holiday_schedule": "Closed on public holidays"}}, "pricing": {"all_plans": [{"name": "Membership Fee", "price": "20000", "limitations": [], "billing_cycle": "Monthly", "target_customer": "Businesses seeking to implement GS1 standards", "included_features": ["One-off joining fee", "Recurring monthly licence fee"]}], "enterprise_pricing": {"available": true, "starting_price": "20000", "custom_features": []}}}	{"source_ids": [1], "source_count": 1, "last_merged_at": "2026-02-19T12:33:36.808775Z", "detected_conflicts": []}	2026-02-19 12:29:38	2026-02-19 14:04:54
4	4	3	draft	{"faqs": [], "company": {"name": "GHC Excellence", "values": ["Patient-centered care", "Innovation", "Integrity"], "vision": "To be a leading healthcare provider recognized for excellence in patient care and innovative healthcare solutions.", "founded": "Not specified", "history": "GHC Excellence has a strong foundation in healthcare services, focusing on technology-driven solutions to improve patient outcomes. Over the years, they have developed various tracking systems that streamline patient care and enhance communication among healthcare providers.", "mission": "To provide comprehensive and coordinated healthcare services that enhance patient safety and satisfaction.", "industry": "Healthcare", "locations": ["Nairobi-Namanga Road, Kajiado"], "leadership": [], "description": "GHC Excellence is a healthcare provider focused on improving patient care through innovative tracking systems. Their services enhance the coordination of care among healthcare providers and ensure patients have access to their medical histories, medication records, and lab results in real-time. They are committed to delivering high-quality healthcare solutions that prioritize patient safety and satisfaction.", "company_size": "Small to Medium", "headquarters": "Kajiado, Kenya", "business_model": "B2C"}, "contact": {"all_emails": ["info@ghcexcellence.co.ke"], "all_phones": ["+254 726 776 293", "+254 739 371 657"], "primary_email": "info@ghcexcellence.co.ke", "primary_phone": "+254 726 776 293", "business_hours": {"timezone": "Not specified", "standard_hours": "Not specified", "holiday_schedule": "Not specified"}, "physical_addresses": ["Nairobi-Namanga Road, Kajiado"], "social_media_profiles": {"other": [], "twitter": null, "facebook": null, "linkedin": null, "instagram": null}}, "pricing": {"all_plans": [], "free_trial": {"duration": null, "available": false, "limitations": null}, "enterprise_pricing": {"available": false, "starting_price": null, "custom_features": []}, "pricing_philosophy": "Not specified."}, "portfolio": {"summary": "GHC Excellence has developed various healthcare tracking systems that enhance patient care and operational efficiency.", "projects": []}, "customer_journey": {"support_model": "Not specified.", "typical_questions": [], "onboarding_process": "Not specified."}, "products_services": [{"name": "Healthcare Tracking Systems", "category": "Healthcare Technology", "use_cases": ["Improving medication adherence through tracking.", "Enhancing communication among healthcare providers."], "description": "GHC Excellence offers a suite of healthcare tracking systems designed to improve patient care and operational efficiency. These systems include features for medication tracking, electronic health records, and laboratory sample tracking, which allow healthcare providers to deliver coordinated and informed care.", "key_features": ["Traceability Standards: Ensures that all medical processes are compliant with established standards.", "Patient Identification: Streamlines patient registration and identification to prevent errors."], "pricing_summary": "Pricing details are not specified.", "target_industries": ["Healthcare", "Pharmaceuticals"]}], "agent_instructions": "You are an expert customer care representative for GHC Excellence.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer.", "objection_handling": []}	{}	{"source_ids": [4], "source_count": 1, "last_merged_at": "2026-02-19T14:19:31.483086Z", "detected_conflicts": []}	2026-02-19 14:19:05	2026-02-19 14:19:31
2	2	4	draft	{"faqs": [{"answer": "The membership fee includes a one-off joining fee and a recurring annual license fee based on your annual turnover.", "category": "Membership", "question": "What is included in the membership fee?"}, {"answer": "We offer in-person training, virtual training, and e-learning options tailored to various industry needs.", "category": "Training", "question": "What types of training do you offer?"}], "company": {"name": "GS1 Kenya", "values": ["Integrity", "Innovation", "Collaboration"], "vision": "To be the trusted partner in supply chain solutions and a leader in providing standards for business communication.", "founded": "Year not specified", "history": "Founded to support businesses in Kenya, GS1 Kenya has been instrumental in promoting the use of barcodes and standards to enhance product traceability and supply chain management. The organization has evolved to offer a range of services and projects aimed at connecting various stakeholders in the supply chain.", "mission": "To enhance the efficiency and visibility of supply chains through the adoption of global standards.", "industry": "Standards and Technology Solutions", "locations": ["5th Floor, Room number 39, Nextgen Mall, Mombasa Road, Nairobi, Kenya"], "leadership": [{"name": "Arnold Polycarp Okello", "title": "CEO", "expertise": "Supply chain optimization, business consultancy", "background": "Extensive experience in supply chain management and standards implementation."}, {"name": "James Macharia", "title": "Director", "expertise": "Operational efficiency, project management", "background": "Expert in operational management and strategic planning."}, {"name": "Gerald O Nyamboga", "title": "Technical Manager", "expertise": "Technology integration, data management", "background": "Specializes in technology solutions for supply chains."}, {"name": "Paschal Kasimu", "title": "Training Manager", "expertise": "Training development, corporate education", "background": "Experienced in capacity building and training programs."}], "description": "GS1 Kenya is a leading organization focused on improving supply chain efficiency through global standards for business communication. They provide various services including training, consultancy, and membership to support businesses in areas like traceability, data management, and product identification. Their commitment to quality and compliance ensures that businesses can operate with confidence in a competitive marketplace.", "company_size": "50-100 employees", "headquarters": "Nairobi, Kenya", "business_model": "B2B/B2C"}, "contact": {"all_emails": ["info@gs1kenya.org"], "all_phones": ["+254 709226000", "+254 710122252"], "primary_email": "info@gs1kenya.org", "primary_phone": "+254 709226000", "business_hours": {"timezone": "EAT", "standard_hours": "Monday to Friday, 9 AM to 5 PM", "holiday_schedule": "Closed on public holidays"}, "physical_addresses": ["5th Floor, Room number 39, Nextgen Mall, Mombasa Road, Nairobi, Kenya", "P.O. Box 3243-00200, Nairobi, Kenya"], "social_media_profiles": {"other": [{"url": "https://www.youtube.com/channel/UChMpKZMCVfOuWWc-a-Sb2YQ", "platform": "youtube"}], "twitter": "https://twitter.com/gs1kenya", "facebook": "https://www.facebook.com/gs1kenya.org/", "linkedin": "https://www.linkedin.com/company/gs1-kenya", "instagram": null}}, "pricing": {"all_plans": [{"name": "Membership Fee", "price": null, "limitations": [], "billing_cycle": "annual", "target_customer": "Businesses needing barcode registration and compliance support", "included_features": ["One-off joining fee", "Recurring annual licence fee based on annual turnover"]}], "free_trial": {"available": false}, "enterprise_pricing": {"available": false}, "pricing_philosophy": "GS1 Kenya adopts a value-based pricing approach, ensuring that businesses get the best return on their investment through quality services."}, "portfolio": {"summary": "GS1 Kenya undertakes various projects aimed at enhancing supply chain efficiency and traceability through technology and standards.", "projects": [{"link": null, "name": "Shamba Ikonet", "description": "Connecting Farmers to Buyers through Trust, Traceability & Technology.", "technologies_used": ["Mobile Applications", "Blockchain"]}, {"link": null, "name": "Archive Management", "description": "Organize Smarter. Retrieve Faster. Manage Records with Confidence.", "technologies_used": ["Document Management Systems"]}, {"link": null, "name": "Visitor Access Management", "description": "Smart Access. Verified Identity. Trusted Spaces.", "technologies_used": ["Access Control Systems"]}, {"link": null, "name": "Thamani Online", "description": "Smarter Supply Chains. Verified Products. Seamless Payments.", "technologies_used": ["E-commerce Platforms"]}, {"link": null, "name": "Sokopawa", "description": "Control and monitor your products with our integrated solutions.", "technologies_used": ["Inventory Management Software"]}, {"link": null, "name": "Asset Management", "description": "Powered by GS1 Standards for Accuracy and Control.", "technologies_used": ["Asset Tracking Systems"]}, {"link": null, "name": "Barcode Verification", "description": "Ensure Barcode Quality, Compliance & Global Readability.", "technologies_used": ["Verification Software"]}, {"link": null, "name": "Barcode Printing", "description": "Durable, High-Quality Labels You Can Trust.", "technologies_used": ["Label Printing Technology"]}, {"link": null, "name": "Warehouse Management", "description": "Enhance Accuracy. Boost Efficiency. Gain Full Visibility.", "technologies_used": ["Warehouse Management Systems"]}]}, "customer_journey": {"support_model": "Ongoing support is available through email and phone, with dedicated consultants for members requiring in-depth assistance.", "typical_questions": ["How do I register my barcode?", "What are the benefits of membership?"], "onboarding_process": "Upon joining, members receive a welcome package that includes resources on how to utilize GS1 services effectively. Training sessions are scheduled based on the member's needs."}, "products_services": [{"name": "Training & Capacity Building", "category": "Training Services", "use_cases": ["Corporate training for businesses", "Skill enhancement for supply chain professionals"], "description": "GS1 Kenya offers comprehensive training programs designed to enhance the skills of professionals in areas like supply chain management, data quality, and barcoding. Their training is available in various formats including in-person, virtual, and e-learning.", "key_features": ["In-Person Training - Hands-on sessions to develop practical skills", "Virtual Training - Flexible online courses for remote learning"], "pricing_summary": "Pricing details vary based on training type and duration.", "target_industries": ["Retail", "Manufacturing", "Logistics"]}, {"name": "Consultancy Services", "category": "Consultancy", "use_cases": ["Improving operational efficiency", "Implementing traceability systems"], "description": "GS1 Kenya provides expert consultancy services to help businesses optimize their supply chains through the implementation of global standards and best practices.", "key_features": ["Supply Chain Optimization - Tailored solutions for enhanced efficiency", "Data Quality Management - Ensuring accuracy and reliability of data"], "pricing_summary": "Consultancy fees are customized based on project scope.", "target_industries": ["Food and Beverage", "Pharmaceuticals", "Consumer Goods"]}, {"name": "Membership Services", "category": "Membership", "use_cases": ["Businesses needing barcode registration", "Organizations looking to comply with global standards"], "description": "Joining GS1 Kenya as a member provides businesses with access to essential resources, including barcode numbers, compliance support, and networking opportunities.", "key_features": ["One-off joining fee - Initial cost to become a member", "Recurring annual license fee - Based on annual turnover"], "pricing_summary": "Membership includes a one-off joining fee and an annual license fee based on turnover.", "target_industries": ["All industries requiring barcoding"]}], "agent_instructions": "You are an expert customer care representative for GS1 Kenya.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer.", "objection_handling": [{"category": "price", "objection": "The membership fee seems high.", "proof_points": ["Members report improved operational efficiency and compliance."], "talking_points": ["Membership provides access to essential resources and support.", "The fee is based on annual turnover, making it scalable."]}]}	{}	{"source_ids": [2], "source_count": 1, "last_merged_at": "2026-02-20T05:52:15.351659Z", "detected_conflicts": []}	2026-02-19 12:50:42	2026-02-20 05:52:15
5	5	3	draft	{"faqs": [{"answer": "GS1 Kenya iHub offers private office spaces, open-desks, boardroom meetings, and access to a break-out lounge.", "category": "General", "question": "What services does GS1 Kenya iHub offer?"}, {"answer": "The private room is available for KSH 30,000 per month.", "category": "Pricing", "question": "What is the pricing for the private room?"}], "company": {"name": "GS1 Kenya iHub", "values": ["Collaboration", "Innovation", "Customer Satisfaction"], "vision": "To be the leading co-working space in Kenya, fostering innovation and collaboration among professionals.", "founded": "Not specified", "history": "Founded to meet the growing demand for flexible working environments in Nairobi, GS1 Kenya iHub has established itself as a premier destination for entrepreneurs, freelancers, and businesses. The facility has continually evolved to provide state-of-the-art amenities and services.", "mission": "To provide innovative and flexible workspace solutions that empower individuals and businesses to thrive.", "industry": "Co-working Spaces", "locations": ["Nextgen Mall, 5th Floor, along Mombasa Road, Nairobi, Kenya"], "leadership": [], "description": "GS1 Kenya iHub offers a dynamic co-working environment designed to foster collaboration and productivity. Located in Nairobi, the iHub provides various workspace options including private offices, open desks, and well-equipped meeting rooms. With a focus on high-speed internet and comfortable facilities, it aims to support professionals and teams seeking a conducive working atmosphere.", "company_size": "Small to Medium", "headquarters": "Nairobi, Kenya", "business_model": "B2C"}, "contact": {"all_emails": ["ihub@gs1kenya.org"], "all_phones": ["+254 709 226 099"], "primary_email": "ihub@gs1kenya.org", "primary_phone": "+254 709 226 099", "business_hours": {"timezone": "EAT", "standard_hours": "Monday to Friday, 8 AM to 6 PM", "holiday_schedule": "Closed on public holidays"}, "physical_addresses": ["Nextgen Mall, 5th Floor, along Mombasa Road, Nairobi, Kenya"], "social_media_profiles": {"other": [], "twitter": "https://twitter.com/gs1kenyaihub", "facebook": "https://www.facebook.com/profile.php?id=61550782007249", "linkedin": "https://www.linkedin.com/company/gs1kenyaihub/about/", "instagram": ""}}, "pricing": {"all_plans": [{"name": "Private Room", "price": "KSH 30,000/Month", "limitations": [], "billing_cycle": "Monthly", "target_customer": "Individuals and teams seeking privacy", "included_features": ["Dedicated private space", "High-speed internet", "Access to break-out lounge"]}, {"name": "Open Desk", "price": "KSH 15,000/Month", "limitations": [], "billing_cycle": "Monthly", "target_customer": "Freelancers and casual workers", "included_features": ["Flexible workspace", "Community environment", "Unlimited internet access"]}, {"name": "Boardroom", "price": "KSH 2,500/Person (Full Day)", "limitations": [], "billing_cycle": "Daily", "target_customer": "Corporates and teams needing meeting space", "included_features": ["Professional setup", "Technical support", "Unlimited internet access"]}], "free_trial": {"available": false}, "enterprise_pricing": {"available": false}, "pricing_philosophy": "GS1 Kenya iHub offers competitive pricing to ensure accessibility for individuals and businesses while maintaining high-quality services."}, "portfolio": {"summary": "GS1 Kenya iHub provides a range of workspace solutions tailored to meet the needs of professionals and businesses in Nairobi.", "projects": []}, "customer_journey": {"support_model": "Ongoing support is provided via email and phone, with a dedicated team available for on-site assistance.", "typical_questions": ["What are the available workspace options?", "How can I book a meeting room?"], "onboarding_process": "New customers can start by selecting their desired workspace option and completing the registration process online or in-person. They will receive a tour of the facilities and an introduction to available services."}, "products_services": [{"name": "Private Room", "category": "Office Space", "use_cases": ["Freelancers needing a quiet space", "Teams requiring privacy for meetings"], "description": "A dedicated private workspace designed for individuals or teams requiring a focused environment. Features include high-speed internet and comfortable seating.", "key_features": ["Dedicated private space", "High-speed internet", "Comfortable seating", "Access to furnished break-out lounge area"], "pricing_summary": "KSH 30,000/Month", "target_industries": ["Freelancers", "Startups", "Small Businesses"]}, {"name": "Open Desk", "category": "Co-working Space", "use_cases": ["Casual workers", "Entrepreneurs looking for networking opportunities"], "description": "A flexible workspace option that allows individuals to work in a community environment. It includes high-speed internet and access to shared amenities.", "key_features": ["Flexible workspace", "Community environment", "Unlimited high-speed internet access", "Access to furnished break-out lounge area"], "pricing_summary": "KSH 15,000/Month", "target_industries": ["Freelancers", "Small Businesses"]}, {"name": "Boardroom", "category": "Meeting Space", "use_cases": ["Corporate meetings", "Workshops", "Training sessions"], "description": "A professional meeting room equipped with a wide 4k TV display console and technical support, ideal for presentations and collaborative meetings.", "key_features": ["Professional meeting setup", "Unlimited high-speed internet access", "Technical support available"], "pricing_summary": "KSH 2,500/Person (Full Day)", "target_industries": ["Corporates", "Training Providers"]}], "agent_instructions": "You are an expert customer care representative for GS1 Kenya iHub.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer.", "objection_handling": [{"category": "price", "objection": "The pricing seems high.", "proof_points": ["High-speed internet and professional meeting setups are included in all plans."], "talking_points": ["Our pricing reflects the quality of services and amenities provided.", "We offer flexible plans to suit different budgets."]}]}	{}	{"source_ids": [5], "source_count": 1, "last_merged_at": "2026-02-20T06:00:52.071347Z", "detected_conflicts": []}	2026-02-20 06:00:00	2026-02-20 06:00:52
6	6	3	draft	{"faqs": [], "company": {"name": "ShambaIkonet", "values": ["Integrity", "Innovation", "Sustainability"], "vision": "To be the leading agricultural logistics platform in Africa, transforming the way food is distributed and consumed.", "founded": "Year not provided", "history": "Founded in [year not provided], ShambaIkonet has rapidly established itself as a vital link between farmers and markets in Kenya, leveraging technology to enhance agricultural productivity and market access.", "mission": "To empower farmers by connecting them directly with buyers and improving the agricultural supply chain.", "industry": "Agriculture and Logistics", "locations": ["NextGen floor 5, Mombasa Rd, Nairobi, Kenya"], "leadership": [], "description": "ShambaIkonet is a platform dedicated to connecting farmers with buyers, streamlining the agricultural supply chain, and providing logistics support. The company focuses on enhancing the efficiency of agricultural transactions and ensuring that fresh farm products reach consumers effectively. With a commitment to supporting local farmers, ShambaIkonet aims to improve food security and promote sustainable agricultural practices.", "company_size": "Small to Medium", "headquarters": "Nairobi, Kenya", "business_model": "B2B/B2C"}, "contact": {"all_emails": ["info@shambaikonet.com"], "all_phones": ["+254709226000"], "primary_email": "info@shambaikonet.com", "primary_phone": "+254709226000", "business_hours": {"timezone": "EAT", "standard_hours": "8 AM - 5 PM", "holiday_schedule": "Closed on public holidays"}, "physical_addresses": ["NextGen floor 5, Mombasa Rd, Nairobi, Kenya"], "social_media_profiles": {"other": [], "twitter": null, "facebook": null, "linkedin": null, "instagram": null}}, "pricing": {"all_plans": [{"name": "Cabbage", "price": "KSH 42.0 per Kg", "limitations": [], "billing_cycle": "N/A", "target_customer": "General consumers and retailers", "included_features": ["Min. order: 5 KG"]}, {"name": "Arrow Roots", "price": "KSH 204.0 per Kg", "limitations": [], "billing_cycle": "N/A", "target_customer": "General consumers and retailers", "included_features": ["Min. order: 5 KG"]}, {"name": "Green Capsicum", "price": "KSH 129.0 per Kg", "limitations": [], "billing_cycle": "N/A", "target_customer": "General consumers and retailers", "included_features": ["Min. order: 5 KG"]}, {"name": "Pawpaw", "price": "KSH 41.0/Kg", "limitations": [], "billing_cycle": "N/A", "target_customer": "General consumers and retailers", "included_features": ["Min. order: 50 KG"]}, {"name": "Kent Mango", "price": "KSH 38.0/Kg", "limitations": [], "billing_cycle": "N/A", "target_customer": "General consumers and retailers", "included_features": ["Min. order: 100 KG"]}], "free_trial": {"duration": null, "available": false, "limitations": null}, "enterprise_pricing": {"available": false, "starting_price": null, "custom_features": []}, "pricing_philosophy": "ShambaIkonet adopts a competitive pricing strategy aimed at supporting farmers while providing value to consumers."}, "portfolio": {"summary": "ShambaIkonet focuses on facilitating agricultural transactions and logistics for fresh farm products.", "projects": []}, "customer_journey": {"support_model": "Ongoing support is provided through email and phone, with a focus on resolving inquiries related to orders and logistics.", "typical_questions": ["What products do you offer?", "How do I place an order?"], "onboarding_process": "Users can create an account through the website to start ordering products. Additional guidance may be provided via customer support."}, "products_services": [{"name": "Agricultural Products", "category": "Fresh Produce", "use_cases": ["Farmers seeking direct sales channels.", "Consumers looking for fresh, locally sourced produce."], "description": "ShambaIkonet offers a wide range of fresh agricultural products, ensuring quality and timely delivery from farmers to consumers. Their services include connecting farmers to buyers, streamlining the agricultural supply chain, and providing logistics support.", "key_features": ["Direct connection between farmers and buyers, enhancing market access.", "Logistics support to ensure timely delivery of fresh produce."], "pricing_summary": "Pricing varies by product, with minimum order quantities typically starting at 5 KG.", "target_industries": ["Agriculture", "Food Distribution"]}], "agent_instructions": "You are an expert customer care representative for ShambaIkonet.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer.", "objection_handling": []}	{}	{"source_ids": [6], "source_count": 1, "last_merged_at": "2026-02-20T06:02:47.482966Z", "detected_conflicts": []}	2026-02-20 06:02:04	2026-02-20 06:02:47
7	7	3	draft	{"faqs": [{"answer": "We offer a variety of health and beauty products, including natural skincare items made from organic ingredients like shea butter and essential oils.", "category": "General", "question": "What types of products do you offer?"}, {"answer": "You can reach our support team via email at support@sokopawa.com.", "category": "Support", "question": "How can I contact support?"}], "company": {"name": "Sokopawa", "values": ["Quality", "Customer Satisfaction", "Sustainability"], "vision": "To be a leading online destination for natural beauty and wellness products in Kenya.", "founded": "Year not specified", "history": "Founded in recent years, Sokopawa has quickly established itself as a trusted name in the e-commerce space in Kenya, focusing on delivering high-quality products directly to consumers. The company has expanded its product offerings to include various categories, ensuring a comprehensive shopping experience.", "mission": "To provide high-quality, natural skincare products that promote healthy skin and well-being.", "industry": "E-commerce/Health & Beauty", "locations": ["Nairobi, Kilimani"], "leadership": [], "description": "Sokopawa is an online marketplace that specializes in a diverse range of products, particularly focusing on health and beauty items. The company offers a variety of skincare products made from natural ingredients, including organic shea butter and essential oils. With a commitment to quality and customer satisfaction, Sokopawa aims to provide effective solutions for skincare and personal care needs.", "company_size": "Small to Medium", "headquarters": "Nairobi, Kenya", "business_model": "B2C"}, "contact": {"all_emails": ["support@sokopawa.com"], "all_phones": [], "primary_email": "support@sokopawa.com", "primary_phone": null, "business_hours": {"timezone": "EAT", "standard_hours": "9 AM - 5 PM", "holiday_schedule": "Closed on public holidays"}, "physical_addresses": ["Nairobi, Kilimani"], "social_media_profiles": {"other": [], "twitter": null, "facebook": null, "linkedin": null, "instagram": "https://www.instagram.com/sokopawa/?hl=en"}}, "pricing": {"all_plans": [{"name": "Shea Butter Fantasy with Lavender 250g", "price": "KSH 600", "limitations": [], "billing_cycle": "one-time purchase", "target_customer": "Individuals with extremely dry skin", "included_features": ["Soothing and high moisturizing nature", "Suitable for extremely dry and rough skin"]}, {"name": "Shea Butter Fantasy Ylang Ylang 250g", "price": "KSH 600", "limitations": [], "billing_cycle": "one-time purchase", "target_customer": "Individuals seeking deep hydration", "included_features": ["Luxurious and soothing body butter", "Deep hydration for various skin types"]}, {"name": "Shea Nilotica Vanilla & Orange 250g", "price": "KSH 600", "limitations": [], "billing_cycle": "one-time purchase", "target_customer": "Individuals wanting to promote healthy skin", "included_features": ["Sweet smelling butter", "Promotes healthy skin"]}], "free_trial": {"duration": null, "available": false, "limitations": null}, "enterprise_pricing": {"available": false, "starting_price": null, "custom_features": []}, "pricing_philosophy": "Sokopawa aims to offer affordable pricing for high-quality, natural skincare products, ensuring accessibility for all customers."}, "portfolio": {"summary": "Sokopawa focuses on delivering high-quality natural skincare and beauty products, with a commitment to customer satisfaction and product effectiveness.", "projects": []}, "customer_journey": {"support_model": "Ongoing support is available via email at support@sokopawa.com, and customers can also contact support through various call-to-action prompts on the website.", "typical_questions": ["What types of products do you offer?", "How can I contact support?"], "onboarding_process": "Customers can register on the website to start shopping for products. Upon registration, they can log in to their accounts to view products, make purchases, and manage their orders."}, "products_services": [{"name": "Shea Butter Fantasy with Lavender 250g", "category": "Skincare", "use_cases": ["Moisturizing dry skin", "Daily skincare routine"], "description": "A soothing and high moisturizing body butter made with organic shea butter, suitable for extremely dry and rough skin.", "key_features": ["Soothing and high moisturizing nature", "Suitable for extremely dry and rough skin", "Made with Organic Shea Butter"], "pricing_summary": "KSH 600", "target_industries": ["Health & Beauty"]}, {"name": "Shea Butter Fantasy Ylang Ylang 250g", "category": "Skincare", "use_cases": ["Daily moisturizer", "Skin treatment for dryness"], "description": "Luxurious and soothing body butter that provides deep hydration for various skin types, enriched with Lavender and Ylang Ylang essential oils.", "key_features": ["Luxurious and soothing body butter", "Deep hydration for various skin types", "Contains Lavender and Ylang Ylang essential oils"], "pricing_summary": "KSH 600", "target_industries": ["Health & Beauty"]}, {"name": "Shea Nilotica Vanilla & Orange 250g", "category": "Skincare", "use_cases": ["Skin repair", "Moisturizing"], "description": "A sweet-smelling butter that promotes healthy skin and reverses skin damage, infused with Vanilla & Orange essential oils.", "key_features": ["Sweet smelling butter", "Promotes healthy skin", "Contains Vanilla & Orange essential oils"], "pricing_summary": "KSH 600", "target_industries": ["Health & Beauty"]}, {"name": "Shea Fantasy Hair Growth 120ml", "category": "Hair Care", "use_cases": ["Hair treatment", "Scalp care"], "description": "A nourishing oil blend that promotes hair growth and prevents breakage, providing hydration for the scalp.", "key_features": ["Promotes new hair growth", "Prevents breakage", "Hydrating oil blend"], "pricing_summary": "KSH 650", "target_industries": ["Health & Beauty"]}, {"name": "Shea Fantasy Avocado oil 100ml", "category": "Skincare", "use_cases": ["Skin treatment", "Moisturizing"], "description": "An excellent skin softener with curative effects to repair skin, packed with antioxidants and vitamins.", "key_features": ["Excellent skin softener", "Curative effect to repair skin", "Moisturizes and softens skin"], "pricing_summary": "KSH 850", "target_industries": ["Health & Beauty"]}, {"name": "Shea Fantasy Jojoba Oil 100ml", "category": "Skincare", "use_cases": ["Makeup removal", "Skin hydration"], "description": "A liquid wax resembling skin sebum, rich in vitamin E, that moisturizes skin and can be used as a makeup remover.", "key_features": ["Liquid wax resembling skin sebum", "Rich in vitamin E", "Moisturizes skin"], "pricing_summary": "KSH 1,000", "target_industries": ["Health & Beauty"]}, {"name": "Shea Fantasy Black Castor Oil 100ml", "category": "Hair Care", "use_cases": ["Hair growth", "Skin hydration"], "description": "A natural humectant that promotes hydration and is rich in Vitamin E and fatty acids.", "key_features": ["Natural humectant", "Promotes hydration", "Rich in Vitamin E and Fatty Acids"], "pricing_summary": "KSH 550", "target_industries": ["Health & Beauty"]}, {"name": "Shea Fantasy Virgin Olive Oil", "category": "Skincare", "use_cases": ["Hair treatment", "Skin nourishment"], "description": "Nourishing oil rich in vitamins that repairs and smooths damaged hair and is suitable for various applications.", "key_features": ["Nourishing oil rich in vitamins", "Repairs and smooths damaged hair", "Suitable for various applications"], "pricing_summary": "KSH 450", "target_industries": ["Health & Beauty"]}, {"name": "Shea Butter Fantasy 2kgs", "category": "Skincare", "use_cases": ["Body moisturizer", "Skin treatment"], "description": "A nutrient-rich cosmetics butter that deeply moisturizes and repairs skin, safe for all skin types.", "key_features": ["Nutrient-rich cosmetics butter", "Deeply moisturizes and repairs skin", "Safe for all skin types"], "pricing_summary": "KSH 2,900", "target_industries": ["Health & Beauty"]}], "agent_instructions": "You are an expert customer care representative for Sokopawa.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer.", "objection_handling": [{"category": "price", "objection": "The prices seem high compared to other products.", "proof_points": ["Our customers report significant improvements in their skin health after using our products."], "talking_points": ["Our products are made from high-quality, natural ingredients.", "We prioritize customer satisfaction and product effectiveness."]}]}	{}	{"source_ids": [7], "source_count": 1, "last_merged_at": "2026-02-20T06:05:13.172399Z", "detected_conflicts": []}	2026-02-20 06:04:00	2026-02-20 06:05:13
8	8	3	draft	{"faqs": [], "company": {"name": "Datem Security", "values": ["Integrity", "Customer Focus", "Innovation"], "vision": "To be the leading provider of security solutions in the region, recognized for exceptional service and cutting-edge technology.", "founded": "Not specified", "history": "Founded with the aim of addressing security challenges in urban environments, Datem Security has grown to offer a variety of services tailored to meet the needs of diverse clients. The company has continually adapted to the changing landscape of security services, integrating technology and customer feedback into their offerings.", "mission": "To provide innovative security solutions that ensure the safety of individuals and properties while enhancing customer experiences.", "industry": "Security Services", "locations": ["5th Floor Nextgen Mall, Mombasa Road, Nairobi, Kenya"], "leadership": [], "description": "Datem Security specializes in providing comprehensive security solutions, including visitor management systems and efficient security check-in processes. With a focus on enhancing safety and security for both residents and visitors, the company also offers digital marketing and market analysis services to support its clients' needs. Their commitment to innovation and customer satisfaction sets them apart in the security industry.", "company_size": "Small to Medium", "headquarters": "Nairobi, Kenya", "business_model": "B2B/B2C"}, "contact": {"all_emails": ["info@uideck.com", "support@uideck.com"], "all_phones": ["+254 700 1111 555", "+254 799 5555 444"], "primary_email": "info@uideck.com", "primary_phone": "+254 700 1111 555", "business_hours": {"timezone": "EAT", "standard_hours": "9 AM - 5 PM", "holiday_schedule": "Closed on public holidays"}, "physical_addresses": ["5th Floor Nextgen Mall, Mombasa Road, Nairobi, Kenya"], "social_media_profiles": {"other": [], "twitter": null, "facebook": null, "linkedin": null, "instagram": null}}, "pricing": {"all_plans": [], "free_trial": {"available": false}, "enterprise_pricing": {"available": false}, "pricing_philosophy": "Datem Security emphasizes value-driven pricing, ensuring clients receive quality services that meet their security needs."}, "portfolio": {"summary": "Datem Security provides a range of projects focused on enhancing security through technology and strategic consulting.", "projects": []}, "customer_journey": {"support_model": "Ongoing support is provided through email and phone, ensuring that clients can receive assistance as needed.", "typical_questions": ["What services do you offer?", "How can I improve my security setup?"], "onboarding_process": "The onboarding process typically includes an initial consultation to assess security needs, followed by a demonstration of services and setup of the chosen systems."}, "products_services": [{"name": "Visitor Management System", "category": "Security Services", "use_cases": ["Corporate offices", "Residential complexes"], "description": "A comprehensive system designed to streamline visitor check-ins and enhance security protocols. It ensures that all visitors are logged efficiently, promoting a safer environment.", "key_features": ["Fast and efficient security check-ins - Reduces wait times and improves visitor experience.", "Visitor and residents logs - Maintains accurate records for security audits."], "pricing_summary": "Pricing details are not specified.", "target_industries": ["Corporate", "Residential"]}, {"name": "Digital Marketing", "category": "Marketing Services", "use_cases": ["Brand awareness campaigns", "Lead generation"], "description": "Services aimed at promoting security solutions through various digital platforms, helping clients reach a broader audience.", "key_features": [], "pricing_summary": "Pricing details are not specified.", "target_industries": ["Security", "Corporate"]}, {"name": "Market Analysis", "category": "Consulting Services", "use_cases": ["Market entry strategies", "Competitive analysis"], "description": "In-depth analysis of market trends and consumer behavior to inform strategic decisions for clients in the security sector.", "key_features": [], "pricing_summary": "Pricing details are not specified.", "target_industries": ["Security", "Corporate"]}], "agent_instructions": "You are an expert customer care representative for Datem Security.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer.", "objection_handling": []}	{}	{"source_ids": [8], "source_count": 1, "last_merged_at": "2026-02-20T06:07:22.741651Z", "detected_conflicts": []}	2026-02-20 06:06:47	2026-02-20 06:07:22
9	9	3	draft	{"faqs": [], "company": {"name": "Glocal Models", "values": ["Empowerment", "Sustainability", "Authenticity"], "vision": "To be the leading platform for models and agencies, fostering a community that values authenticity and sustainability in fashion.", "founded": "2020", "history": "Glocal Models was founded to bridge the gap between models and industry professionals, ensuring that models have access to opportunities that align with their values and aspirations.", "mission": "To empower aspiring models by providing them with the tools and connections necessary to succeed in the fashion industry while promoting sustainable practices.", "industry": "Modeling and Fashion", "locations": [], "leadership": [], "description": "Glocal Models is a platform that connects aspiring models with clients and agencies, promoting sustainable fashion opportunities. They focus on creating verified modeling profiles that meet GS1 standards to ensure authenticity and quality in the modeling industry.", "company_size": "Small", "headquarters": "Nairobi, Kenya", "business_model": "B2C"}, "contact": {"all_emails": [], "all_phones": [], "primary_email": null, "primary_phone": null, "business_hours": {"timezone": "EAT", "standard_hours": "9 AM - 5 PM", "holiday_schedule": "Closed on public holidays"}, "physical_addresses": [], "social_media_profiles": {"other": [], "twitter": null, "facebook": null, "linkedin": null, "instagram": null}}, "pricing": {"all_plans": [], "free_trial": {"available": false}, "enterprise_pricing": {"available": false}, "pricing_philosophy": "Glocal Models has not publicly detailed its pricing philosophy or specific pricing plans."}, "portfolio": {"summary": "Glocal Models focuses on connecting models with various clients and agencies while promoting sustainable fashion initiatives.", "projects": []}, "customer_journey": {"support_model": "Support details are not specified; users may need to rely on the platform's help section or contact forms.", "typical_questions": ["How do I create a modeling profile?", "What are the benefits of joining Glocal Models?"], "onboarding_process": "Users can join as models by creating a free profile on the Glocal Models platform, where they can verify their identity and connect with agencies."}, "products_services": [{"name": "Modeling Profile Creation", "category": "Modeling Services", "use_cases": ["Aspiring models looking to create a professional profile", "Agencies searching for verified models"], "description": "Glocal Models offers a streamlined process for creating professional modeling profiles that help models showcase their skills and connect with potential clients.", "key_features": ["Verification with GS1 Standards - Ensures authenticity of profiles", "Connection with Clients and Agencies - Facilitates opportunities for models", "Sustainable Fashion Opportunities - Promotes eco-friendly modeling options"], "pricing_summary": "Pricing details are not specified on the website.", "target_industries": ["Fashion", "Advertising", "Entertainment"]}], "agent_instructions": "You are an expert customer care representative for Glocal Models.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer.", "objection_handling": []}	{}	{"source_ids": [9], "source_count": 1, "last_merged_at": "2026-02-20T06:10:28.644131Z", "detected_conflicts": []}	2026-02-20 06:10:04	2026-02-20 06:10:28
10	10	3	draft	{"faqs": [], "company": {"name": "GHC Excellence", "values": ["Integrity", "Compassion", "Innovation", "Collaboration"], "vision": "To be the leading healthcare provider in the region, recognized for our commitment to quality care and patient-centered services.", "founded": "Not specified", "history": "GHC Excellence has established itself as a trusted healthcare provider in Kajiado, Kenya, focusing on modernizing healthcare delivery through technology. The company has achieved significant milestones in improving patient care and enhancing health outcomes.", "mission": "To provide exceptional healthcare services that prioritize patient safety and satisfaction through innovative solutions.", "industry": "Healthcare", "locations": ["Nairobi-Namanga Road, Kajiado"], "leadership": [], "description": "GHC Excellence is a healthcare provider focused on enhancing patient care through innovative tracking systems. Their services include patient identification, medication tracking, and electronic health records management, ensuring that patients receive coordinated and efficient care. The company is committed to improving health outcomes by leveraging technology to keep patients informed and engaged in their healthcare journey.", "company_size": "Medium-sized enterprise", "headquarters": "Kajiado, Kenya", "business_model": "B2C"}, "contact": {"all_emails": ["info@ghcexcellence.co.ke"], "all_phones": ["+254 726 776 293", "+254 739 371 657"], "primary_email": "info@ghcexcellence.co.ke", "primary_phone": "+254 726 776 293", "business_hours": {"timezone": "EAT", "standard_hours": "Monday to Friday, 8 AM - 5 PM", "holiday_schedule": "Closed on public holidays"}, "physical_addresses": ["Nairobi-Namanga Road, Kajiado"], "social_media_profiles": {"other": [], "twitter": "", "facebook": "", "linkedin": "", "instagram": ""}}, "pricing": {"all_plans": [], "free_trial": {"duration": "", "available": false, "limitations": ""}, "enterprise_pricing": {"available": false, "starting_price": "", "custom_features": []}, "pricing_philosophy": "GHC Excellence focuses on providing value-driven healthcare services, though specific pricing details are currently unavailable."}, "portfolio": {"summary": "GHC Excellence has implemented various innovative tracking systems to enhance patient care and streamline healthcare operations.", "projects": []}, "customer_journey": {"support_model": "Ongoing support is provided via email and phone for any inquiries regarding services and patient tracking.", "typical_questions": ["How do I access my electronic health records?", "What should I do if I miss a medication dose?"], "onboarding_process": "Patients can schedule appointments through the contact information provided, and will receive guidance on how to utilize the tracking systems."}, "products_services": [{"name": "Patient Tracking Services", "category": "Healthcare Services", "use_cases": ["Chronic disease management", "Pre-operative assessments"], "description": "GHC Excellence offers a range of patient tracking services designed to improve the efficiency of healthcare delivery. This includes medication tracking, electronic health records, and laboratory sample tracking, which ensures that patients remain informed about their health and treatment.", "key_features": ["Patient Identification: Streamlines patient data management to enhance care coordination.", "Medication Tracking: Provides real-time updates on medication schedules and adherence.", "Electronic Health Records: Centralizes patient information for easy access by healthcare providers.", "Laboratory Sample Tracking: Keeps patients informed about their test results through notifications."], "pricing_summary": "Pricing details are not specified.", "target_industries": ["Healthcare", "Pharmaceuticals"]}], "agent_instructions": "You are an expert customer care representative for GHC Excellence.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer.", "objection_handling": []}	{}	{"source_ids": [10], "source_count": 1, "last_merged_at": "2026-02-20T06:11:56.312231Z", "detected_conflicts": []}	2026-02-20 06:11:30	2026-02-20 06:11:56
11	11	3	draft	{"faqs": [], "company": {"name": "Michael Munavu", "values": ["Innovation", "Integrity", "Customer Success"], "vision": "To be a leading provider of technology solutions that drive transformation and efficiency in various industries.", "founded": "Not specified", "history": "Michael Munavu has built a strong portfolio over the years, contributing to numerous projects that impact various sectors including education, agriculture, and customer service. His commitment to quality and performance optimization has established him as a trusted partner in the tech community.", "mission": "To empower businesses through innovative software solutions and exceptional tech consulting.", "industry": "Software Development", "locations": [], "leadership": [{"name": "Michael Munavu", "title": "Senior Software Engineer / Full-Stack Developer", "expertise": "Full-Stack Development, AI Applications, Tech Consulting", "background": "Extensive experience in full-stack development, with a focus on AI applications and web development."}], "description": "Michael Munavu is a seasoned software engineer specializing in full-stack development, AI applications, and web solutions. He offers a range of services including tech consulting and ongoing support, focusing on delivering scalable and efficient systems. With a strong background in various technologies, he is dedicated to helping businesses leverage technology for growth and efficiency.", "company_size": "Small (1-10 employees)", "headquarters": "Not specified", "business_model": "B2B/B2C"}, "contact": {"all_emails": ["michaelmunavu83@gmail.com"], "all_phones": ["+254 740769596"], "primary_email": "michaelmunavu83@gmail.com", "primary_phone": "+254 740769596", "business_hours": {"timezone": "Not specified", "standard_hours": "Not specified", "holiday_schedule": "Not specified"}, "physical_addresses": [], "social_media_profiles": {"other": [{"url": "https://github.com/MICHAELMUNAVU83", "platform": "GitHub"}], "twitter": "https://twitter.com/MichaelTrance1", "facebook": "", "linkedin": "https://www.linkedin.com/in/michael-munavu/", "instagram": "https://www.instagram.com/michael_munavu"}}, "pricing": {"all_plans": [], "free_trial": {"duration": null, "available": false, "limitations": null}, "enterprise_pricing": {"available": false, "starting_price": null, "custom_features": []}, "pricing_philosophy": "Pricing details are not explicitly stated, suggesting a tailored approach based on project requirements."}, "portfolio": {"summary": "Michael has worked on a diverse range of projects that demonstrate his expertise in software development and impact on various sectors.", "projects": [{"link": "", "name": "CallWisely AI", "description": "Building AI customer care support agents.", "technologies_used": ["AI", "Machine Learning"]}, {"link": "", "name": "African Management Institute", "description": "Worked on building features for their learning management platform impacting over 100,000 businesses in Africa.", "technologies_used": ["Web Development", "Backend Development"]}, {"link": "", "name": "Podii HQ", "description": "Worked on innovative management solutions for agriculture and education sectors using Elixir and Phoenix LiveView.", "technologies_used": ["Elixir", "Phoenix LiveView"]}, {"link": "", "name": "GS1 Kenya", "description": "Contributed to the development of their ERP system using Elixir, focusing on scalable solutions for barcode processing.", "technologies_used": ["Elixir"]}, {"link": "", "name": "Amaris Digital Solutions", "description": "Designed and developed systems using Ruby and React, focusing on scalable and efficient backend systems.", "technologies_used": ["Ruby", "React"]}, {"link": "", "name": "Uamuzi", "description": "Led a team of software engineers in developing a system that connects citizens with their leaders.", "technologies_used": ["Web Development"]}]}, "customer_journey": {"support_model": "Ongoing support through email and phone consultations.", "typical_questions": ["What services do you offer?", "How can you help my business?"], "onboarding_process": "Initial consultation to understand client needs, followed by project scoping and timeline establishment."}, "products_services": [{"name": "Full-Stack Development", "category": "Development Services", "use_cases": ["E-commerce websites", "Corporate applications"], "description": "Comprehensive development services covering both frontend and backend technologies to create robust web applications.", "key_features": ["Custom Web Solutions", "Scalable Architecture"], "pricing_summary": "Pricing details not specified.", "target_industries": ["Retail", "Education", "Agriculture"]}, {"name": "AI Applications Development", "category": "Development Services", "use_cases": ["AI customer support agents", "Predictive analytics tools"], "description": "Development of AI-driven applications to enhance customer engagement and operational efficiency.", "key_features": ["Machine Learning Integration", "Natural Language Processing"], "pricing_summary": "Pricing details not specified.", "target_industries": ["Customer Service", "Healthcare"]}, {"name": "Tech Consulting", "category": "Consultation Services", "use_cases": ["Technology audits", "System optimization"], "description": "Expert guidance on technology strategy, implementation, and performance optimization.", "key_features": ["Tailored Solutions", "Expert Insights"], "pricing_summary": "Pricing details not specified.", "target_industries": ["Various"]}], "agent_instructions": "You are an expert customer care representative for Michael Munavu.\\nYour primary goal is to provide helpful, accurate, and friendly support.\\nUse the comprehensive data available to you to answer questions about products, services, pricing, company history, and projects they have completed.\\nListen actively, address concerns with specific details from the knowledge base, and build a positive relationship with the customer.", "objection_handling": []}	{}	{"source_ids": [11], "source_count": 1, "last_merged_at": "2026-02-27T10:02:57.405959Z", "detected_conflicts": []}	2026-02-27 10:02:17	2026-02-27 10:02:57
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, description, assigned_phone_number, user_id, inserted_at, updated_at, agent_name, outbound_greeting_message, call_handling_instructions, voice, inbound_greeting_message, chatbot_greeting_message) FROM stdin;
1	Gs1 Kenya	Traceability Company	\N	1	2026-02-19 12:28:23	2026-02-19 12:28:23	Jane	Hey, I am {agent_name} from {company_name}. Do you have a few minutes? ,  I'd love to tell you about how we can help your business.	Answer the phone professionally\n       and be helpful. If the customer has questions, provide accurate information from the knowledge base.	Polly.Joanna-Neural	Hello, this is {agent_name} from {company_name}. How can I assist you today?	Hi, I'm {agent_name} from {company_name}. How can I help you today?
2	GS1 KENYA WEBSITE	The AI Agent will help in answering customer inquiries and overall improve the customer care experience	254 709226000	2	2026-02-19 12:50:14	2026-02-19 12:50:14	Jane	Hey, I am {agent_name} from {company_name}. Do you have a few minutes? ,  I'd love to tell you about how we can help your business.	Answer the phone professionally\n       and be helpful. If the customer has questions, provide accurate information from the knowledge base.	Polly.Joanna-Neural	Hello, this is {agent_name} from {company_name}. How can I assist you today?	Hi, I'm {agent_name} from {company_name}. How can I help you today?
3	Ihub	Co working space	\N	1	2026-02-19 13:25:24	2026-02-19 13:25:24	Jane	Hey, I am {agent_name} from {company_name}. Do you have a few minutes? ,  I'd love to tell you about how we can help your business.	Answer the phone professionally\n       and be helpful. If the customer has questions, provide accurate information from the knowledge base.	Polly.Joanna-Neural	Hello, this is {agent_name} from {company_name}. How can I assist you today?	Hi, I'm {agent_name} from {company_name}. How can I help you today?
4	GHCE	GHCE	\N	1	2026-02-19 14:18:35	2026-02-19 14:18:35	Jane	Hey, I am {agent_name} from {company_name}. Do you have a few minutes? ,  I'd love to tell you about how we can help your business.	Answer the phone professionally\n       and be helpful. If the customer has questions, provide accurate information from the knowledge base.	Polly.Joanna-Neural	Hello, this is {agent_name} from {company_name}. How can I assist you today?	Hi, I'm {agent_name} from {company_name}. How can I help you today?
5	GS1 IHUB	To help improve customer care service	+254 709 226 099	2	2026-02-20 05:59:22	2026-02-20 05:59:22	Jane	Hey, I am {agent_name} from {company_name}. Do you have a few minutes? ,  I'd love to tell you about how we can help your business.	Answer the phone professionally\n       and be helpful. If the customer has questions, provide accurate information from the knowledge base.	Polly.Joanna-Neural	Hello, this is {agent_name} from {company_name}. How can I assist you today?	Hi, I'm {agent_name} from {company_name}. How can I help you today?
7	Sokopawa	To help enhance the customer service experience\n	+254 709 226 157 	2	2026-02-20 06:02:35	2026-02-20 06:04:23	Jane	Hey, I am {agent_name} from {company_name}. Do you have a few minutes? ,  I'd love to tell you about how we can help your business.	Answer the phone professionally\n       and be helpful. If the customer has questions, provide accurate information from the knowledge base.	Polly.Joanna-Neural	Hello, this is {agent_name} from {company_name}. How can I assist you today?	Hi, I'm {agent_name} from {company_name}. How can I help you today?
6	SHAMBA iko NET	To help improve customer service	+254709226000 	2	2026-02-20 06:01:40	2026-02-20 06:05:29	Jane	Hey, I am {agent_name} from {company_name}. Do you have a few minutes? ,  I'd love to tell you about how we can help your business.	Answer the phone professionally\n       and be helpful. If the customer has questions, provide accurate information from the knowledge base.	Polly.Joanna-Neural	Hello, this is {agent_name} from {company_name}. How can I assist you today?	Hi, I'm {agent_name} from {company_name}. How can I help you today?
8	Datem	To help enhance the customer service experience	+254 709 226 000	2	2026-02-20 06:06:08	2026-02-20 06:06:08	Jane	Hey, I am {agent_name} from {company_name}. Do you have a few minutes? ,  I'd love to tell you about how we can help your business.	Answer the phone professionally\n       and be helpful. If the customer has questions, provide accurate information from the knowledge base.	Polly.Joanna-Neural	Hello, this is {agent_name} from {company_name}. How can I assist you today?	Hi, I'm {agent_name} from {company_name}. How can I help you today?
9	Glocal Models	It will help in improving the customer care experience	+254 709226000	2	2026-02-20 06:08:46	2026-02-20 06:08:46	Jane	Hey, I am {agent_name} from {company_name}. Do you have a few minutes? ,  I'd love to tell you about how we can help your business.	Answer the phone professionally\n       and be helpful. If the customer has questions, provide accurate information from the knowledge base.	Polly.Joanna-Neural	Hello, this is {agent_name} from {company_name}. How can I assist you today?	Hi, I'm {agent_name} from {company_name}. How can I help you today?
10	 GLOCAL HEALTHCARE CENTRE OF EXCELLENCE 	Improving the customer care experience using callwiselyai.	+254 726 776 293	2	2026-02-20 06:11:01	2026-02-20 06:11:01	Jane	Hey, I am {agent_name} from {company_name}. Do you have a few minutes? ,  I'd love to tell you about how we can help your business.	Answer the phone professionally\n       and be helpful. If the customer has questions, provide accurate information from the knowledge base.	Polly.Joanna-Neural	Hello, this is {agent_name} from {company_name}. How can I assist you today?	Hi, I'm {agent_name} from {company_name}. How can I help you today?
11	Michael Munavu	www.michaelmunavu.com	\N	1	2026-02-27 10:01:53	2026-02-27 10:01:53	Jane	Hey, I am {agent_name} from {company_name}. Do you have a few minutes? ,  I'd love to tell you about how we can help your business.	Answer the phone professionally\n       and be helpful. If the customer has questions, provide accurate information from the knowledge base.	Polly.Joanna-Neural	Hello, this is {agent_name} from {company_name}. How can I assist you today?	Hi, I'm {agent_name} from {company_name}. How can I help you today?
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (version, inserted_at) FROM stdin;
20250805151713	2026-02-18 13:45:19
20250805151837	2026-02-18 13:45:19
20250806025600	2026-02-18 13:45:19
20250806032808	2026-02-18 13:45:19
20250809093703	2026-02-18 13:45:19
20250809093813	2026-02-18 13:45:19
20250809094256	2026-02-18 13:45:19
20250809094659	2026-02-18 13:45:19
20250809095250	2026-02-18 13:45:19
20250809173638	2026-02-18 13:45:19
20250809192045	2026-02-18 13:45:19
20250810051510	2026-02-18 13:45:19
20250810063132	2026-02-18 13:45:19
20250810063434	2026-02-18 13:45:19
20250810100537	2026-02-18 13:45:19
20250813153231	2026-02-18 13:45:19
20250814112519	2026-02-18 13:45:19
20250814112606	2026-02-18 13:45:19
20250815051010	2026-02-18 13:45:19
20250815102617	2026-02-18 13:45:19
20250817051906	2026-02-18 13:45:19
20250819173655	2026-02-18 13:45:19
20251124060501	2026-02-18 13:45:19
20251124060626	2026-02-18 13:45:19
20251224091225	2026-02-18 13:45:19
20251224091301	2026-02-18 13:45:19
20251224091334	2026-02-18 13:45:19
20251224091414	2026-02-18 13:45:19
20251224091441	2026-02-18 13:45:19
20260119121500	2026-02-18 13:45:19
20260120130000	2026-02-18 13:45:19
20260205160000	2026-02-18 13:45:19
20260205163000	2026-02-18 13:45:19
20260209120000	2026-02-18 13:45:19
20260210120000	2026-02-18 13:45:19
20260211120000	2026-02-18 13:45:19
20260212000000	2026-02-18 13:45:19
20260219120000	2026-02-20 05:45:46
\.


--
-- Data for Name: team_invitations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team_invitations (id, email, token, invited_by_id, expires_at, accepted_at, inserted_at) FROM stdin;
2	michaelmunavu83@gmail.com	eUoTvvCM17OAjf_2cLEqIV3ywWrU0RuwPf_JyVCB_1Q	2	2026-02-27 05:55:56+00	\N	2026-02-20 05:55:56+00
3	susan@gs1kenya.org	_Qa2BEVVGVXdKMF4LCvONW5hi_AMNoweozD1ron9V5c	2	2026-02-27 05:56:05+00	\N	2026-02-20 05:56:05+00
4	michaelmunavu83@gmail.com	XqqPjuzfXvMBYbZ4jCji6qQOsmBYCZI6stiX-Ltjh4I	2	2026-02-27 05:57:31+00	\N	2026-02-20 05:57:31+00
5	f.rashid@gs1kenya.org	EtGrRtzK1O4tgHQhg-WHaISXSDlrKVMicuTW7BSDmSs	2	2026-02-27 06:13:26+00	\N	2026-02-20 06:13:26+00
6	m.wakio@gs1kenya.org	P4MD8SZHug4KszjIa0o5NzmnmPDWm-AiZqhlhU7t8N0	2	2026-02-27 06:13:38+00	\N	2026-02-20 06:13:38+00
7	nelson@gs1kenya.org	BKYV5rCg-bwkvOnnNpPhIrnXXGjjEfnDf9-53WlC544	2	2026-02-27 06:14:46+00	\N	2026-02-20 06:14:46+00
8	felix.sichangi@gs1kenya.org	eUJ1UhFg-VnkRZlmNeWBd_7DCi_I2p6aeoPl_fQyLmo	2	2026-02-27 06:15:52+00	2026-02-20 06:29:17+00	2026-02-20 06:15:52+00
11	michaelmunavu83@gmail.com	2WiU1mUZBpB5nr7OMzO7I4qEWBhlNLIY7yqK2jaZwf8	2	2026-02-27 06:45:11+00	2026-02-20 06:46:27+00	2026-02-20 06:45:11+00
1	joss@gs1kenya.org	ZWD0qPdEkUwrW1mKtPDcIxu7PtXvQhFbMw56WDbuZVw	2	2026-02-27 05:55:45+00	2026-02-20 08:06:58+00	2026-02-20 05:55:45+00
10	r.wanyugi@gs1kenya.org	WPTe_Gu_L-socMUEajQF1_H9bTaaTwW71D0fXlpHbvw	2	2026-03-02 07:07:11+00	\N	2026-02-20 06:23:06+00
9	r.mwose@gs1kenya.org	2bsbTp4J83rBDfvl_FDxzB2WpBkyaN05j9WcloAVuts	2	2026-03-02 07:07:14+00	\N	2026-02-20 06:16:11+00
\.


--
-- Data for Name: user_notification_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_notification_settings (id, user_id, notify_new_conversation, notify_document_generated, notify_pending_approval, emails, inserted_at, updated_at, product_id) FROM stdin;
1	1	t	f	f	{michaelmunavu83@gmail.com}	2026-02-19 12:43:01	2026-02-19 12:43:29	1
2	2	t	f	f	{customercare@gs1kenya.org,susan@gs1kenya.org,info@gskenya.org}	2026-02-19 12:51:53	2026-02-19 12:52:51	2
3	1	f	f	f	{michaelmunavu83@gmail.com}	2026-02-19 13:31:25	2026-02-19 13:31:25	3
4	2	f	f	f	{customercare@gs1kenya.org}	2026-02-20 06:09:02	2026-02-20 06:09:02	9
\.


--
-- Data for Name: user_workflows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_workflows (id, name, description, is_active, user_id, product_id, inserted_at, updated_at, trigger_type, trigger_config, conditions, actions, priority, requires_approval, approval_config, execution_count, last_executed_at, success_rate, template_id, template_version) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, hashed_password, confirmed_at, inserted_at, updated_at, first_name, last_name, last_logged_in_at, last_logged_out_at, invited_by_id) FROM stdin;
3	michaelmunavu8@gmail.com	$2b$12$rDsM10C0VwkmvXuhtLHp6u.AYUaOB9NFsKLBpfVBjUKHAlLoAgnh2	\N	2026-02-19 14:08:02	2026-02-19 14:17:01	\N	\N	2026-02-19 14:08:03	2026-02-19 14:17:01	\N
4	felix.sichangi@gs1kenya.org	$2b$12$fTuOly9nTF6ePtVgT7YTPuPOm3LtmZLRKiO03nqnvhFGpKOYk6P1S	\N	2026-02-20 06:29:17	2026-02-20 06:29:18	\N	\N	2026-02-20 06:29:18	\N	2
5	joss@gs1kenya.org	$2b$12$W4J5ANynLJAC5uVQikel1ONItAGDwYJWI5wxJce5PQR4AdjRUmLn6	\N	2026-02-20 08:06:58	2026-02-20 08:06:58	\N	\N	2026-02-20 08:06:58	\N	2
1	michaelmunavu83@gmail.com	$2b$12$vlZS0KKd3qf2t/KPX5MLY.cBLHGXhqA2SAJhY3GIBV6mCjQWSmYny	\N	2026-02-18 13:45:54	2026-02-27 10:01:36	\N	\N	2026-02-27 10:01:36	2026-02-20 06:47:47	2
2	customercare@gs1kenya.org	$2b$12$mxJrIygwZZw/1JtymQJPbuwbRjJZgEwJbOg/lOc./4qGOlKOQP1sS	\N	2026-02-19 12:48:15	2026-02-27 13:15:32	\N	\N	2026-02-27 13:15:32	2026-02-20 13:15:59	\N
\.


--
-- Data for Name: users_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_tokens (id, user_id, token, context, sent_to, inserted_at) FROM stdin;
1	1	\\x8649af3d1b691b0d5e5fc1f4275df9d41efa77a56469461369415ecbdefa5957	session	\N	2026-02-18 13:45:55
3	2	\\x3c1306c49c6d4c00060c89f3c8bf746bebc2cb9bed25fbb6bae25688292ab4bb	session	\N	2026-02-19 12:48:15
4	2	\\x93922fb7a2c20d985cd8d32363a3f063a86f3ee3978e274984f71a3285342712	session	\N	2026-02-19 13:30:35
5	2	\\x84f22fee6df82d041783cc4ba38d5461fd388d3d32db12b0cbdc0d3f566ac3e9	session	\N	2026-02-19 13:35:08
7	1	\\xefde3db62f228475366b6705d3448e4a111382301a0b2bd343aca8265a609bf7	session	\N	2026-02-19 14:18:22
9	4	\\x9948770c9c551b21a96db6f297ba745758f165b39b94aa30ab3267c8673e8f1f	session	\N	2026-02-20 06:29:18
13	5	\\x96fa2261dd33c2147201d53241fc618a23869af1f9c027ac5515ca839549d792	session	\N	2026-02-20 08:06:58
14	1	\\xbf7e30983ebf338a443da6508e26c1038fd913507ad120ac0b8c80e398bdffa2	session	\N	2026-02-20 13:16:10
15	2	\\xcd8cb9e328234e87a5d44c8f2b012a20defed261f2a5a347d8bcb345e4d4a805	session	\N	2026-02-23 07:05:53
16	2	\\xad8558842dd34227a4fa1b6553c2f26ac6fa8a0a15e0e3fdc3ec106ddc78cd83	session	\N	2026-02-23 07:24:23
17	2	\\xd33e13f4e5671b81db1624182023e6da112f08724eb6e2fca0d7708d9856facc	session	\N	2026-02-24 08:29:27
18	1	\\x993df42b57d823992c45c7b97cc36cfdde2c91516e4d35649c11bc93f6157ade	session	\N	2026-02-27 07:53:12
19	1	\\xe71c45c402456cc1ab716efad41856f7dbd3360a4f184f50fdab52420892109a	session	\N	2026-02-27 10:01:36
20	2	\\x3ba0045b199853c6569fc69afb35265c460d1af7d71087ce7a987ecb9cc35ae8	session	\N	2026-02-27 13:15:32
\.


--
-- Data for Name: workflow_executions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_executions (id, workflow_id, product_id, user_id, conversation_id, call_type, status, trigger_data, execution_log, result, error, error_details, started_at, completed_at, duration_ms, pending_approval_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: workflow_tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_tasks (id, product_id, user_id, workflow_execution_id, workflow_id, conversation_id, title, description, status, priority, due_at, completed_at, metadata, inserted_at, updated_at) FROM stdin;
1	1	1	\N	\N	cht_kllyak5xhmltg9ies	Follow-up: meeting with CEO	Topic: meeting with CEO	open	high	\N	\N	{"topic": "meeting with CEO", "source": "ai_follow_up", "channel": "chatbot", "contact_name": "", "contact_email": ""}	2026-02-19 12:41:40	2026-02-19 12:41:40
2	1	1	\N	\N	cht_kllyak5xhmltg9ies	Meeting with Michael: Mon Feb 19 at 17:00	Scheduled: 2024-02-19 17:00:00Z\nName: Michael\nEmail: michaelmunavu83@gmail.com	open	high	2024-02-19 17:00:00	\N	{"source": "ai_meeting_detection", "channel": "chatbot", "contact_name": "Michael", "contact_email": "michaelmunavu83@gmail.com"}	2026-02-19 12:42:09	2026-02-19 12:42:09
\.


--
-- Data for Name: workflow_templates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_templates (id, template_id, version, name, description, category, tags, trigger_type, trigger_config, conditions, actions, requires_approval, approval_config, icon, color, difficulty, estimated_setup_time, required_context, usage_count, avg_success_rate, is_active, is_featured, is_system, created_by, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: workspace_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workspace_members (id, user_id, product_id, role, invited_by_id, inserted_at) FROM stdin;
1	4	6	admin	2	2026-02-20 06:29:17+00
2	4	2	admin	2	2026-02-20 06:39:46+00
3	1	2	admin	2	2026-02-20 06:46:27+00
4	1	5	admin	2	2026-02-20 06:46:27+00
5	1	6	admin	2	2026-02-20 06:46:27+00
6	1	7	admin	2	2026-02-20 06:46:27+00
7	1	8	admin	2	2026-02-20 06:46:27+00
8	1	9	admin	2	2026-02-20 06:46:27+00
9	1	10	admin	2	2026-02-20 06:46:27+00
10	5	2	admin	2	2026-02-20 08:06:58+00
11	5	1	admin	2	2026-02-23 07:06:57+00
12	5	3	admin	2	2026-02-23 07:06:57+00
13	5	4	admin	2	2026-02-23 07:06:57+00
14	5	5	admin	2	2026-02-23 07:06:57+00
15	5	6	admin	2	2026-02-23 07:06:57+00
16	5	7	admin	2	2026-02-23 07:06:57+00
17	5	8	admin	2	2026-02-23 07:06:57+00
18	5	9	admin	2	2026-02-23 07:06:57+00
19	5	10	admin	2	2026-02-23 07:06:57+00
\.


--
-- Name: ai_usages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ai_usages_id_seq', 10, true);


--
-- Name: call_conversations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.call_conversations_id_seq', 1, false);


--
-- Name: call_instances_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.call_instances_id_seq', 1, false);


--
-- Name: chat_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_messages_id_seq', 22, true);


--
-- Name: chat_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_sessions_id_seq', 10, true);


--
-- Name: chatbot_analytics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chatbot_analytics_id_seq', 550, true);


--
-- Name: chatbot_configs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chatbot_configs_id_seq', 4, true);


--
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contacts_id_seq', 1, false);


--
-- Name: demo_configurations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.demo_configurations_id_seq', 1, false);


--
-- Name: generated_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.generated_documents_id_seq', 1, false);


--
-- Name: information_sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.information_sources_id_seq', 11, true);


--
-- Name: invitation_workspaces_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invitation_workspaces_id_seq', 17, true);


--
-- Name: pending_approvals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pending_approvals_id_seq', 1, false);


--
-- Name: product_contexts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_contexts_id_seq', 11, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 11, true);


--
-- Name: team_invitations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.team_invitations_id_seq', 11, true);


--
-- Name: user_notification_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_notification_settings_id_seq', 4, true);


--
-- Name: user_workflows_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_workflows_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 5, true);


--
-- Name: users_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_tokens_id_seq', 20, true);


--
-- Name: workflow_executions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workflow_executions_id_seq', 1, false);


--
-- Name: workflow_tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workflow_tasks_id_seq', 2, true);


--
-- Name: workflow_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workflow_templates_id_seq', 1, false);


--
-- Name: workspace_members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workspace_members_id_seq', 19, true);


--
-- Name: ai_usages ai_usages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_usages
    ADD CONSTRAINT ai_usages_pkey PRIMARY KEY (id);


--
-- Name: call_conversations call_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.call_conversations
    ADD CONSTRAINT call_conversations_pkey PRIMARY KEY (id);


--
-- Name: call_instances call_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.call_instances
    ADD CONSTRAINT call_instances_pkey PRIMARY KEY (id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: chat_sessions chat_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_sessions
    ADD CONSTRAINT chat_sessions_pkey PRIMARY KEY (id);


--
-- Name: chatbot_analytics chatbot_analytics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbot_analytics
    ADD CONSTRAINT chatbot_analytics_pkey PRIMARY KEY (id);


--
-- Name: chatbot_configs chatbot_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbot_configs
    ADD CONSTRAINT chatbot_configs_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: demo_configurations demo_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.demo_configurations
    ADD CONSTRAINT demo_configurations_pkey PRIMARY KEY (id);


--
-- Name: generated_documents generated_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_documents
    ADD CONSTRAINT generated_documents_pkey PRIMARY KEY (id);


--
-- Name: information_sources information_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.information_sources
    ADD CONSTRAINT information_sources_pkey PRIMARY KEY (id);


--
-- Name: invitation_workspaces invitation_workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitation_workspaces
    ADD CONSTRAINT invitation_workspaces_pkey PRIMARY KEY (id);


--
-- Name: pending_approvals pending_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pending_approvals
    ADD CONSTRAINT pending_approvals_pkey PRIMARY KEY (id);


--
-- Name: product_contexts product_contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_contexts
    ADD CONSTRAINT product_contexts_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: team_invitations team_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_invitations
    ADD CONSTRAINT team_invitations_pkey PRIMARY KEY (id);


--
-- Name: user_notification_settings user_notification_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_notification_settings
    ADD CONSTRAINT user_notification_settings_pkey PRIMARY KEY (id);


--
-- Name: user_workflows user_workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_workflows
    ADD CONSTRAINT user_workflows_pkey PRIMARY KEY (id);


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
-- Name: workflow_executions workflow_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_executions
    ADD CONSTRAINT workflow_executions_pkey PRIMARY KEY (id);


--
-- Name: workflow_tasks workflow_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_tasks
    ADD CONSTRAINT workflow_tasks_pkey PRIMARY KEY (id);


--
-- Name: workflow_templates workflow_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_templates
    ADD CONSTRAINT workflow_templates_pkey PRIMARY KEY (id);


--
-- Name: workspace_members workspace_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_pkey PRIMARY KEY (id);


--
-- Name: ai_usages_inserted_at_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ai_usages_inserted_at_index ON public.ai_usages USING btree (inserted_at);


--
-- Name: ai_usages_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ai_usages_product_id_index ON public.ai_usages USING btree (product_id);


--
-- Name: ai_usages_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ai_usages_user_id_index ON public.ai_usages USING btree (user_id);


--
-- Name: ai_usages_user_id_inserted_at_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ai_usages_user_id_inserted_at_index ON public.ai_usages USING btree (user_id, inserted_at);


--
-- Name: call_conversations_call_analysis_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX call_conversations_call_analysis_index ON public.call_conversations USING btree (call_analysis);


--
-- Name: call_conversations_call_instance_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX call_conversations_call_instance_id_index ON public.call_conversations USING btree (call_instance_id);


--
-- Name: call_conversations_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX call_conversations_product_id_index ON public.call_conversations USING btree (product_id);


--
-- Name: call_instances_call_analysis_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX call_instances_call_analysis_index ON public.call_instances USING btree (call_analysis);


--
-- Name: chat_messages_chat_session_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chat_messages_chat_session_id_index ON public.chat_messages USING btree (chat_session_id);


--
-- Name: chat_messages_inserted_at_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chat_messages_inserted_at_index ON public.chat_messages USING btree (inserted_at);


--
-- Name: chat_messages_message_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX chat_messages_message_id_index ON public.chat_messages USING btree (message_id);


--
-- Name: chat_messages_message_type_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chat_messages_message_type_index ON public.chat_messages USING btree (message_type);


--
-- Name: chat_sessions_is_human_takeover_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chat_sessions_is_human_takeover_index ON public.chat_sessions USING btree (is_human_takeover);


--
-- Name: chat_sessions_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chat_sessions_product_id_index ON public.chat_sessions USING btree (product_id);


--
-- Name: chat_sessions_session_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX chat_sessions_session_id_index ON public.chat_sessions USING btree (session_id);


--
-- Name: chat_sessions_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chat_sessions_status_index ON public.chat_sessions USING btree (status);


--
-- Name: chatbot_analytics_event_name_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chatbot_analytics_event_name_index ON public.chatbot_analytics USING btree (event_name);


--
-- Name: chatbot_analytics_product_id_event_name_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chatbot_analytics_product_id_event_name_index ON public.chatbot_analytics USING btree (product_id, event_name);


--
-- Name: chatbot_analytics_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chatbot_analytics_product_id_index ON public.chatbot_analytics USING btree (product_id);


--
-- Name: chatbot_analytics_product_id_timestamp_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chatbot_analytics_product_id_timestamp_index ON public.chatbot_analytics USING btree (product_id, "timestamp");


--
-- Name: chatbot_analytics_session_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chatbot_analytics_session_id_index ON public.chatbot_analytics USING btree (session_id);


--
-- Name: chatbot_analytics_timestamp_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chatbot_analytics_timestamp_index ON public.chatbot_analytics USING btree ("timestamp");


--
-- Name: chatbot_configs_embed_api_key_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chatbot_configs_embed_api_key_index ON public.chatbot_configs USING btree (embed_api_key);


--
-- Name: chatbot_configs_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX chatbot_configs_product_id_index ON public.chatbot_configs USING btree (product_id);


--
-- Name: demo_configurations_call_sid_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX demo_configurations_call_sid_index ON public.demo_configurations USING btree (call_sid);


--
-- Name: demo_configurations_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX demo_configurations_status_index ON public.demo_configurations USING btree (status);


--
-- Name: demo_configurations_user_email_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX demo_configurations_user_email_index ON public.demo_configurations USING btree (user_email);


--
-- Name: demo_configurations_user_phone_number_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX demo_configurations_user_phone_number_index ON public.demo_configurations USING btree (user_phone_number);


--
-- Name: generated_documents_conversation_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX generated_documents_conversation_id_index ON public.generated_documents USING btree (conversation_id);


--
-- Name: generated_documents_product_id_document_number_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX generated_documents_product_id_document_number_index ON public.generated_documents USING btree (product_id, document_number);


--
-- Name: generated_documents_product_id_document_type_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX generated_documents_product_id_document_type_index ON public.generated_documents USING btree (product_id, document_type);


--
-- Name: generated_documents_product_id_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX generated_documents_product_id_status_index ON public.generated_documents USING btree (product_id, status);


--
-- Name: generated_documents_recipient_email_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX generated_documents_recipient_email_index ON public.generated_documents USING btree (recipient_email);


--
-- Name: generated_documents_valid_until_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX generated_documents_valid_until_index ON public.generated_documents USING btree (valid_until);


--
-- Name: generated_documents_workflow_execution_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX generated_documents_workflow_execution_id_index ON public.generated_documents USING btree (workflow_execution_id);


--
-- Name: information_sources_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX information_sources_product_id_index ON public.information_sources USING btree (product_id);


--
-- Name: information_sources_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX information_sources_user_id_index ON public.information_sources USING btree (user_id);


--
-- Name: invitation_workspaces_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX invitation_workspaces_product_id_index ON public.invitation_workspaces USING btree (product_id);


--
-- Name: invitation_workspaces_team_invitation_id_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX invitation_workspaces_team_invitation_id_product_id_index ON public.invitation_workspaces USING btree (team_invitation_id, product_id);


--
-- Name: pending_approvals_conversation_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pending_approvals_conversation_id_index ON public.pending_approvals USING btree (conversation_id);


--
-- Name: pending_approvals_expires_at_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pending_approvals_expires_at_index ON public.pending_approvals USING btree (expires_at);


--
-- Name: pending_approvals_product_id_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pending_approvals_product_id_status_index ON public.pending_approvals USING btree (product_id, status);


--
-- Name: pending_approvals_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pending_approvals_status_index ON public.pending_approvals USING btree (status);


--
-- Name: pending_approvals_user_id_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pending_approvals_user_id_status_index ON public.pending_approvals USING btree (user_id, status);


--
-- Name: pending_approvals_workflow_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pending_approvals_workflow_id_index ON public.pending_approvals USING btree (workflow_id);


--
-- Name: product_contexts_custom_overrides_gin_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX product_contexts_custom_overrides_gin_idx ON public.product_contexts USING gin (custom_overrides);


--
-- Name: product_contexts_master_context_gin_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX product_contexts_master_context_gin_idx ON public.product_contexts USING gin (master_context);


--
-- Name: product_contexts_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX product_contexts_product_id_index ON public.product_contexts USING btree (product_id);


--
-- Name: product_contexts_source_metadata_gin_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX product_contexts_source_metadata_gin_idx ON public.product_contexts USING gin (source_metadata);


--
-- Name: product_contexts_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX product_contexts_status_index ON public.product_contexts USING btree (status);


--
-- Name: product_contexts_updated_at_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX product_contexts_updated_at_index ON public.product_contexts USING btree (updated_at);


--
-- Name: products_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX products_user_id_index ON public.products USING btree (user_id);


--
-- Name: team_invitations_email_accepted_at_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX team_invitations_email_accepted_at_index ON public.team_invitations USING btree (email, accepted_at);


--
-- Name: team_invitations_invited_by_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX team_invitations_invited_by_id_index ON public.team_invitations USING btree (invited_by_id);


--
-- Name: team_invitations_token_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX team_invitations_token_index ON public.team_invitations USING btree (token);


--
-- Name: user_notification_settings_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_notification_settings_product_id_index ON public.user_notification_settings USING btree (product_id);


--
-- Name: user_notification_settings_user_id_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_notification_settings_user_id_product_id_index ON public.user_notification_settings USING btree (user_id, product_id);


--
-- Name: user_workflows_priority_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_workflows_priority_index ON public.user_workflows USING btree (priority);


--
-- Name: user_workflows_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_workflows_product_id_index ON public.user_workflows USING btree (product_id);


--
-- Name: user_workflows_product_id_is_active_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_workflows_product_id_is_active_index ON public.user_workflows USING btree (product_id, is_active);


--
-- Name: user_workflows_trigger_type_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_workflows_trigger_type_index ON public.user_workflows USING btree (trigger_type);


--
-- Name: user_workflows_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_workflows_user_id_index ON public.user_workflows USING btree (user_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_invited_by_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_invited_by_id_index ON public.users USING btree (invited_by_id);


--
-- Name: users_tokens_context_token_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_tokens_context_token_index ON public.users_tokens USING btree (context, token);


--
-- Name: users_tokens_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_tokens_user_id_index ON public.users_tokens USING btree (user_id);


--
-- Name: workflow_executions_conversation_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_executions_conversation_id_index ON public.workflow_executions USING btree (conversation_id);


--
-- Name: workflow_executions_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_executions_product_id_index ON public.workflow_executions USING btree (product_id);


--
-- Name: workflow_executions_product_id_status_started_at_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_executions_product_id_status_started_at_index ON public.workflow_executions USING btree (product_id, status, started_at);


--
-- Name: workflow_executions_started_at_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_executions_started_at_index ON public.workflow_executions USING btree (started_at);


--
-- Name: workflow_executions_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_executions_status_index ON public.workflow_executions USING btree (status);


--
-- Name: workflow_executions_workflow_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_executions_workflow_id_index ON public.workflow_executions USING btree (workflow_id);


--
-- Name: workflow_tasks_conversation_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_tasks_conversation_id_index ON public.workflow_tasks USING btree (conversation_id);


--
-- Name: workflow_tasks_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_tasks_product_id_index ON public.workflow_tasks USING btree (product_id);


--
-- Name: workflow_tasks_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_tasks_status_index ON public.workflow_tasks USING btree (status);


--
-- Name: workflow_tasks_workflow_execution_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_tasks_workflow_execution_id_index ON public.workflow_tasks USING btree (workflow_execution_id);


--
-- Name: workflow_tasks_workflow_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_tasks_workflow_id_index ON public.workflow_tasks USING btree (workflow_id);


--
-- Name: workflow_templates_category_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_templates_category_index ON public.workflow_templates USING btree (category);


--
-- Name: workflow_templates_is_active_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_templates_is_active_index ON public.workflow_templates USING btree (is_active);


--
-- Name: workflow_templates_is_featured_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_templates_is_featured_index ON public.workflow_templates USING btree (is_featured);


--
-- Name: workflow_templates_is_system_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workflow_templates_is_system_index ON public.workflow_templates USING btree (is_system);


--
-- Name: workflow_templates_template_id_version_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX workflow_templates_template_id_version_index ON public.workflow_templates USING btree (template_id, version);


--
-- Name: workspace_members_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workspace_members_product_id_index ON public.workspace_members USING btree (product_id);


--
-- Name: workspace_members_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX workspace_members_user_id_index ON public.workspace_members USING btree (user_id);


--
-- Name: workspace_members_user_id_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX workspace_members_user_id_product_id_index ON public.workspace_members USING btree (user_id, product_id);


--
-- Name: ai_usages ai_usages_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_usages
    ADD CONSTRAINT ai_usages_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: ai_usages ai_usages_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_usages
    ADD CONSTRAINT ai_usages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: call_conversations call_conversations_call_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.call_conversations
    ADD CONSTRAINT call_conversations_call_instance_id_fkey FOREIGN KEY (call_instance_id) REFERENCES public.call_instances(id);


--
-- Name: call_conversations call_conversations_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.call_conversations
    ADD CONSTRAINT call_conversations_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: call_conversations call_conversations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.call_conversations
    ADD CONSTRAINT call_conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: call_instances call_instances_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.call_instances
    ADD CONSTRAINT call_instances_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: call_instances call_instances_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.call_instances
    ADD CONSTRAINT call_instances_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: chat_messages chat_messages_chat_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_chat_session_id_fkey FOREIGN KEY (chat_session_id) REFERENCES public.chat_sessions(id) ON DELETE CASCADE;


--
-- Name: chat_sessions chat_sessions_chatbot_config_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_sessions
    ADD CONSTRAINT chat_sessions_chatbot_config_id_fkey FOREIGN KEY (chatbot_config_id) REFERENCES public.chatbot_configs(id) ON DELETE CASCADE;


--
-- Name: chat_sessions chat_sessions_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_sessions
    ADD CONSTRAINT chat_sessions_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: chatbot_analytics chatbot_analytics_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbot_analytics
    ADD CONSTRAINT chatbot_analytics_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: chatbot_analytics chatbot_analytics_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbot_analytics
    ADD CONSTRAINT chatbot_analytics_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: chatbot_configs chatbot_configs_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbot_configs
    ADD CONSTRAINT chatbot_configs_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: generated_documents generated_documents_parent_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_documents
    ADD CONSTRAINT generated_documents_parent_document_id_fkey FOREIGN KEY (parent_document_id) REFERENCES public.generated_documents(id) ON DELETE SET NULL;


--
-- Name: generated_documents generated_documents_pending_approval_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_documents
    ADD CONSTRAINT generated_documents_pending_approval_id_fkey FOREIGN KEY (pending_approval_id) REFERENCES public.pending_approvals(id) ON DELETE SET NULL;


--
-- Name: generated_documents generated_documents_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_documents
    ADD CONSTRAINT generated_documents_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: generated_documents generated_documents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_documents
    ADD CONSTRAINT generated_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: generated_documents generated_documents_workflow_execution_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_documents
    ADD CONSTRAINT generated_documents_workflow_execution_id_fkey FOREIGN KEY (workflow_execution_id) REFERENCES public.workflow_executions(id) ON DELETE SET NULL;


--
-- Name: information_sources information_sources_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.information_sources
    ADD CONSTRAINT information_sources_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: information_sources information_sources_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.information_sources
    ADD CONSTRAINT information_sources_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: invitation_workspaces invitation_workspaces_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitation_workspaces
    ADD CONSTRAINT invitation_workspaces_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: invitation_workspaces invitation_workspaces_team_invitation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitation_workspaces
    ADD CONSTRAINT invitation_workspaces_team_invitation_id_fkey FOREIGN KEY (team_invitation_id) REFERENCES public.team_invitations(id) ON DELETE CASCADE;


--
-- Name: pending_approvals pending_approvals_decided_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pending_approvals
    ADD CONSTRAINT pending_approvals_decided_by_fkey FOREIGN KEY (decided_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: pending_approvals pending_approvals_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pending_approvals
    ADD CONSTRAINT pending_approvals_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: pending_approvals pending_approvals_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pending_approvals
    ADD CONSTRAINT pending_approvals_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: pending_approvals pending_approvals_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pending_approvals
    ADD CONSTRAINT pending_approvals_workflow_id_fkey FOREIGN KEY (workflow_id) REFERENCES public.user_workflows(id) ON DELETE CASCADE;


--
-- Name: product_contexts product_contexts_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_contexts
    ADD CONSTRAINT product_contexts_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: products products_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: team_invitations team_invitations_invited_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_invitations
    ADD CONSTRAINT team_invitations_invited_by_id_fkey FOREIGN KEY (invited_by_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_notification_settings user_notification_settings_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_notification_settings
    ADD CONSTRAINT user_notification_settings_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: user_notification_settings user_notification_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_notification_settings
    ADD CONSTRAINT user_notification_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_workflows user_workflows_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_workflows
    ADD CONSTRAINT user_workflows_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: user_workflows user_workflows_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_workflows
    ADD CONSTRAINT user_workflows_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users users_invited_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_invited_by_id_fkey FOREIGN KEY (invited_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: users_tokens users_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: workflow_executions workflow_executions_pending_approval_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_executions
    ADD CONSTRAINT workflow_executions_pending_approval_id_fkey FOREIGN KEY (pending_approval_id) REFERENCES public.pending_approvals(id) ON DELETE SET NULL;


--
-- Name: workflow_executions workflow_executions_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_executions
    ADD CONSTRAINT workflow_executions_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: workflow_executions workflow_executions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_executions
    ADD CONSTRAINT workflow_executions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: workflow_executions workflow_executions_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_executions
    ADD CONSTRAINT workflow_executions_workflow_id_fkey FOREIGN KEY (workflow_id) REFERENCES public.user_workflows(id) ON DELETE CASCADE;


--
-- Name: workflow_tasks workflow_tasks_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_tasks
    ADD CONSTRAINT workflow_tasks_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: workflow_tasks workflow_tasks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_tasks
    ADD CONSTRAINT workflow_tasks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: workflow_tasks workflow_tasks_workflow_execution_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_tasks
    ADD CONSTRAINT workflow_tasks_workflow_execution_id_fkey FOREIGN KEY (workflow_execution_id) REFERENCES public.workflow_executions(id) ON DELETE SET NULL;


--
-- Name: workflow_tasks workflow_tasks_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_tasks
    ADD CONSTRAINT workflow_tasks_workflow_id_fkey FOREIGN KEY (workflow_id) REFERENCES public.user_workflows(id) ON DELETE SET NULL;


--
-- Name: workflow_templates workflow_templates_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_templates
    ADD CONSTRAINT workflow_templates_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: workspace_members workspace_members_invited_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_invited_by_id_fkey FOREIGN KEY (invited_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: workspace_members workspace_members_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: workspace_members workspace_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 6NFYlkt1f4bKy5Da5ERyJvyXplCONYfKLLUZ4vvXzz5RAUSv3Zbb4h5QwpmogPd

