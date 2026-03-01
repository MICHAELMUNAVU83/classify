--
-- PostgreSQL database dump
--

\restrict IyjvT1eLyKFtLZDxZc5ML3P1C18Tif7ubhlNNw3rlDCA6fZw6cUWqaw3VyQeW4I

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
-- Name: bundle_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bundle_items (
    id bigint NOT NULL,
    bundle_id bigint,
    product_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.bundle_items OWNER TO postgres;

--
-- Name: bundle_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bundle_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bundle_items_id_seq OWNER TO postgres;

--
-- Name: bundle_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bundle_items_id_seq OWNED BY public.bundle_items.id;


--
-- Name: bundles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bundles (
    id bigint NOT NULL,
    title character varying(255),
    description text,
    image character varying(255),
    is_active boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.bundles OWNER TO postgres;

--
-- Name: bundles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bundles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bundles_id_seq OWNER TO postgres;

--
-- Name: bundles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bundles_id_seq OWNED BY public.bundles.id;


--
-- Name: collections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collections (
    id bigint NOT NULL,
    title character varying(255),
    slug character varying(255),
    image character varying(255),
    "position" integer,
    is_active boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.collections OWNER TO postgres;

--
-- Name: collections_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.collections_id_seq OWNER TO postgres;

--
-- Name: collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collections_id_seq OWNED BY public.collections.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    phone character varying(255),
    address text,
    order_count integer DEFAULT 0 NOT NULL,
    total_spent integer DEFAULT 0 NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_id_seq OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: info_pages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.info_pages (
    id bigint NOT NULL,
    slug character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    icon character varying(255),
    content text,
    meta_description character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.info_pages OWNER TO postgres;

--
-- Name: info_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.info_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.info_pages_id_seq OWNER TO postgres;

--
-- Name: info_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.info_pages_id_seq OWNED BY public.info_pages.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id bigint NOT NULL,
    reference character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    phone character varying(255),
    address text,
    total_amount integer DEFAULT 0 NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    items jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    promo_code character varying(255),
    discount_amount integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: product_images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_images (
    id bigint NOT NULL,
    image character varying(255),
    "position" character varying(255),
    product_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.product_images OWNER TO postgres;

--
-- Name: product_images_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_images_id_seq OWNER TO postgres;

--
-- Name: product_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_images_id_seq OWNED BY public.product_images.id;


--
-- Name: product_variants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variants (
    id bigint NOT NULL,
    color_name character varying(255),
    color_hex character varying(255),
    size character varying(255),
    stock_quantity character varying(255),
    product_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.product_variants OWNER TO postgres;

--
-- Name: product_variants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_variants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_variants_id_seq OWNER TO postgres;

--
-- Name: product_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_variants_id_seq OWNED BY public.product_variants.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    name character varying(255),
    slug character varying(255),
    description text,
    base_price integer,
    image character varying(255),
    badge_label character varying(255),
    badge_color character varying(255),
    is_featured boolean DEFAULT false NOT NULL,
    is_bestseller boolean DEFAULT false NOT NULL,
    is_new_arrival boolean DEFAULT false NOT NULL,
    "position" integer,
    status character varying(255),
    collection_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    size_advice text,
    shipping_returns text
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
-- Name: promo_codes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promo_codes (
    id bigint NOT NULL,
    code character varying(255) NOT NULL,
    description character varying(255),
    influencer_name character varying(255),
    discount_percent integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    usage_count integer DEFAULT 0 NOT NULL,
    max_uses integer,
    expires_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.promo_codes OWNER TO postgres;

--
-- Name: promo_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.promo_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.promo_codes_id_seq OWNER TO postgres;

--
-- Name: promo_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.promo_codes_id_seq OWNED BY public.promo_codes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: site_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.site_settings (
    id bigint NOT NULL,
    site_name character varying(255) DEFAULT 'Kulola''s Closet'::character varying,
    site_tagline character varying(255) DEFAULT 'Everyday Fashion, Effortlessly You'::character varying,
    primary_color character varying(255) DEFAULT '#C8001F'::character varying,
    font_heading character varying(255) DEFAULT 'Playfair Display'::character varying,
    font_body character varying(255) DEFAULT 'Instrument Sans'::character varying,
    font_script character varying(255) DEFAULT 'Dancing Script'::character varying,
    logo_url character varying(255),
    instagram_url character varying(255),
    whatsapp_number character varying(255),
    support_email character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.site_settings OWNER TO postgres;

--
-- Name: site_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.site_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.site_settings_id_seq OWNER TO postgres;

--
-- Name: site_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.site_settings_id_seq OWNED BY public.site_settings.id;


--
-- Name: testimonials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.testimonials (
    id bigint NOT NULL,
    name character varying(255),
    rating integer,
    image character varying(255),
    body text,
    is_active boolean DEFAULT false NOT NULL,
    "position" integer,
    product_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.testimonials OWNER TO postgres;

--
-- Name: testimonials_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.testimonials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.testimonials_id_seq OWNER TO postgres;

--
-- Name: testimonials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.testimonials_id_seq OWNED BY public.testimonials.id;


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
    role character varying(255) DEFAULT 'member'::character varying NOT NULL,
    name character varying(255),
    last_signed_in_at timestamp(0) without time zone
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
-- Name: bundle_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bundle_items ALTER COLUMN id SET DEFAULT nextval('public.bundle_items_id_seq'::regclass);


--
-- Name: bundles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bundles ALTER COLUMN id SET DEFAULT nextval('public.bundles_id_seq'::regclass);


--
-- Name: collections id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collections ALTER COLUMN id SET DEFAULT nextval('public.collections_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: info_pages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.info_pages ALTER COLUMN id SET DEFAULT nextval('public.info_pages_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: product_images id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_images ALTER COLUMN id SET DEFAULT nextval('public.product_images_id_seq'::regclass);


--
-- Name: product_variants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants ALTER COLUMN id SET DEFAULT nextval('public.product_variants_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: promo_codes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promo_codes ALTER COLUMN id SET DEFAULT nextval('public.promo_codes_id_seq'::regclass);


--
-- Name: site_settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_settings ALTER COLUMN id SET DEFAULT nextval('public.site_settings_id_seq'::regclass);


--
-- Name: testimonials id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.testimonials ALTER COLUMN id SET DEFAULT nextval('public.testimonials_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_tokens ALTER COLUMN id SET DEFAULT nextval('public.users_tokens_id_seq'::regclass);


--
-- Data for Name: bundle_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bundle_items (id, bundle_id, product_id, inserted_at, updated_at) FROM stdin;
1	1	1	2026-02-25 10:03:56	2026-02-25 10:03:56
2	1	2	2026-02-25 10:03:56	2026-02-25 10:03:56
3	1	4	2026-02-25 10:03:56	2026-02-25 10:03:56
4	1	8	2026-02-25 10:14:39	2026-02-25 10:14:39
\.


--
-- Data for Name: bundles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bundles (id, title, description, image, is_active, inserted_at, updated_at) FROM stdin;
1	The Evening Edit Bundle	Our curated evening bundle — the ultimate collection for the woman who commands every room. Includes the showstopping Crimson Flora Halter Gown, the ethereal Aisling Ball Gown, and the iconic Moher Infinity Dress. Three pieces, infinite possibilities.	/uploads/live_view_upload-1772014464-112817049116-1	t	2026-02-25 10:03:56	2026-02-25 10:14:33
\.


--
-- Data for Name: collections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collections (id, title, slug, image, "position", is_active, inserted_at, updated_at) FROM stdin;
1	Gowns	gowns	/uploads/live_view_upload-1772014392-783926839811-1	1	t	2026-02-25 10:03:56	2026-02-25 10:13:15
2	Dresses	dresses	/uploads/live_view_upload-1772014420-774533954664-2	2	t	2026-02-25 10:03:56	2026-02-25 10:13:44
4	Jackets	jackets	/uploads/live_view_upload-1772015898-834253335812-2	5	t	2026-02-25 10:38:20	2026-02-25 10:38:20
3	Palazzo Pants	palazzo-pants	/uploads/live_view_upload-1772014638-37699950038-2	3	t	2026-02-25 10:17:21	2026-02-26 10:49:34
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, email, name, phone, address, order_count, total_spent, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: info_pages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.info_pages (id, slug, title, icon, content, meta_description, is_active, "position", inserted_at, updated_at) FROM stdin;
1	how-to-order	How to Order	🛍️	## How to Place Your Order\n\nOrdering is simple and straightforward. Here's how:\n\n### Option 1 — Order via WhatsApp (Recommended)\n\n- Screenshot or share the product you love from our Instagram or website.\n- Send us a message on **WhatsApp: 0796 770 862**.\n- Let us know your **size**, preferred **colour**, and **delivery location**.\n- We'll confirm availability and send you the total including delivery.\n- Make payment via **M-Pesa Till No. 5894819**.\n- Send us the M-Pesa confirmation message.\n- Your order will be dispatched within 24 hours!\n\n### Option 2 — Order via the Website\n\n- Browse our collections and add items to your cart.\n- Proceed to **Checkout** and fill in your delivery details.\n- Complete payment via M-Pesa.\n- You'll receive an order confirmation via email or WhatsApp.\n\n### Custom & Bespoke Orders\n\nFor gowns marked as **custom made**, please WhatsApp us with your measurements:\n- Bust, Waist, Hips (in cm)\n- Height\n- Event date (to ensure on-time delivery)\n\nAllow **2–3 weeks** for custom production.\n\n## Payment Methods\n\n- **M-Pesa Till No. 5894819**\n- Bank transfer (available on request)\n\n## Need Help?\n\nIf you have any trouble placing an order, reach out on WhatsApp and we'll assist you immediately.\n	Step-by-step guide on how to place an order — shop online or via WhatsApp.	t	1	2026-02-25 10:03:56	2026-02-25 10:03:56
2	size-guide	Size Guide	📐	## Finding Your Perfect Fit\n\nAll our garments are designed with real bodies in mind. We recommend taking your measurements before ordering.\n\n### How to Measure Yourself\n\n- **Bust** — Measure around the fullest part of your chest, keeping the tape parallel to the floor.\n- **Waist** — Measure around your natural waistline, the narrowest part of your torso.\n- **Hips** — Measure around the fullest part of your hips, about 20 cm below your waist.\n- **Height** — Stand straight against a wall and measure from floor to top of head.\n\n### UK Size Conversion Guide\n\n- **Size 8 UK** — Bust 80–84 cm | Waist 60–64 cm | Hips 86–90 cm\n- **Size 10 UK** — Bust 84–88 cm | Waist 64–68 cm | Hips 90–94 cm\n- **Size 12 UK** — Bust 88–94 cm | Waist 68–74 cm | Hips 94–100 cm\n- **Size 14 UK** — Bust 94–100 cm | Waist 74–80 cm | Hips 100–106 cm\n- **Size 16 UK** — Bust 100–106 cm | Waist 80–86 cm | Hips 106–112 cm\n\n### Custom & Bespoke Sizing\n\nFor gowns listed as custom made, we work directly with your measurements. WhatsApp us and we will guide you through the process.\n\n## Not Sure About Your Size?\n\nEvery product page includes specific size availability. You can also **WhatsApp us** with your measurements and we'll recommend the best fit for you.\n	Find your perfect fit — measurements for gowns, dresses and custom orders.	t	2	2026-02-25 10:03:56	2026-02-25 10:03:56
3	shipping-delivery	Shipping & Delivery	🚚	## Shipping & Delivery\n\nWe deliver across Kenya! Here's everything you need to know.\n\n### Nairobi Deliveries\n\n- **Standard Delivery** — 1–2 business days | **USD 200–300**\n- **Same-Day Delivery** — Available for orders placed before 12 PM | **USD 300–500** (select locations)\n- **Pick-Up** — Contact us on WhatsApp to arrange a convenient pick-up point.\n\n### Countrywide Deliveries\n\n- **Courier (G4S / Wells Fargo)** — 2–4 business days | **USD 400–600**\n- **Bus / Matatu Services** — 1–2 business days | Cost varies by distance\n\n### Custom Order Delivery\n\nCustom-made gowns require **2–3 weeks production time** before dispatch. We will keep you updated throughout the process via WhatsApp.\n\n### How Delivery Works\n\n- Once your order is confirmed and payment received, we process and pack within **24 hours**.\n- You'll receive a **WhatsApp notification** when your parcel is dispatched.\n\n## Questions?\n\nReach us on **WhatsApp: 0796 770 862** for any delivery enquiries.\n	Shipping and delivery information — Nairobi same-day delivery and countrywide shipping across Kenya.	t	3	2026-02-25 10:03:57	2026-02-25 10:03:57
4	returns-exchanges	Returns & Exchanges	🔄	## Returns & Exchanges\n\nWe want you to love every piece. If something isn't right, here's what you can do.\n\n### Our Policy\n\n- We accept **exchange requests** within **48 hours** of receiving your order.\n- Items must be **unworn, unwashed, and in original condition** with tags intact.\n- **Custom-made gowns** are final sale — we cannot accept returns or exchanges on bespoke orders.\n- **Sale items** are final sale and cannot be exchanged or returned.\n\n### Valid Reasons for Exchange\n\n- Wrong size sent (our error)\n- Wrong item sent (our error)\n- Item has a manufacturing defect\n\n### How to Request an Exchange\n\n- Contact us on **WhatsApp: 0796 770 862** within 48 hours of delivery.\n- Share your order details and clear photos of the item(s).\n- Our team will review and respond within 24 hours.\n\n### Refunds\n\n- We do not offer cash refunds except in cases where the item is out of stock and no suitable replacement is available.\n- Refunds, where applicable, are processed within **5–7 business days** via M-Pesa.\n\n## Contact Us\n\nIf you have any concerns about your order, please reach out promptly on **WhatsApp: 0796 770 862**.\n	Returns and exchanges policy — we want you to love every piece.	t	4	2026-02-25 10:03:57	2026-02-25 10:03:57
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, reference, email, name, phone, address, total_amount, status, items, inserted_at, updated_at, promo_code, discount_amount) FROM stdin;
1	KUL-2C23A3859AF2	michaelmunavu83@gmail.com	Michael Munavu	+254740769596	7576-kangundo	149	pending	{"{\\"id\\": 4, \\"key\\": \\"4__c1__8 UK\\", \\"name\\": \\"Moher Infinity Dress\\", \\"size\\": \\"8 UK\\", \\"slug\\": \\"moher-infinity-dress\\", \\"color\\": \\"Olive/Purple\\", \\"image\\": \\"/uploads/live_view_upload-1772014172-569614288612-1\\", \\"price\\": 149, \\"color_id\\": \\"c1\\", \\"quantity\\": 1}"}	2026-02-25 10:40:11	2026-02-25 10:40:11	\N	0
\.


--
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_images (id, image, "position", product_id, inserted_at, updated_at) FROM stdin;
1	/uploads/live_view_upload-1772013952-324268101212-3	1	1	2026-02-25 10:06:04	2026-02-25 10:06:04
2	/uploads/live_view_upload-1772014116-461409878238-2	1	7	2026-02-25 10:08:37	2026-02-25 10:08:37
3	/uploads/live_view_upload-1772014172-569614288612-1	1	4	2026-02-25 10:09:35	2026-02-25 10:09:35
5	/uploads/live_view_upload-1772014318-714377541193-1	1	5	2026-02-25 10:12:00	2026-02-25 10:12:00
6	/uploads/live_view_upload-1772014327-560415833999-1	2	5	2026-02-25 10:12:09	2026-02-25 10:12:09
8	/uploads/live_view_upload-1772014752-232768582813-2	1	9	2026-02-25 10:19:14	2026-02-25 10:19:14
9	/uploads/live_view_upload-1772015671-728518417464-5	1	10	2026-02-25 10:34:33	2026-02-25 10:34:33
10	/uploads/live_view_upload-1772015680-709984041508-2	2	10	2026-02-25 10:34:41	2026-02-25 10:34:41
11	/uploads/live_view_upload-1772015787-919194152283-2	1	11	2026-02-25 10:36:33	2026-02-25 10:36:33
12	/uploads/live_view_upload-1772098150-13022770640-3	1	13	2026-02-26 09:29:21	2026-02-26 09:29:21
13	/uploads/live_view_upload-1772098195-806634890165-3	2	13	2026-02-26 09:30:05	2026-02-26 09:30:05
14	/uploads/live_view_upload-1772098216-52351819873-1	3	13	2026-02-26 09:30:27	2026-02-26 09:30:27
15	/uploads/live_view_upload-1772098234-842290980217-3	4	13	2026-02-26 09:30:45	2026-02-26 09:30:45
16	/uploads/live_view_upload-1772098310-232595291354-2	1	3	2026-02-26 09:31:53	2026-02-26 09:31:53
17	/uploads/live_view_upload-1772098316-461974761174-1	2	3	2026-02-26 09:32:00	2026-02-26 09:32:00
18	/uploads/live_view_upload-1772098330-92497752766-1	3	3	2026-02-26 09:32:13	2026-02-26 09:32:13
19	/uploads/live_view_upload-1772098354-737070019398-3	4	3	2026-02-26 09:32:35	2026-02-26 09:32:35
20	/uploads/live_view_upload-1772098493-444315559214-1	1	14	2026-02-26 09:34:56	2026-02-26 09:34:56
21	/uploads/live_view_upload-1772098508-504737696128-2	2	14	2026-02-26 09:35:11	2026-02-26 09:35:11
22	/uploads/live_view_upload-1772098523-438424023739-1	3	14	2026-02-26 09:35:25	2026-02-26 09:35:25
23	/uploads/live_view_upload-1772099498-579264169821-1	1	15	2026-02-26 09:51:43	2026-02-26 09:51:43
24	/uploads/live_view_upload-1772099531-896995158351-2	2	15	2026-02-26 09:52:12	2026-02-26 09:52:12
25	/uploads/live_view_upload-1772099680-471104762844-3	1	2	2026-02-26 09:54:51	2026-02-26 09:54:51
26	/uploads/live_view_upload-1772099758-6690908847-1	2	2	2026-02-26 09:56:01	2026-02-26 09:56:01
27	/uploads/live_view_upload-1772099877-589340978536-2	2	4	2026-02-26 09:58:12	2026-02-26 09:58:12
28	/uploads/live_view_upload-1772099915-178077124346-3	3	4	2026-02-26 09:58:49	2026-02-26 09:58:49
29	/uploads/live_view_upload-1772099936-906133155532-1	4	4	2026-02-26 09:59:10	2026-02-26 09:59:10
30	/uploads/live_view_upload-1772099988-243422800272-1	3	10	2026-02-26 09:59:56	2026-02-26 09:59:56
31	/uploads/live_view_upload-1772099998-899851542713-1	4	10	2026-02-26 10:00:00	2026-02-26 10:00:00
32	/uploads/live_view_upload-1772100005-74211321448-2	5	10	2026-02-26 10:00:06	2026-02-26 10:00:06
33	/uploads/live_view_upload-1772100142-12272722804-1	1	16	2026-02-26 10:02:25	2026-02-26 10:02:25
34	/uploads/live_view_upload-1772100153-910549242628-2	2	16	2026-02-26 10:02:34	2026-02-26 10:02:34
35	/uploads/live_view_upload-1772100162-192580352432-1	3	16	2026-02-26 10:02:42	2026-02-26 10:02:42
36	/uploads/live_view_upload-1772100212-392574993903-2	3	5	2026-02-26 10:03:34	2026-02-26 10:03:34
37	/uploads/live_view_upload-1772100233-552935924877-1	4	5	2026-02-26 10:03:55	2026-02-26 10:03:55
38	/uploads/live_view_upload-1772100310-496835478235-1	2	7	2026-02-26 10:05:12	2026-02-26 10:05:12
39	/uploads/live_view_upload-1772100316-919500410411-2	3	7	2026-02-26 10:05:17	2026-02-26 10:05:17
40	/uploads/live_view_upload-1772100521-811671402448-1	1	17	2026-02-26 10:08:42	2026-02-26 10:08:42
41	/uploads/live_view_upload-1772100530-167508749341-2	2	17	2026-02-26 10:08:51	2026-02-26 10:08:51
42	/uploads/live_view_upload-1772100570-281332203568-2	3	17	2026-02-26 10:09:31	2026-02-26 10:09:31
43	/uploads/live_view_upload-1772100740-908843899948-1	1	8	2026-02-26 10:12:40	2026-02-26 10:12:40
44	/uploads/live_view_upload-1772100789-612741731286-1	2	8	2026-02-26 10:13:24	2026-02-26 10:13:24
45	/uploads/live_view_upload-1772100816-595895980905-1	3	8	2026-02-26 10:13:52	2026-02-26 10:13:52
46	/uploads/live_view_upload-1772100868-609061108656-1	2	6	2026-02-26 10:14:30	2026-02-26 10:14:30
47	/uploads/live_view_upload-1772100876-392268487331-2	3	6	2026-02-26 10:14:37	2026-02-26 10:14:37
48	/uploads/live_view_upload-1772100881-141284275764-3	4	6	2026-02-26 10:14:42	2026-02-26 10:14:42
49	/uploads/live_view_upload-1772100991-88742420583-1	1	18	2026-02-26 10:16:32	2026-02-26 10:16:32
50	/uploads/live_view_upload-1772101002-129034656109-1	2	18	2026-02-26 10:16:43	2026-02-26 10:16:43
\.


--
-- Data for Name: product_variants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variants (id, color_name, color_hex, size, stock_quantity, product_id, inserted_at, updated_at) FROM stdin;
1	Crimson Red	#CC2936	8 UK	5	1	2026-02-25 10:03:56	2026-02-25 10:03:56
2	Crimson Red	#CC2936	10 UK	5	1	2026-02-25 10:03:56	2026-02-25 10:03:56
3	Crimson Red	#CC2936	12 UK	5	1	2026-02-25 10:03:56	2026-02-25 10:03:56
4	Crimson Red	#CC2936	14 UK	5	1	2026-02-25 10:03:56	2026-02-25 10:03:56
5	Crimson Red	#CC2936	16 UK	5	1	2026-02-25 10:03:56	2026-02-25 10:03:56
6	Deep Russet	#8B3A3A	8 UK	5	1	2026-02-25 10:03:56	2026-02-25 10:03:56
7	Deep Russet	#8B3A3A	10 UK	5	1	2026-02-25 10:03:56	2026-02-25 10:03:56
8	Deep Russet	#8B3A3A	12 UK	5	1	2026-02-25 10:03:56	2026-02-25 10:03:56
9	Deep Russet	#8B3A3A	14 UK	5	1	2026-02-25 10:03:56	2026-02-25 10:03:56
10	Deep Russet	#8B3A3A	16 UK	5	1	2026-02-25 10:03:56	2026-02-25 10:03:56
12	Pristine White	#F5F5F5	10 UK	5	2	2026-02-25 10:03:56	2026-02-25 10:03:56
13	Pristine White	#F5F5F5	12 UK	5	2	2026-02-25 10:03:56	2026-02-25 10:03:56
14	Pristine White	#F5F5F5	14 UK	5	2	2026-02-25 10:03:56	2026-02-25 10:03:56
15	Pristine White	#F5F5F5	16 UK	5	2	2026-02-25 10:03:56	2026-02-25 10:03:56
16	Ivory	#FFFFF0	8 UK	5	2	2026-02-25 10:03:56	2026-02-25 10:03:56
17	Ivory	#FFFFF0	10 UK	5	2	2026-02-25 10:03:56	2026-02-25 10:03:56
18	Ivory	#FFFFF0	12 UK	5	2	2026-02-25 10:03:56	2026-02-25 10:03:56
19	Ivory	#FFFFF0	14 UK	5	2	2026-02-25 10:03:56	2026-02-25 10:03:56
20	Ivory	#FFFFF0	16 UK	5	2	2026-02-25 10:03:56	2026-02-25 10:03:56
21	Pristine Ivory	#FFFFF0	8 UK	5	3	2026-02-25 10:03:56	2026-02-25 10:03:56
22	Pristine Ivory	#FFFFF0	10 UK	5	3	2026-02-25 10:03:56	2026-02-25 10:03:56
23	Pristine Ivory	#FFFFF0	12 UK	5	3	2026-02-25 10:03:56	2026-02-25 10:03:56
24	Pristine Ivory	#FFFFF0	14 UK	5	3	2026-02-25 10:03:56	2026-02-25 10:03:56
25	Pristine Ivory	#FFFFF0	16 UK	5	3	2026-02-25 10:03:56	2026-02-25 10:03:56
26	Olive/Purple	#6B7C4A	8 UK	5	4	2026-02-25 10:03:56	2026-02-25 10:03:56
27	Olive/Purple	#6B7C4A	10 UK	5	4	2026-02-25 10:03:56	2026-02-25 10:03:56
28	Olive/Purple	#6B7C4A	12 UK	5	4	2026-02-25 10:03:56	2026-02-25 10:03:56
29	Olive/Purple	#6B7C4A	14 UK	5	4	2026-02-25 10:03:56	2026-02-25 10:03:56
30	Olive/Purple	#6B7C4A	16 UK	5	4	2026-02-25 10:03:56	2026-02-25 10:03:56
31	Plum/Purple	#6B2D6B	8 UK	5	4	2026-02-25 10:03:56	2026-02-25 10:03:56
32	Plum/Purple	#6B2D6B	10 UK	5	4	2026-02-25 10:03:56	2026-02-25 10:03:56
33	Plum/Purple	#6B2D6B	12 UK	5	4	2026-02-25 10:03:56	2026-02-25 10:03:56
34	Plum/Purple	#6B2D6B	14 UK	5	4	2026-02-25 10:03:56	2026-02-25 10:03:56
35	Plum/Purple	#6B2D6B	16 UK	5	4	2026-02-25 10:03:56	2026-02-25 10:03:56
36	Golden Ochre	#C9A84C	8 UK	5	5	2026-02-25 10:03:56	2026-02-25 10:03:56
37	Golden Ochre	#C9A84C	10 UK	5	5	2026-02-25 10:03:56	2026-02-25 10:03:56
38	Golden Ochre	#C9A84C	12 UK	5	5	2026-02-25 10:03:56	2026-02-25 10:03:56
39	Golden Ochre	#C9A84C	14 UK	5	5	2026-02-25 10:03:56	2026-02-25 10:03:56
40	Golden Ochre	#C9A84C	16 UK	5	5	2026-02-25 10:03:56	2026-02-25 10:03:56
41	Earthy Rust	#A0522D	8 UK	5	5	2026-02-25 10:03:56	2026-02-25 10:03:56
42	Earthy Rust	#A0522D	10 UK	5	5	2026-02-25 10:03:56	2026-02-25 10:03:56
43	Earthy Rust	#A0522D	12 UK	5	5	2026-02-25 10:03:56	2026-02-25 10:03:56
44	Earthy Rust	#A0522D	14 UK	5	5	2026-02-25 10:03:56	2026-02-25 10:03:56
45	Earthy Rust	#A0522D	16 UK	5	5	2026-02-25 10:03:56	2026-02-25 10:03:56
46	Golden Ochre	#C9A84C	8 UK	5	6	2026-02-25 10:03:56	2026-02-25 10:03:56
47	Golden Ochre	#C9A84C	10 UK	5	6	2026-02-25 10:03:56	2026-02-25 10:03:56
48	Golden Ochre	#C9A84C	12 UK	5	6	2026-02-25 10:03:56	2026-02-25 10:03:56
49	Golden Ochre	#C9A84C	14 UK	5	6	2026-02-25 10:03:56	2026-02-25 10:03:56
50	Golden Ochre	#C9A84C	16 UK	5	6	2026-02-25 10:03:56	2026-02-25 10:03:56
51	Aqua Blue	#4FC3C3	8 UK	5	7	2026-02-25 10:03:56	2026-02-25 10:03:56
52	Aqua Blue	#4FC3C3	10 UK	5	7	2026-02-25 10:03:56	2026-02-25 10:03:56
53	Aqua Blue	#4FC3C3	12 UK	5	7	2026-02-25 10:03:56	2026-02-25 10:03:56
54	Aqua Blue	#4FC3C3	14 UK	5	7	2026-02-25 10:03:56	2026-02-25 10:03:56
55	Aqua Blue	#4FC3C3	16 UK	5	7	2026-02-25 10:03:56	2026-02-25 10:03:56
56	Silver Grey	#9CA3AF	8 UK	5	7	2026-02-25 10:03:56	2026-02-25 10:03:56
57	Silver Grey	#9CA3AF	10 UK	5	7	2026-02-25 10:03:56	2026-02-25 10:03:56
58	Silver Grey	#9CA3AF	12 UK	5	7	2026-02-25 10:03:56	2026-02-25 10:03:56
59	Silver Grey	#9CA3AF	14 UK	5	7	2026-02-25 10:03:56	2026-02-25 10:03:56
60	Silver Grey	#9CA3AF	16 UK	5	7	2026-02-25 10:03:56	2026-02-25 10:03:56
61	Light Blue Stripe	#B8D4E8	8 UK	5	8	2026-02-25 10:03:56	2026-02-25 10:03:56
62	Light Blue Stripe	#B8D4E8	10 UK	5	8	2026-02-25 10:03:56	2026-02-25 10:03:56
63	Light Blue Stripe	#B8D4E8	12 UK	5	8	2026-02-25 10:03:56	2026-02-25 10:03:56
64	Light Blue Stripe	#B8D4E8	14 UK	5	8	2026-02-25 10:03:56	2026-02-25 10:03:56
65	Light Blue Stripe	#B8D4E8	16 UK	5	8	2026-02-25 10:03:56	2026-02-25 10:03:56
66	White Stripe	#F5F5F5	8 UK	5	8	2026-02-25 10:03:56	2026-02-25 10:03:56
67	White Stripe	#F5F5F5	10 UK	5	8	2026-02-25 10:03:56	2026-02-25 10:03:56
68	White Stripe	#F5F5F5	12 UK	5	8	2026-02-25 10:03:56	2026-02-25 10:03:56
69	White Stripe	#F5F5F5	14 UK	5	8	2026-02-25 10:03:56	2026-02-25 10:03:56
70	White Stripe	#F5F5F5	16 UK	5	8	2026-02-25 10:03:56	2026-02-25 10:03:56
72	ewrt	#000000	6 uk	10	9	2026-02-25 10:20:54	2026-02-25 10:20:54
11	Pristine White	#be2d2d	8 UK	5	2	2026-02-25 10:03:56	2026-02-25 14:54:42
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, slug, description, base_price, image, badge_label, badge_color, is_featured, is_bestseller, is_new_arrival, "position", status, collection_id, inserted_at, updated_at, size_advice, shipping_returns) FROM stdin;
6	Mara Lithic Shirt Dress	mara-lithic-shirt-dress	Evoke the raw, enduring beauty of nature with the Mara Lithic Shirt Dress. This piece is a celebration of organic textures, featuring a custom bark-inspired print meticulously crafted from intricate patterns and rugged aesthetics of tree bark. The 'Lithic' name hints at its earthy, stone-like resilience, while the design remains fluid and feminine. Crafted from high-quality cotton fabric, this dress offers breathable comfort without sacrificing its structured, sophisticated silhouette. Features include a bark-inspired complex earth-toned print, a high-low hemline with asymmetrical cut for modern movement, a classic collar and button-down front, 3/4 length sleeves, and a cinched waist to highlight the natural frame. Style with transparent heels and gold hoops, or dress down with leather sandals.	149	/uploads/live_view_upload-1772014350-592159875589-1	\N	#f3f4f6	t	t	t	6	active	2	2026-02-25 10:03:56	2026-02-25 10:30:02	Available in sizes 10 and 12 UK. The cinched waist is adjustable. Runs true to UK sizing — if between sizes, size up for ease of movement through the shoulders.	Nairobi delivery USD 200–300 (1–2 days). Countrywide USD 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
3	Luna Pearl Corset Gown	luna-pearl-corset-gown	Step into your forever in a gown that balances timeless sophistication with a daring spirit. The Luna Pearl Corset Gown is crafted for the bride who wants to be remembered. Featuring a masterfully structured bodice and a sweeping, high-slit skirt, this piece is a masterclass in architectural bridal design. The bustier-style bodice is adorned with delicate lace overlays and subtle pearl-inspired beadwork, offering a secure, sculpted fit that emphasises the natural waist. A sleek A-line skirt crafted from high-luster Italian satin flows into a dramatic train, with a bold thigh-high slit adding a touch of Hollywood glamour and discreet side pockets for practical elegance.	1989	/uploads/live_view_upload-1772098297-869541406266-2	New	green	t	t	t	3	active	1	2026-02-25 10:03:56	2026-02-26 11:58:01	Available in size 10 UK. Designed to be fitted at the bust and waist, flowing loose from the hip. Features adjustable spaghetti straps, built-in padded cups and a concealed back zipper. Contact us for custom sizing.	Nairobi delivery USD 200–300 (1–2 days). Countrywide USD 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
4	Moher Infinity Dress	moher-infinity-dress	The Moher Infinity Dress is the ultimate wardrobe chameleon. The signature 'Moher' print captures the dramatic interplay of light and shadow found on the iconic Irish coastline, reimagined through a lens of rich, kaleidoscopic purples, teals, and sunset oranges. Featuring a structured, vibrant printed skirt and long luxurious silk satin straps, this piece allows you to transform your look in seconds — whether you prefer a modest cross-front, a daring plunge, or a sophisticated one-shoulder silhouette. The multi-way straps can be tied in over 15 different styles, making it perfect for weddings, cocktail parties, or elevated daywear. Thoughtfully designed with discreet side pockets.	149	/uploads/live_view_upload-1772014159-812563618298-2	Bestseller	red	t	t	t	4	active	2	2026-02-25 10:03:56	2026-02-25 10:30:32	Available in sizes 10, 12 and 14 UK. The wide waistband cinches the figure and the multi-way straps are fully adjustable — this dress works across a range of body types. If between sizes, size up for comfort in the skirt.	Nairobi delivery USD 200–300 (1–2 days). Countrywide USD 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
5	Mara Lithic Safari Dress	mara-lithic-safari-dress	The Mara Lithic Safari Dress is a sophisticated study of tree bark, featuring intricate, interlocking patterns of golden ochre, earthy rust, and slate grey that capture the rugged, beautiful essence of the wild — reimagined for the modern wardrobe. Crafted from 100% premium cotton for breathable comfort that transitions effortlessly from a day in the sun to an evening event. The versatile shirt-dress cut hits just above the knee with a classic collar and short sleeves for a structured yet relaxed look. An adjustable waist tie lets you define your silhouette — cinched for a tailored look or loose for a breezy, casual vibe. Completed with earthy, tonal buttons and subtle chest pockets.	149	/uploads/live_view_upload-1772014272-475454625215-2	New	green	t	t	t	5	active	2	2026-02-25 10:03:56	2026-02-25 10:30:12	Available in sizes 10, 12 and 14 UK. The adjustable waist tie gives flexibility across sizes. Runs true to UK sizing — if between sizes, size up for ease of movement.	Nairobi delivery USD 200–300 (1–2 days). Countrywide USD 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
2	Aisling Ball Gown	aisling-ball-gown	This stunning Midnight Satin & Lace Ball Gown is the epitome of timeless elegance, designed for the woman who wants to make a grand entrance. Combining architectural volume with delicate textures, this dress is a masterclass in evening sophistication. The bodice features a sleek, strapless sweetheart neckline with intricate floral lace overlays and structured boning for a tailored, flattering silhouette. The skirt is crafted from high-luster duchess satin, flowing into a full, dramatic circle with a regal pool effect for a 360-degree statement look. Perfect for black tie galas, prom, evening weddings, or any occasion that calls for elegant authority.	1989	/uploads/live_view_upload-1772014140-41595935231-1	Featured	blue	t	t	t	2	active	1	2026-02-25 10:03:56	2026-02-26 11:57:54	Available in size 10 UK. For other sizes, this gown can be made to order — contact us via WhatsApp with your measurements. Style tip: pair with a sleek updo and statement silver drop earrings for an Old Hollywood aesthetic.	Nairobi delivery USD 200–300 (1–2 days). Countrywide USD 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
14	THE CELESTE SILK COLUMN GOWN	celest-silk-column-gown	Ethereal Grace in Every Movement\nRadiate timeless sophistication in the Celeste Silk Column Gown. Designed for the woman who appreciates the intersection of classic bridal tradition and modern minimalism, this gown is a masterclass in texture and silhouette.\n\nThe Details\nIntricate Bodice: Features a meticulously textured, lace-overlaid bodice with a modest scoop neckline that provides a secure, comfortable fit without sacrificing style.\nSatin Luster: The skirt is crafted from premium, high-shine silk-satin that drapes effortlessly from the waist, cascading into a soft, romantic puddle train.\nStriking Profile: The sleeveless design and backless detailing offer a hint of allure, while the clean column silhouette elongates the frame for a statuesque look.\nThe Finish: Completed with a concealed back zipper and delicate structural boning to ensure a flawless fit through the evening.\nStyle Notes\nPerfect for a modern wedding, a gala, or a sophisticated formal event. Pair with statement drop earrings as shown and a sleek updo to highlight the open back and textured bodice.\nSpecifications\nFabric: Premium Silk Satin / Corded  custom made Lace \nSilhouette: Column / Sheath\nNeckline: Scoop\nTrain: Floor-length puddle train\nCare: Professional Dry Clean Only\n \nSIZE : 10 UK\n\nPRICE: 2000	1989	/uploads/live_view_upload-1772098484-663707789905-1	\N	#f3f4f6	t	t	t	1	active	1	2026-02-26 09:34:45	2026-02-26 11:58:16	\N	\N
7	Aqua Cascade Drift Shirt Dress	aqua-cascade-drift-shirt-dress	Inspired by the rhythmic movement and cooling mist of a cascading waterfall, the Aqua Cascade Drift Shirt Dress is a wearable work of art. The intricate blue and silver-grey print mirrors the play of light on rushing water, creating a visual texture that is both calming and dynamic. A versatile shirt-dress cut features a dramatic high-low hemline that offers graceful movement with every step. Crafted from high-quality breathable cotton, it keeps you cool and comfortable from morning brunch to evening events. Includes a classic pointed collar, full-length button-down front, deep integrated side pockets, structured long sleeves with button cuffs, and an adjustable waist belt for a polished finish. Style with clear acrylic heels or cinch with a wide belt to accentuate the waist.	159	/uploads/live_view_upload-1772100347-756582291417-2	New	green	t	t	t	7	active	2	2026-02-25 10:03:56	2026-02-26 10:05:48	Available in sizes 10 and 12 UK. Relaxed through the body with structured long sleeves. The removable belt allows you to adjust the fit at the waist. Runs true to UK sizing.	Nairobi delivery USD 200–300 (1–2 days). Countrywide USD 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
8	Legacy Button-Down Shirt Dress	legacy-button-down-shirt-dress	This stylish midi shirt dress combines effortless utility with a feminine silhouette, making it a versatile staple for any wardrobe. Crafted from a light-coloured, fine-striped fabric, it offers a clean, crisp aesthetic suitable for both professional and casual environments. Features a classic button-down front with a structured collar and relaxed drop-shoulder long sleeves that can be rolled up for a laid-back look. A flattering midi length with subtle side slits for ease of movement, dual chest patch pockets with button closures, practical side-seam pockets, and an adjustable waist via a removable belt. Style tip: remove the belt and wear it open over a tank top and denim as a lightweight duster coat for a completely different vibe.	150	/uploads/live_view_upload-1772014008-337990927613-3	Featured	blue	t	t	t	8	active	2	2026-02-25 10:03:56	2026-02-25 10:28:17	Runs true to size. Relaxed drop-shoulder cut — measure your bust and shoulders for the best fit. The removable belt cinches the waist and is fully adjustable. Pairs perfectly with tall black leather boots or white sneakers.	Nairobi delivery USD 200–300 (1–2 days). Countrywide USD 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
1	Crimson Flora Halter Gown	crimson-flora-halter-gown	Turn heads in our Crimson Flora Halter Gown. This piece balances the architectural strength of a high-neckline with the soft romance of hand-placed floral appliqués. The luminous satin skirt flows effortlessly into an elongated train, ensuring every step you take is cinematic. Pair with minimal jewelry to let the bodice's exquisite craftsmanship take center stage.	1989	/uploads/live_view_upload-1772013934-457468476003-1	Bestseller	red	t	t	t	1	active	1	2026-02-25 10:03:56	2026-02-26 11:58:09	This gown is custom made to order. Please provide your exact measurements — bust, waist, hips and height — when placing your order. Allow 2–3 weeks for production. Contact us via WhatsApp to begin your custom order.	Nairobi delivery USD 200–300 (1–2 days). Countrywide USD 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
9	MARA LITHIC PALAZZO PANTS	mara-lithic-palazzo-pants	Inspired by the ancient, enduring textures of the earth and the protective skin of the forest, the Mara Lithic Palazzo Pants are a masterpiece of organic style. These aren't just trousers; they are a wearable landscape.\nThe Design Philosophy\nThe "Mara Lithic" print draws its soul from the intricate patterns of tree bark, blending earthy ochre, deep crimson, and mossy slate into a visual texture that feels both ancient and contemporary. The name itself—a nod to the stone-like permanence of nature—reflects a design built to transcend fleeting trends.\nVersatility & Silhouette\nCrafted from premium, breathable cotton, these palazzo pants offer a high-waisted, wide-leg silhouette that marries dramatic movement with everyday comfort. As shown in our gallery, the Mara Lithic adapts to your rhythm:\nThe Power Set: Pair with our matching Mara Lithic ruffled blouse or off-the-shoulder top for a bold, monochromatic statement that commands attention.\nCasual Chic: Dress them down with a simple white crop or a pastel turtleneck to let the complex "bark" print take center stage.\nEffortless Elegance: The structural integrity of the cotton ensures the wide leg maintains its shape, whether you’re strolling through a garden or attending a gallery opening.\n"Texture is the storyteller of the natural world. With the Mara Lithic, we’ve brought that story to your wardrobe."\nProduct Details\nMaterial: 100% High-quality breathable cotton.\nFit: High-rise waist with a voluminous, floor-sweeping wide leg.\nFeatures: Deep side pockets and a tailored waistband for a flattering finish.\nOrigin: Proudly part of the Tomollo collection.	149	/uploads/live_view_upload-1772014724-356586194567-2	Hot	#f2f4f1	t	t	t	8	active	3	2026-02-25 10:18:46	2026-02-25 10:18:46	\N	\N
10	MOHER PALAZZO PANTS	moher-palazzo-pants	Capture the untamed beauty of the Irish coastline with our Moher Palazzo Pants. Featuring a vibrant, abstract print inspired by the rugged textures and deep hues of the Cliffs of Moher, these pants are a wearable piece of art designed for the bold minimalist and the color-enthusiast alike.\nDesign Details\nArtistic Print: A rich tapestry of deep violets, electric blues, and mossy greens, mimicking the cliffside flora and Atlantic depths.\nThe Cut: A high-waisted, wide-leg silhouette that offers dramatic movement and an elongated profile.\nThe Fabric: Crafted from 100% premium cotton, ensuring breathability and comfort from city streets to seaside escapes.\nPracticality: Features a structured waistband with a button closure and deep side pockets—because style should always be functional.\nStyle It Your Way\nThese palazzos are the ultimate wardrobe chameleon.\nThe Full Set: Pair with our matching Moher off-the-shoulder top for a striking, head-to-toe jumpsuit effect.\nCasual Chic: Tuck in a crisp white or soft pink off-the-shoulder blouse for an airy, feminine look.\nModern Edge: Contrast the voluminous bottom with a sleek, black cropped turtleneck for a sophisticated, transitional outfit.\n\nSIZES: 10 UK, 12 UK, 14 UK, 16 UK \n\nPRICE: USD 159	159	/uploads/live_view_upload-1772015659-307604592658-5	\N	#f3f4f6	t	t	t	4	active	3	2026-02-25 10:34:21	2026-02-25 10:34:21	\N	\N
11	WATAMU PALAZZO PANTS	watamu-palazzo-pants	Coastal Elegance Redefined\nCapture the vibrant soul of the Kenyan coast with our Watamu Palazzo Pants. Designed for the woman who carries the spirit of the ocean wherever she goes, these pants are a masterclass in effortless, tropical style.\nThe Inspiration\nThe "Watamu Print" is a visual love letter to the pristine shores of its namesake. Featuring a deep, aquatic blue base, the pattern is layered with intricate textures of coral reefs, emerald sea moss, and sun-drenched earth tones. It’s more than a print—it's a wearable piece of paradise.\nThe Design\nFluid Silhouette: High-waisted with a dramatic wide-leg cut that mimics the movement of the tides.\nMaximum Comfort: Features a comfortable back elasticated waistband and essential side pockets for a relaxed, functional fit.\nNatural Breathability: Crafted from 100% premium cotton fabric, ensuring you stay cool and crisp even in the midday heat.\nStyling Tips\nThe Full Set: Pair with our matching Watamu Off-the-Shoulder Crop Top for a bold, head-turning co-ord look perfect for sunset dinners.\nBeachside Minimalist: Swap the matching top for a simple olive or white tank to let the intricate print take center stage.\nFootwear: Looks stunning with metallic gladiator sandals or simple barefoot luxury on the sand.\nFabric Care: 100% Cotton. Cold hand wash or delicate machine wash recommended to preserve the vibrancy of the Watamu print.	159	/uploads/live_view_upload-1772015768-692164517188-3	\N	#f3f4f6	t	t	t	10	draft	3	2026-02-25 10:36:14	2026-02-25 10:36:14	\N	\N
12	EMERALD AZURE HOODED BOMBER JACKET	emerald-azure-hooded-bomber-jacket	Inspired by Ballinastoe Woods\nThis lightweight bomber jacket merges high-performance wear with the ethereal beauty of the Irish landscape. The "Emerald Azure" print captures the deep teals, mossy greens, and fractured light found within the iconic Ballinastoe Woods, creating a wearable piece of art.\nProduct Highlights\nDesign: Features a vibrant, all-over abstract print inspired by the forest floor and canopy of County Wicklow.\nMaterial: Crafted from durable, weather-resistant polyester fabric, making it ideal for coastal breezes or city walks.\nVersatility: Includes a functional hood with a high-contrast lining (available in deep azure or slate black) to protect against the elements.\nFit: Modern, athletic silhouette with ribbed cuffs and hem for a secure, comfortable fit.\nStyle DetailsFeature Description\nFabric 100% Premium Polyester\nColorway Emerald, Azure, Gold, and Deep Navy\nDetails Full-zip front, dual side pockets, and integrated hood\nOrigin Print inspired by Ballinastoe Woods, Ireland	159	/uploads/live_view_upload-1772015947-838640859260-1	\N	#f3f4f6	t	t	t	10	active	4	2026-02-25 10:39:09	2026-02-25 10:39:09	\N	\N
13	URBAN EDGE BOMBER JACKET	urban-edge-bomber-jacket	Versatility meets heritage. Crafted from 100% premium cotton, these jackets are designed for those who value comfort without sacrificing style. Whether you’re hitting the city streets or looking for a cozy layer for a weekend getaway, this jacket is your new go-to.\nKey Features\nPure Comfort: Breathable 100% cotton fabric for all-day wear.\nSignature Prints: Features bold, monochrome geometric and textured patterns that make a statement.\nCustom Fit Options: Available in Hooded versions for a sporty, laid-back vibe or Classic Bomber (non-hooded) for a sleek, streamlined look.\nFunctional Detail: Secure zip-front closure with ribbed cuffs and collar to lock in warmth.\nFor Him & For Her\nDesigned with a modern, unisex silhouette, these jackets are perfect for matching moments or individual expression.\nFor Her: Style it with leggings and boots for an edgy look (as seen on our model), or pair it with shorts for a playful, transition-season outfit.\nFor Him: Pair with dark denim or joggers for an effortless, high-fashion streetwear aesthetic.\nChoose your style. Choose your vibe. Wear the culture.\n\nSIZES : M, L, XL\n\nPRICE: USD 199	199	/uploads/live_view_upload-1772098122-317663249770-1	New	#f3f4f6	t	t	t	8	active	4	2026-02-26 09:28:53	2026-02-26 09:28:53	\N	\N
15	THE SAFARI HYBRID BOMBER JACKET	safari-hybrid-bomber-jacket	Classic Utility Meets Modern Streetwear\nElevate your outerwear game with the Garrison Hybrid Bomber, a sophisticated take on the classic flight jacket. Engineered for the transition between seasons, this jacket blends the rugged appeal of a field coat with the sleek silhouette of a traditional bomber.\nProduct Highlights\nDistinctive Design: Features dual-entry chest flap pockets for a utilitarian edge, paired with a clean, streamlined zip front.\nContrasting Hardware: Deep black ribbed collar, cuffs, and hem provide a sharp contrast against the tan/sand-toned body, creating a framed, athletic look.\nSurprise Interior: Fully lined with a breathable, classic red and blue pinstripe fabric, offering a touch of sartorial personality every time you take it off.\nPremium Texture: Crafted from a durable, mid-weight fabric with a subtle tactile finish that holds its shape while resisting the elements.\nStyle & Fit\nWhether you’re navigating the city streets or a rugged coastline, the Garrison adapts to your environment:\nThe Urban Look: Pair it with a crisp white tee, slim-fit denim, and Chelsea boots for an effortless "city-cool" aesthetic.\nThe Coastal Vibe: Layer it over a hoodie or thermal with a beanie for a functional, wind-resistant outfit.\nFit Tip: Designed with a tailored, modern fit. It sits right at the waist for a classic bomber profile. For a more relaxed, layered look, we recommend sizing up.\nTechnical Specs\nMaterial: Premium cotton-poly blend shell.\nLining: 100% Cotton pinstripe.\nClosure: Heavy-duty reinforced front zipper.\nPockets: 2 button-down chest pockets; 2 hidden side-seam hand pockets.\n\nSIZES: L, XL, XXL \n\nPRICE : USD 189	189	/uploads/live_view_upload-1772098611-100433847652-1	\N	#f3f4f6	t	t	t	10	active	4	2026-02-26 09:36:57	2026-02-26 09:36:57	\N	\N
16	KENTE GRID BOMBER JACKET	kente-grid-bomber-jacket	Make a bold statement with a jacket that bridges the gap between global street style and rich cultural heritage. Our Kente-Grid Bomber features an intricate, all-over geometric pattern inspired by traditional African textile motifs, rendered in a sophisticated palette of deep ochre, earthy crimson, and obsidian black.\nCrafted with a sharp, unisex silhouette, this jacket is designed for those who value authenticity and high-impact style. The structured bomber cut is finished with premium ribbed detailing at the collar, cuffs, and hem, ensuring a perfect fit that holds its shape whether you're navigating the city streets or attending a gallery opening.\nKey Features\nSignature Print: A vibrant, high-definition geometric pattern that commands attention.\nVersatile Fit: A tailored bomber silhouette that looks just as good over a simple black tee as it does paired with a mini-skirt and boots.\nPremium Detailing: Durable full-zip front and reinforced ribbed finishes for a snug, athletic feel.\nYear-Round Wear: Lightweight enough for transitional layering, yet bold enough to be the centerpiece of any outfit.\nStyle Notes\nFor Him: Pair with slim-fit charcoal denim and white leather sneakers for a clean, minimalist look that lets the jacket do the talking.\nFor Her: Style it open with a black bodysuit and high-waisted skirt for a powerful, urban-chic ensemble\n\nSIZES: L, XL, XXL \nPRICE: USD 259	259	/uploads/live_view_upload-1772100124-805384809120-1	\N	#f3f4f6	t	t	t	2	active	4	2026-02-26 10:02:06	2026-02-26 10:02:06	\N	\N
17	THE AQUA CASCADE SHIRT	aqua-cascade-shirt	The "Aqua-Cascade" Shirt Dress\nWhere Artistry Meets the Shore.\nInspired by the rhythmic beauty of rushing waterfalls, this shirt dress features a mesmerizing, multi-tonal blue print inspired by Ngare Ndare waterfalls that captures the essence of fluid movement. Designed for the woman who values both comfort and a striking silhouette, it’s a versatile piece that transitions seamlessly from a sunny brunch to a sophisticated seaside evening.\n\nKey Features\nWaterfall-Inspired Print: A vibrant, abstract pattern in deep cerulean and icy blues, designed to mimic the energy of falling water.\n\nHigh-Low Hemline: A modern, curved hem that is shorter in the front and longer in the back, offering a flattering leg lengthening effect.\n\nPremium Cotton Comfort: Crafted from 100% breathable cotton fabric, ensuring you stay cool and comfortable all day long.\nClassic Tailoring: Features a sharp collar, a relaxed V-neckline, and 3/4 length sleeves for a polished yet breezy look.\n\nEffortless Silhouette: A relaxed fit that provides freedom of movement without sacrificing style.\nStyle Notes\nPair it with clear acrylic heels (as pictured) to keep the focus on the vibrant print, or dress it down with white sneakers for an elevated casual look.\n\nSIZE: 10UK , 12 UK, 14 UK\n\nPRICE: USD 150\n	150	/uploads/live_view_upload-1772100439-576438241466-2	\N	#f3f4f6	t	t	t	1	active	2	2026-02-26 10:07:20	2026-02-26 10:07:20	\N	\N
18	 AQUA CASCADE PALAZZO PANTS	aqua-cascade-palazzo-pants	Make a splash without leaving the shore and the waterfalls.\nEffortless, airy, and undeniably bold, the Aqua Cascade Palazzo Pants are designed for the woman who moves like water. Featuring a mesmerizing abstract print in depths of cerulean, turquoise, and seafoam, these pants bring a refreshing energy to any wardrobe.\nWhy You’ll Love Them:\nThe Silhouette: A dramatic wide-leg cut that offers maximum movement and a flattering, elongated frame.\nThe Print: A high-definition "Aqua Cascade" pattern that mimics the rhythmic beauty  the beauty of the Ngare Ndare waterfalls \nThe Fit: High-waisted with tailored pleats to ensure a structured yet comfortable drape.\nVersatility: As shown, these pants pair perfectly with everything from sleek, off-the-shoulder bodysuits to matching cropped puff-sleeve tops for a coordinated "resort-ready" look.\nStyle Suggestions:\nFor the Minimalist: Pair with a crisp white off-the-shoulder top and gold platform sandals to let the print do the talking.\nFor the Bold: Go head-to-toe with our matching Aqua Cascade Crop Top for a striking monochrome ensemble.\nThe Finish: Add oversized sunglasses and gold jewelry to lean into the sophisticated, sun-drenched aesthetic.\nFabric & Care: Lightweight, breathable fabric perfect for tropical climates or summer afternoons.\nSIZES: 10 UK,12 UK \n\nPRICE: USD 159 	159	/uploads/live_view_upload-1772100967-618199960894-2	\N	#f3f4f6	t	t	t	2	active	3	2026-02-26 10:16:08	2026-02-26 10:16:08	\N	\N
\.


--
-- Data for Name: promo_codes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promo_codes (id, code, description, influencer_name, discount_percent, is_active, usage_count, max_uses, expires_at, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (version, inserted_at) FROM stdin;
20260218042636	2026-02-25 10:03:56
20260221045341	2026-02-25 10:03:56
20260221051329	2026-02-25 10:03:56
20260221051746	2026-02-25 10:03:56
20260221052005	2026-02-25 10:03:56
20260221052106	2026-02-25 10:03:56
20260221052248	2026-02-25 10:03:56
20260221053555	2026-02-25 10:03:56
20260221120406	2026-02-25 10:03:56
20260222144930	2026-02-25 10:03:56
20260222160227	2026-02-25 10:03:56
20260223132605	2026-02-25 10:03:56
20260223200000	2026-02-25 10:03:56
20260223210000	2026-02-25 10:03:56
20260224080000	2026-02-25 10:03:56
\.


--
-- Data for Name: site_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.site_settings (id, site_name, site_tagline, primary_color, font_heading, font_body, font_script, logo_url, instagram_url, whatsapp_number, support_email, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: testimonials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.testimonials (id, name, rating, image, body, is_active, "position", product_id, inserted_at, updated_at) FROM stdin;
1	Amina W.	5	/images/people/woman1.jpg	I wore the Crimson Flora Halter Gown to my sister's wedding and I have never felt more stunning. The craftsmanship is incredible — every detail is perfection. Multiple people asked who made my dress!	t	1	1	2026-02-25 10:03:56	2026-02-25 10:03:56
2	Cynthia O.	5	/images/people/woman2.jpg	The Moher Infinity Dress is everything. I styled it four different ways in one week — to a gala, a brunch, a wedding and a date night. The print is absolutely breathtaking. Worth every penny.	t	2	4	2026-02-25 10:03:56	2026-02-25 10:03:56
3	Grace M.	5	/images/people/woman3.jpg	The Legacy Shirt Dress is my new everyday hero. I wear it belted to the office and open over jeans on weekends. The quality is outstanding — this is not fast fashion, this is investment dressing.	t	3	8	2026-02-25 10:03:56	2026-02-25 10:03:56
4	Fatuma K.	5	/images/people/woman4.jpg	My Luna Pearl Corset Gown arrived and I burst into tears — it is the most beautiful thing I have ever worn. The corsetry is so well constructed and the slit is absolutely stunning. My bridal moment is sorted.	t	4	3	2026-02-25 10:03:56	2026-02-25 10:03:56
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, hashed_password, confirmed_at, inserted_at, updated_at, role, name, last_signed_in_at) FROM stdin;
1	michaelmunavu83@gmail.com	$2b$12$MfL2gkeNP2ziXMN5OLFsE.rKLgDuE7nUt2sRwyobWX5ZFyQjnnRWy	2026-02-25 10:03:57	2026-02-25 10:03:57	2026-02-25 10:03:57	super_admin	Michael Munavu	2026-02-26 09:24:49
\.


--
-- Data for Name: users_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_tokens (id, user_id, token, context, sent_to, inserted_at) FROM stdin;
1	1	\\xdad2598978c389ac18920203ad195bcb556b229d00c79a9689bec3f4245051d9	session	\N	2026-02-25 10:05:04
2	1	\\xe4732438e9ed784cc88c7d556899740f2602f10fee2cc9c6fcfc445698986347	session	\N	2026-02-26 09:24:49
\.


--
-- Name: bundle_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bundle_items_id_seq', 4, true);


--
-- Name: bundles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bundles_id_seq', 1, true);


--
-- Name: collections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collections_id_seq', 4, true);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_id_seq', 1, false);


--
-- Name: info_pages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.info_pages_id_seq', 4, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 1, true);


--
-- Name: product_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_images_id_seq', 50, true);


--
-- Name: product_variants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_variants_id_seq', 72, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 18, true);


--
-- Name: promo_codes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.promo_codes_id_seq', 1, false);


--
-- Name: site_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.site_settings_id_seq', 1, false);


--
-- Name: testimonials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.testimonials_id_seq', 4, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: users_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_tokens_id_seq', 2, true);


--
-- Name: bundle_items bundle_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bundle_items
    ADD CONSTRAINT bundle_items_pkey PRIMARY KEY (id);


--
-- Name: bundles bundles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bundles
    ADD CONSTRAINT bundles_pkey PRIMARY KEY (id);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: info_pages info_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.info_pages
    ADD CONSTRAINT info_pages_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: product_images product_images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (id);


--
-- Name: product_variants product_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: promo_codes promo_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promo_codes
    ADD CONSTRAINT promo_codes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: site_settings site_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_settings
    ADD CONSTRAINT site_settings_pkey PRIMARY KEY (id);


--
-- Name: testimonials testimonials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.testimonials
    ADD CONSTRAINT testimonials_pkey PRIMARY KEY (id);


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
-- Name: bundle_items_bundle_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bundle_items_bundle_id_index ON public.bundle_items USING btree (bundle_id);


--
-- Name: bundle_items_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bundle_items_product_id_index ON public.bundle_items USING btree (product_id);


--
-- Name: customers_email_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX customers_email_index ON public.customers USING btree (email);


--
-- Name: customers_inserted_at_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX customers_inserted_at_index ON public.customers USING btree (inserted_at);


--
-- Name: info_pages_is_active_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX info_pages_is_active_index ON public.info_pages USING btree (is_active);


--
-- Name: info_pages_slug_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX info_pages_slug_index ON public.info_pages USING btree (slug);


--
-- Name: orders_reference_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX orders_reference_index ON public.orders USING btree (reference);


--
-- Name: orders_status_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX orders_status_index ON public.orders USING btree (status);


--
-- Name: product_images_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX product_images_product_id_index ON public.product_images USING btree (product_id);


--
-- Name: products_collection_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX products_collection_id_index ON public.products USING btree (collection_id);


--
-- Name: promo_codes_code_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX promo_codes_code_index ON public.promo_codes USING btree (code);


--
-- Name: promo_codes_is_active_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX promo_codes_is_active_index ON public.promo_codes USING btree (is_active);


--
-- Name: testimonials_product_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX testimonials_product_id_index ON public.testimonials USING btree (product_id);


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
-- Name: bundle_items bundle_items_bundle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bundle_items
    ADD CONSTRAINT bundle_items_bundle_id_fkey FOREIGN KEY (bundle_id) REFERENCES public.bundles(id);


--
-- Name: bundle_items bundle_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bundle_items
    ADD CONSTRAINT bundle_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: product_images product_images_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: product_variants product_variants_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: products products_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- Name: testimonials testimonials_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.testimonials
    ADD CONSTRAINT testimonials_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: users_tokens users_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict IyjvT1eLyKFtLZDxZc5ML3P1C18Tif7ubhlNNw3rlDCA6fZw6cUWqaw3VyQeW4I

