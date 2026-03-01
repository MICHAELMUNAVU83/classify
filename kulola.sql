--
-- PostgreSQL database dump
--

\restrict uT7BwFAWdoiNRJu0KhPOsGkhP9oQTihbJhkkdScOCZAiA5OwlR4blmnF3QYtWGU

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
1	1	6	2026-02-23 14:34:30	2026-02-23 14:34:30
3	1	17	2026-02-23 14:34:30	2026-02-23 14:34:30
4	1	11	2026-02-23 14:34:30	2026-02-23 14:34:30
5	1	4	2026-02-23 15:35:22	2026-02-23 15:35:22
\.


--
-- Data for Name: bundles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bundles (id, title, description, image, is_active, inserted_at, updated_at) FROM stdin;
1	The Kulola Starter Bundle	Our curated starter bundle — everything you need to build a versatile, head-turning wardrobe. Includes our bestselling Black Wide-Leg Palazzo Pants, the Burgundy Pleated Maxi Skirt, the Red Knit Cardigan and the Denim Maxi Skirt. Mix, match and own every room.	/images/products/black-wide-leg-pants-floral-top.jpg	t	2026-02-23 14:34:30	2026-02-23 14:34:30
\.


--
-- Data for Name: collections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collections (id, title, slug, image, "position", is_active, inserted_at, updated_at) FROM stdin;
1	Co-ord Sets	coord-sets	/images/products/red-denim-coord-set.jpg	1	t	2026-02-23 14:34:29	2026-02-23 14:34:29
2	Wide-Leg Pants	wide-leg-pants	/images/products/black-wide-leg-pants-floral-top.jpg	2	t	2026-02-23 14:34:29	2026-02-23 14:34:29
3	Skirts	skirts	/images/products/denim-maxi-skirt-front.jpg	3	t	2026-02-23 14:34:29	2026-02-23 14:34:29
4	Jumpsuits	jumpsuits	/images/products/sage-linen-jumpsuit.jpg	4	t	2026-02-23 14:34:29	2026-02-23 14:34:29
5	Tops & Knits	tops-and-knits	/images/products/grey-layered-knit-set-front.jpg	5	t	2026-02-23 14:34:29	2026-02-23 14:34:29
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, email, name, phone, address, order_count, total_spent, inserted_at, updated_at) FROM stdin;
1	michaelmunavu83@gmail.com	Michael Munavu	+254740769596	7576-kangundo	4	18100	2026-02-23 15:21:01	2026-02-23 19:32:03
\.


--
-- Data for Name: info_pages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.info_pages (id, slug, title, icon, content, meta_description, is_active, "position", inserted_at, updated_at) FROM stdin;
1	how-to-order	How to Order	🛍️	## How to Place Your Order\n\nOrdering from Kulola's Closet is simple and straightforward. Here's how:\n\n### Option 1 — Order via WhatsApp (Recommended)\n\n- Screenshot or share the product you love from our Instagram or website.\n- Send us a message on **WhatsApp: 0796 770 862**.\n- Let us know your **size**, preferred **colour**, and **delivery location**.\n- We'll confirm availability and send you the total including delivery.\n- Make payment via **M-Pesa Till No. 5894819**.\n- Send us the M-Pesa confirmation message.\n- Your order will be dispatched within 24 hours!\n\n### Option 2 — Order via the Website\n\n- Browse our collections and add items to your cart.\n- Proceed to **Checkout** and fill in your delivery details.\n- Complete payment via M-Pesa.\n- You'll receive an order confirmation via email or WhatsApp.\n\n## Payment Methods\n\n- **M-Pesa Till No. 5894819** (Kulola's Closet)\n- Bank transfer (available on request)\n\n## Need Help?\n\nIf you have any trouble placing an order, don't hesitate to reach out on WhatsApp and we'll assist you immediately.\n	Step-by-step guide on how to place an order at Kulola's Closet — shop online or via WhatsApp.	t	1	2026-02-23 14:34:30	2026-02-23 14:34:30
2	size-guide	Size Guide	📐	## Finding Your Perfect Fit\n\nAll our garments are made with Kenyan bodies in mind. We recommend taking your measurements before ordering.\n\n### How to Measure Yourself\n\n- **Bust** — Measure around the fullest part of your chest, keeping the tape parallel to the floor.\n- **Waist** — Measure around your natural waistline, the narrowest part of your torso.\n- **Hips** — Measure around the fullest part of your hips, about 20 cm below your waist.\n- **Length** — Measure from the top of your shoulder to wherever you'd like the garment to end.\n\n### Women's Size Chart\n\n### Tops & Dresses\n\n- **XS** — Bust 80–84 cm | Waist 60–64 cm | Hips 86–90 cm\n- **S** — Bust 84–88 cm | Waist 64–68 cm | Hips 90–94 cm\n- **M** — Bust 88–94 cm | Waist 68–74 cm | Hips 94–100 cm\n- **L** — Bust 94–100 cm | Waist 74–80 cm | Hips 100–106 cm\n- **XL** — Bust 100–106 cm | Waist 80–86 cm | Hips 106–112 cm\n- **XXL** — Bust 106–114 cm | Waist 86–94 cm | Hips 112–120 cm\n\n### Coord Sets & Bottoms\n\n- **S** — Waist 64–68 cm | Hips 90–96 cm\n- **M** — Waist 68–74 cm | Hips 96–102 cm\n- **L** — Waist 74–80 cm | Hips 102–108 cm\n- **XL** — Waist 80–86 cm | Hips 108–114 cm\n\n## Not Sure About Your Size?\n\nEvery product page includes specific measurements. You can also **WhatsApp us** with your measurements and we'll recommend the best fit for you.\n	Find your perfect fit with Kulola's Closet size guide — measurements for tops, bottoms, dresses, and coord sets.	t	2	2026-02-23 14:34:30	2026-02-23 14:34:30
3	shipping-delivery	Shipping & Delivery	🚚	## Shipping & Delivery\n\nWe deliver across Kenya! Here's everything you need to know about getting your Kulola order to your door.\n\n### Nairobi Deliveries\n\n- **Standard Delivery** — 1–2 business days | **KES 200–300**\n- **Same-Day Delivery** — Available for orders placed before 12 PM | **KES 300–500** (select locations)\n- **Pick-Up** — Contact us on WhatsApp to arrange a convenient pick-up point.\n\n### Countrywide Deliveries\n\n- **Courier (G4S / Wells Fargo)** — 2–4 business days | **KES 400–600**\n- **Bus / Matatu Services** — 1–2 business days | Cost varies by distance\n- Delivery fees for upcountry orders are confirmed at checkout or via WhatsApp.\n\n### How Delivery Works\n\n- Once your order is confirmed and payment received, we process and pack within **24 hours**.\n- You'll receive a **WhatsApp notification** when your parcel is dispatched, including tracking details where applicable.\n- For bus deliveries, the bus ticket/tracking number will be shared with you.\n\n### Important Notes\n\n- Delivery timelines exclude weekends and public holidays.\n- Kulola's Closet is not responsible for delays caused by third-party courier services once the parcel is dispatched.\n- Please ensure your **delivery address and phone number** are accurate when ordering.\n\n## Questions?\n\nReach us on **WhatsApp: 0796 770 862** for any delivery enquiries.\n	Kulola's Closet shipping and delivery information — Nairobi same-day delivery and countrywide shipping across Kenya.	t	3	2026-02-23 14:34:30	2026-02-23 14:34:30
4	returns-exchanges	Returns & Exchanges	🔄	## Returns & Exchanges\n\nWe want you to love every piece from Kulola's Closet. If something isn't right, here's what you can do.\n\n### Our Policy\n\n- We accept **exchange requests** within **48 hours** of receiving your order.\n- Items must be **unworn, unwashed, and in original condition** with tags intact.\n- **Sale items** are final sale and cannot be exchanged or returned.\n\n### Valid Reasons for Exchange\n\n- Wrong size sent (our error)\n- Wrong item sent (our error)\n- Item has a manufacturing defect\n\n### How to Request an Exchange\n\n- Contact us on **WhatsApp: 0796 770 862** within 48 hours of delivery.\n- Share your order details and clear photos of the item(s).\n- Our team will review and respond within 24 hours.\n- If approved, we'll arrange collection and dispatch the replacement.\n\n### Exchanges — Size or Style\n\n- If you'd like to exchange for a different size or style (your preference), this is subject to stock availability.\n- The customer is responsible for return delivery costs in this case.\n- Any price difference will be charged or refunded accordingly.\n\n### Refunds\n\n- We do not offer cash refunds except in cases where the item is out of stock and no suitable replacement is available.\n- Refunds, where applicable, are processed within **5–7 business days** via M-Pesa.\n\n## Contact Us\n\nIf you have any concerns about your order, please reach out promptly on **WhatsApp: 0796 770 862**. We're here to help!\n	Kulola's Closet returns and exchanges policy — we want you to love every piece.	t	4	2026-02-23 14:34:30	2026-02-23 14:34:30
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, reference, email, name, phone, address, total_amount, status, items, inserted_at, updated_at, promo_code, discount_amount) FROM stdin;
1	KUL-8D71A1A316F8	michaelmunavu83@gmail.com	Michael Munavu	+254740769596	7576-kangundo	4200	paid	{"{\\"id\\": 4, \\"key\\": \\"4__c2__M\\", \\"name\\": \\"Sage Linen Co-ord Set\\", \\"size\\": \\"M\\", \\"slug\\": \\"sage-linen-coord-set\\", \\"color\\": \\"Olive\\", \\"image\\": \\"/images/products/sage-linen-coord-set.jpg\\", \\"price\\": 4200, \\"color_id\\": \\"c2\\", \\"quantity\\": 1}"}	2026-02-23 15:20:45	2026-02-23 15:21:01	\N	0
2	KUL-02E143644678	michaelmunavu83@gmail.com	Michael Munavu	+254740769596	7576-kangundo	2800	paid	{"{\\"id\\": 6, \\"key\\": \\"6__c1__XS\\", \\"name\\": \\"Black Wide-Leg Palazzo Pants\\", \\"size\\": \\"XS\\", \\"slug\\": \\"black-wide-leg-palazzo-pants\\", \\"color\\": \\"Black\\", \\"image\\": \\"/images/products/black-wide-leg-pants-floral-top.jpg\\", \\"price\\": 2800, \\"color_id\\": \\"c1\\", \\"quantity\\": 1}"}	2026-02-23 15:31:40	2026-02-23 15:31:54	\N	0
3	KUL-C482058248F8	michaelmunavu83@gmail.com	Michael Munavu	+254740769596	7576-kangundo	3500	paid	{"{\\"id\\": 18, \\"key\\": \\"18__c2__L\\", \\"name\\": \\"Navy Pinstripe Blazer\\", \\"size\\": \\"L\\", \\"slug\\": \\"navy-pinstripe-blazer\\", \\"color\\": \\"Black\\", \\"image\\": \\"/images/products/navy-pinstripe-blazer-set.jpg\\", \\"price\\": 3500, \\"color_id\\": \\"c2\\", \\"quantity\\": 1}"}	2026-02-23 19:19:25	2026-02-23 19:19:39	\N	0
4	KUL-00C82792145D	michaelmunavu83@gmail.com	Michael Munavu	+254740769596	7576-kangundo	7600	paid	{"{\\"id\\": 12, \\"key\\": \\"12__c2__M\\", \\"name\\": \\"Burgundy Pleated Maxi Skirt\\", \\"size\\": \\"M\\", \\"slug\\": \\"burgundy-pleated-maxi-skirt\\", \\"color\\": \\"Black\\", \\"image\\": \\"/images/products/burgundy-pleated-maxi-skirt.jpg\\", \\"price\\": 3800, \\"color_id\\": \\"c2\\", \\"quantity\\": 2}"}	2026-02-23 19:31:45	2026-02-23 19:32:03	\N	0
\.


--
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_images (id, image, "position", product_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: product_variants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variants (id, color_name, color_hex, size, stock_quantity, product_id, inserted_at, updated_at) FROM stdin;
1	Red	#CC2936	XS	10	1	2026-02-23 14:34:29	2026-02-23 14:34:29
2	Red	#CC2936	S	10	1	2026-02-23 14:34:29	2026-02-23 14:34:29
3	Red	#CC2936	M	10	1	2026-02-23 14:34:29	2026-02-23 14:34:29
4	Red	#CC2936	L	10	1	2026-02-23 14:34:29	2026-02-23 14:34:29
5	Red	#CC2936	XL	10	1	2026-02-23 14:34:29	2026-02-23 14:34:29
6	Denim Blue	#4A7FB5	XS	10	1	2026-02-23 14:34:29	2026-02-23 14:34:29
7	Denim Blue	#4A7FB5	S	10	1	2026-02-23 14:34:29	2026-02-23 14:34:29
8	Denim Blue	#4A7FB5	M	10	1	2026-02-23 14:34:29	2026-02-23 14:34:29
9	Denim Blue	#4A7FB5	L	10	1	2026-02-23 14:34:29	2026-02-23 14:34:29
10	Denim Blue	#4A7FB5	XL	10	1	2026-02-23 14:34:29	2026-02-23 14:34:29
11	Orange	#F97316	XS	10	2	2026-02-23 14:34:29	2026-02-23 14:34:29
12	Orange	#F97316	S	10	2	2026-02-23 14:34:29	2026-02-23 14:34:29
13	Orange	#F97316	M	10	2	2026-02-23 14:34:29	2026-02-23 14:34:29
14	Orange	#F97316	L	10	2	2026-02-23 14:34:29	2026-02-23 14:34:29
15	Orange	#F97316	XL	10	2	2026-02-23 14:34:29	2026-02-23 14:34:29
16	Denim Blue	#4A7FB5	XS	10	2	2026-02-23 14:34:29	2026-02-23 14:34:29
17	Denim Blue	#4A7FB5	S	10	2	2026-02-23 14:34:29	2026-02-23 14:34:29
18	Denim Blue	#4A7FB5	M	10	2	2026-02-23 14:34:29	2026-02-23 14:34:29
19	Denim Blue	#4A7FB5	L	10	2	2026-02-23 14:34:29	2026-02-23 14:34:29
20	Denim Blue	#4A7FB5	XL	10	2	2026-02-23 14:34:29	2026-02-23 14:34:29
21	Chocolate	#7B3F00	XS	10	3	2026-02-23 14:34:29	2026-02-23 14:34:29
22	Chocolate	#7B3F00	S	10	3	2026-02-23 14:34:29	2026-02-23 14:34:29
23	Chocolate	#7B3F00	M	10	3	2026-02-23 14:34:29	2026-02-23 14:34:29
24	Chocolate	#7B3F00	L	10	3	2026-02-23 14:34:29	2026-02-23 14:34:29
25	Chocolate	#7B3F00	XL	10	3	2026-02-23 14:34:29	2026-02-23 14:34:29
26	Cream	#F5F0E8	XS	10	3	2026-02-23 14:34:29	2026-02-23 14:34:29
27	Cream	#F5F0E8	S	10	3	2026-02-23 14:34:29	2026-02-23 14:34:29
28	Cream	#F5F0E8	M	10	3	2026-02-23 14:34:29	2026-02-23 14:34:29
29	Cream	#F5F0E8	L	10	3	2026-02-23 14:34:29	2026-02-23 14:34:29
30	Cream	#F5F0E8	XL	10	3	2026-02-23 14:34:29	2026-02-23 14:34:29
31	Sage Green	#8FAF7E	XS	10	4	2026-02-23 14:34:29	2026-02-23 14:34:29
32	Sage Green	#8FAF7E	S	10	4	2026-02-23 14:34:29	2026-02-23 14:34:29
33	Sage Green	#8FAF7E	M	10	4	2026-02-23 14:34:29	2026-02-23 14:34:29
34	Sage Green	#8FAF7E	L	10	4	2026-02-23 14:34:29	2026-02-23 14:34:29
35	Sage Green	#8FAF7E	XL	10	4	2026-02-23 14:34:29	2026-02-23 14:34:29
36	Olive	#6B7C4A	XS	10	4	2026-02-23 14:34:29	2026-02-23 14:34:29
37	Olive	#6B7C4A	S	10	4	2026-02-23 14:34:29	2026-02-23 14:34:29
39	Olive	#6B7C4A	L	10	4	2026-02-23 14:34:29	2026-02-23 14:34:29
40	Olive	#6B7C4A	XL	10	4	2026-02-23 14:34:29	2026-02-23 14:34:29
41	Olive	#6B7C4A	XS	10	5	2026-02-23 14:34:29	2026-02-23 14:34:29
42	Olive	#6B7C4A	S	10	5	2026-02-23 14:34:29	2026-02-23 14:34:29
43	Olive	#6B7C4A	M	10	5	2026-02-23 14:34:29	2026-02-23 14:34:29
44	Olive	#6B7C4A	L	10	5	2026-02-23 14:34:29	2026-02-23 14:34:29
45	Olive	#6B7C4A	XL	10	5	2026-02-23 14:34:29	2026-02-23 14:34:29
46	Cream	#F5F0E8	XS	10	5	2026-02-23 14:34:29	2026-02-23 14:34:29
47	Cream	#F5F0E8	S	10	5	2026-02-23 14:34:29	2026-02-23 14:34:29
48	Cream	#F5F0E8	M	10	5	2026-02-23 14:34:29	2026-02-23 14:34:29
49	Cream	#F5F0E8	L	10	5	2026-02-23 14:34:29	2026-02-23 14:34:29
50	Cream	#F5F0E8	XL	10	5	2026-02-23 14:34:29	2026-02-23 14:34:29
52	Black	#1A1A1A	S	10	6	2026-02-23 14:34:29	2026-02-23 14:34:29
53	Black	#1A1A1A	M	10	6	2026-02-23 14:34:29	2026-02-23 14:34:29
54	Black	#1A1A1A	L	10	6	2026-02-23 14:34:29	2026-02-23 14:34:29
55	Black	#1A1A1A	XL	10	6	2026-02-23 14:34:29	2026-02-23 14:34:29
56	White	#F5F5F5	XS	10	6	2026-02-23 14:34:29	2026-02-23 14:34:29
57	White	#F5F5F5	S	10	6	2026-02-23 14:34:29	2026-02-23 14:34:29
58	White	#F5F5F5	M	10	6	2026-02-23 14:34:29	2026-02-23 14:34:29
59	White	#F5F5F5	L	10	6	2026-02-23 14:34:29	2026-02-23 14:34:29
60	White	#F5F5F5	XL	10	6	2026-02-23 14:34:29	2026-02-23 14:34:29
61	Navy	#1B2A6B	XS	10	7	2026-02-23 14:34:29	2026-02-23 14:34:29
62	Navy	#1B2A6B	S	10	7	2026-02-23 14:34:29	2026-02-23 14:34:29
63	Navy	#1B2A6B	M	10	7	2026-02-23 14:34:29	2026-02-23 14:34:29
64	Navy	#1B2A6B	L	10	7	2026-02-23 14:34:29	2026-02-23 14:34:29
65	Navy	#1B2A6B	XL	10	7	2026-02-23 14:34:29	2026-02-23 14:34:29
66	Black	#1A1A1A	XS	10	7	2026-02-23 14:34:29	2026-02-23 14:34:29
67	Black	#1A1A1A	S	10	7	2026-02-23 14:34:29	2026-02-23 14:34:29
68	Black	#1A1A1A	M	10	7	2026-02-23 14:34:29	2026-02-23 14:34:29
69	Black	#1A1A1A	L	10	7	2026-02-23 14:34:29	2026-02-23 14:34:29
70	Black	#1A1A1A	XL	10	7	2026-02-23 14:34:29	2026-02-23 14:34:29
71	Olive	#6B7C4A	XS	10	8	2026-02-23 14:34:29	2026-02-23 14:34:29
72	Olive	#6B7C4A	S	10	8	2026-02-23 14:34:29	2026-02-23 14:34:29
73	Olive	#6B7C4A	M	10	8	2026-02-23 14:34:29	2026-02-23 14:34:29
74	Olive	#6B7C4A	L	10	8	2026-02-23 14:34:29	2026-02-23 14:34:29
75	Olive	#6B7C4A	XL	10	8	2026-02-23 14:34:29	2026-02-23 14:34:29
76	Camel	#C9A882	XS	10	8	2026-02-23 14:34:29	2026-02-23 14:34:29
77	Camel	#C9A882	S	10	8	2026-02-23 14:34:29	2026-02-23 14:34:29
78	Camel	#C9A882	M	10	8	2026-02-23 14:34:29	2026-02-23 14:34:29
79	Camel	#C9A882	L	10	8	2026-02-23 14:34:29	2026-02-23 14:34:29
80	Camel	#C9A882	XL	10	8	2026-02-23 14:34:29	2026-02-23 14:34:29
81	Light Wash	#B8D4E8	XS	10	9	2026-02-23 14:34:29	2026-02-23 14:34:29
82	Light Wash	#B8D4E8	S	10	9	2026-02-23 14:34:29	2026-02-23 14:34:29
83	Light Wash	#B8D4E8	M	10	9	2026-02-23 14:34:29	2026-02-23 14:34:29
84	Light Wash	#B8D4E8	L	10	9	2026-02-23 14:34:29	2026-02-23 14:34:29
85	Light Wash	#B8D4E8	XL	10	9	2026-02-23 14:34:29	2026-02-23 14:34:29
86	Dark Wash	#2C4F7C	XS	10	9	2026-02-23 14:34:29	2026-02-23 14:34:29
87	Dark Wash	#2C4F7C	S	10	9	2026-02-23 14:34:29	2026-02-23 14:34:29
88	Dark Wash	#2C4F7C	M	10	9	2026-02-23 14:34:29	2026-02-23 14:34:29
89	Dark Wash	#2C4F7C	L	10	9	2026-02-23 14:34:29	2026-02-23 14:34:29
90	Dark Wash	#2C4F7C	XL	10	9	2026-02-23 14:34:29	2026-02-23 14:34:29
91	Navy	#1B2A6B	XS	10	10	2026-02-23 14:34:29	2026-02-23 14:34:29
92	Navy	#1B2A6B	S	10	10	2026-02-23 14:34:29	2026-02-23 14:34:29
93	Navy	#1B2A6B	M	10	10	2026-02-23 14:34:29	2026-02-23 14:34:29
94	Navy	#1B2A6B	L	10	10	2026-02-23 14:34:29	2026-02-23 14:34:29
95	Navy	#1B2A6B	XL	10	10	2026-02-23 14:34:29	2026-02-23 14:34:29
96	Mid-Wash Denim	#7BA4C7	XS	10	11	2026-02-23 14:34:29	2026-02-23 14:34:29
51	Black	#1A1A1A	XS	9	6	2026-02-23 14:34:29	2026-02-23 15:31:54
97	Mid-Wash Denim	#7BA4C7	S	10	11	2026-02-23 14:34:29	2026-02-23 14:34:29
106	Burgundy	#800020	XS	10	12	2026-02-23 14:34:29	2026-02-23 14:34:29
125	Blush	#F5C4C4	XL	10	13	2026-02-23 14:34:29	2026-02-23 14:34:29
134	Black	#1A1A1A	L	10	14	2026-02-23 14:34:29	2026-02-23 14:34:29
143	Charcoal	#374151	M	10	15	2026-02-23 14:34:29	2026-02-23 14:34:29
152	Black	#1A1A1A	S	10	16	2026-02-23 14:34:29	2026-02-23 14:34:29
161	Black	#1A1A1A	XS	10	17	2026-02-23 14:34:30	2026-02-23 14:34:30
170	Navy	#1B2A6B	XL	10	18	2026-02-23 14:34:30	2026-02-23 14:34:30
179	White	#F5F5F5	L	10	19	2026-02-23 14:34:30	2026-02-23 14:34:30
188	Black/White	#1A1A1A	M	10	20	2026-02-23 14:34:30	2026-02-23 14:34:30
98	Mid-Wash Denim	#7BA4C7	M	10	11	2026-02-23 14:34:29	2026-02-23 14:34:29
107	Burgundy	#800020	S	10	12	2026-02-23 14:34:29	2026-02-23 14:34:29
116	Sage Green	#8FAF7E	XS	10	13	2026-02-23 14:34:29	2026-02-23 14:34:29
135	Black	#1A1A1A	XL	10	14	2026-02-23 14:34:29	2026-02-23 14:34:29
144	Charcoal	#374151	L	10	15	2026-02-23 14:34:29	2026-02-23 14:34:29
153	Black	#1A1A1A	M	10	16	2026-02-23 14:34:29	2026-02-23 14:34:29
162	Black	#1A1A1A	S	10	17	2026-02-23 14:34:30	2026-02-23 14:34:30
171	Black	#1A1A1A	XS	10	18	2026-02-23 14:34:30	2026-02-23 14:34:30
180	White	#F5F5F5	XL	10	19	2026-02-23 14:34:30	2026-02-23 14:34:30
189	Black/White	#1A1A1A	L	10	20	2026-02-23 14:34:30	2026-02-23 14:34:30
99	Mid-Wash Denim	#7BA4C7	L	10	11	2026-02-23 14:34:29	2026-02-23 14:34:29
108	Burgundy	#800020	M	10	12	2026-02-23 14:34:29	2026-02-23 14:34:29
117	Sage Green	#8FAF7E	S	10	13	2026-02-23 14:34:29	2026-02-23 14:34:29
126	Grey	#9CA3AF	XS	10	14	2026-02-23 14:34:29	2026-02-23 14:34:29
145	Charcoal	#374151	XL	10	15	2026-02-23 14:34:29	2026-02-23 14:34:29
154	Black	#1A1A1A	L	10	16	2026-02-23 14:34:29	2026-02-23 14:34:29
163	Black	#1A1A1A	M	10	17	2026-02-23 14:34:30	2026-02-23 14:34:30
172	Black	#1A1A1A	S	10	18	2026-02-23 14:34:30	2026-02-23 14:34:30
181	Blush	#F5C4C4	XS	10	19	2026-02-23 14:34:30	2026-02-23 14:34:30
190	Black/White	#1A1A1A	XL	10	20	2026-02-23 14:34:30	2026-02-23 14:34:30
100	Mid-Wash Denim	#7BA4C7	XL	10	11	2026-02-23 14:34:29	2026-02-23 14:34:29
109	Burgundy	#800020	L	10	12	2026-02-23 14:34:29	2026-02-23 14:34:29
118	Sage Green	#8FAF7E	M	10	13	2026-02-23 14:34:29	2026-02-23 14:34:29
127	Grey	#9CA3AF	S	10	14	2026-02-23 14:34:29	2026-02-23 14:34:29
136	Black	#1A1A1A	XS	10	15	2026-02-23 14:34:29	2026-02-23 14:34:29
155	Black	#1A1A1A	XL	10	16	2026-02-23 14:34:29	2026-02-23 14:34:29
164	Black	#1A1A1A	L	10	17	2026-02-23 14:34:30	2026-02-23 14:34:30
173	Black	#1A1A1A	M	10	18	2026-02-23 14:34:30	2026-02-23 14:34:30
182	Blush	#F5C4C4	S	10	19	2026-02-23 14:34:30	2026-02-23 14:34:30
191	Beige	#D4B896	XS	10	20	2026-02-23 14:34:30	2026-02-23 14:34:30
101	Dark Denim	#2C4F7C	XS	10	11	2026-02-23 14:34:29	2026-02-23 14:34:29
110	Burgundy	#800020	XL	10	12	2026-02-23 14:34:29	2026-02-23 14:34:29
119	Sage Green	#8FAF7E	L	10	13	2026-02-23 14:34:29	2026-02-23 14:34:29
128	Grey	#9CA3AF	M	10	14	2026-02-23 14:34:29	2026-02-23 14:34:29
137	Black	#1A1A1A	S	10	15	2026-02-23 14:34:29	2026-02-23 14:34:29
146	Navy	#1B2A6B	XS	10	16	2026-02-23 14:34:29	2026-02-23 14:34:29
165	Black	#1A1A1A	XL	10	17	2026-02-23 14:34:30	2026-02-23 14:34:30
183	Blush	#F5C4C4	M	10	19	2026-02-23 14:34:30	2026-02-23 14:34:30
192	Beige	#D4B896	S	10	20	2026-02-23 14:34:30	2026-02-23 14:34:30
174	Black	#1A1A1A	L	9	18	2026-02-23 14:34:30	2026-02-23 19:19:39
102	Dark Denim	#2C4F7C	S	10	11	2026-02-23 14:34:29	2026-02-23 14:34:29
111	Black	#1A1A1A	XS	10	12	2026-02-23 14:34:29	2026-02-23 14:34:29
120	Sage Green	#8FAF7E	XL	10	13	2026-02-23 14:34:29	2026-02-23 14:34:29
129	Grey	#9CA3AF	L	10	14	2026-02-23 14:34:29	2026-02-23 14:34:29
138	Black	#1A1A1A	M	10	15	2026-02-23 14:34:29	2026-02-23 14:34:29
147	Navy	#1B2A6B	S	10	16	2026-02-23 14:34:29	2026-02-23 14:34:29
156	Red	#CC2936	XS	10	17	2026-02-23 14:34:30	2026-02-23 14:34:30
175	Black	#1A1A1A	XL	10	18	2026-02-23 14:34:30	2026-02-23 14:34:30
184	Blush	#F5C4C4	L	10	19	2026-02-23 14:34:30	2026-02-23 14:34:30
193	Beige	#D4B896	M	10	20	2026-02-23 14:34:30	2026-02-23 14:34:30
103	Dark Denim	#2C4F7C	M	10	11	2026-02-23 14:34:29	2026-02-23 14:34:29
112	Black	#1A1A1A	S	10	12	2026-02-23 14:34:29	2026-02-23 14:34:29
121	Blush	#F5C4C4	XS	10	13	2026-02-23 14:34:29	2026-02-23 14:34:29
130	Grey	#9CA3AF	XL	10	14	2026-02-23 14:34:29	2026-02-23 14:34:29
139	Black	#1A1A1A	L	10	15	2026-02-23 14:34:29	2026-02-23 14:34:29
148	Navy	#1B2A6B	M	10	16	2026-02-23 14:34:29	2026-02-23 14:34:29
157	Red	#CC2936	S	10	17	2026-02-23 14:34:30	2026-02-23 14:34:30
166	Navy	#1B2A6B	XS	10	18	2026-02-23 14:34:30	2026-02-23 14:34:30
185	Blush	#F5C4C4	XL	10	19	2026-02-23 14:34:30	2026-02-23 14:34:30
194	Beige	#D4B896	L	10	20	2026-02-23 14:34:30	2026-02-23 14:34:30
104	Dark Denim	#2C4F7C	L	10	11	2026-02-23 14:34:29	2026-02-23 14:34:29
122	Blush	#F5C4C4	S	10	13	2026-02-23 14:34:29	2026-02-23 14:34:29
131	Black	#1A1A1A	XS	10	14	2026-02-23 14:34:29	2026-02-23 14:34:29
140	Black	#1A1A1A	XL	10	15	2026-02-23 14:34:29	2026-02-23 14:34:29
149	Navy	#1B2A6B	L	10	16	2026-02-23 14:34:29	2026-02-23 14:34:29
158	Red	#CC2936	M	10	17	2026-02-23 14:34:30	2026-02-23 14:34:30
167	Navy	#1B2A6B	S	10	18	2026-02-23 14:34:30	2026-02-23 14:34:30
176	White	#F5F5F5	XS	10	19	2026-02-23 14:34:30	2026-02-23 14:34:30
195	Beige	#D4B896	XL	10	20	2026-02-23 14:34:30	2026-02-23 14:34:30
113	Black	#1A1A1A	M	8	12	2026-02-23 14:34:29	2026-02-23 19:32:03
105	Dark Denim	#2C4F7C	XL	10	11	2026-02-23 14:34:29	2026-02-23 14:34:29
114	Black	#1A1A1A	L	10	12	2026-02-23 14:34:29	2026-02-23 14:34:29
123	Blush	#F5C4C4	M	10	13	2026-02-23 14:34:29	2026-02-23 14:34:29
132	Black	#1A1A1A	S	10	14	2026-02-23 14:34:29	2026-02-23 14:34:29
141	Charcoal	#374151	XS	10	15	2026-02-23 14:34:29	2026-02-23 14:34:29
150	Navy	#1B2A6B	XL	10	16	2026-02-23 14:34:29	2026-02-23 14:34:29
159	Red	#CC2936	L	10	17	2026-02-23 14:34:30	2026-02-23 14:34:30
168	Navy	#1B2A6B	M	10	18	2026-02-23 14:34:30	2026-02-23 14:34:30
177	White	#F5F5F5	S	10	19	2026-02-23 14:34:30	2026-02-23 14:34:30
186	Black/White	#1A1A1A	XS	10	20	2026-02-23 14:34:30	2026-02-23 14:34:30
115	Black	#1A1A1A	XL	10	12	2026-02-23 14:34:29	2026-02-23 14:34:29
124	Blush	#F5C4C4	L	10	13	2026-02-23 14:34:29	2026-02-23 14:34:29
133	Black	#1A1A1A	M	10	14	2026-02-23 14:34:29	2026-02-23 14:34:29
142	Charcoal	#374151	S	10	15	2026-02-23 14:34:29	2026-02-23 14:34:29
151	Black	#1A1A1A	XS	10	16	2026-02-23 14:34:29	2026-02-23 14:34:29
160	Red	#CC2936	XL	10	17	2026-02-23 14:34:30	2026-02-23 14:34:30
169	Navy	#1B2A6B	L	10	18	2026-02-23 14:34:30	2026-02-23 14:34:30
178	White	#F5F5F5	M	10	19	2026-02-23 14:34:30	2026-02-23 14:34:30
187	Black/White	#1A1A1A	S	10	20	2026-02-23 14:34:30	2026-02-23 14:34:30
38	Olive	#6B7C4A	M	9	4	2026-02-23 14:34:29	2026-02-23 15:21:01
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, slug, description, base_price, image, badge_label, badge_color, is_featured, is_bestseller, is_new_arrival, "position", status, collection_id, inserted_at, updated_at, size_advice, shipping_returns) FROM stdin;
1	Red & Denim Co-ord Set	red-denim-coord-set	A bold statement co-ord set featuring a cropped red sweatshirt layered over a denim shirt, paired with matching red wide-leg trousers finished with raw-hem denim side-stripe detailing. Effortlessly cool with white sneakers.	4800	/images/products/red-denim-coord-set.jpg	Bestseller	red	t	t	f	1	active	1	2026-02-23 14:34:29	2026-02-23 14:34:29	Runs true to size. The trousers have a drawstring waist for a flexible fit. If between sizes, size up for comfort. Model is 5'6" wearing a size M. Measure your bust and hips before ordering.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
2	Orange & Denim Co-ord Set	orange-denim-coord-set	Vibrant burnt-orange co-ord set with a cropped pullover and wide-leg trousers, both accented with frayed denim contrast panels and cuffs. A denim shirt peeking underneath adds a layered finish.	4800	/images/products/orange-denim-coord-set.jpg	New	green	t	f	t	2	active	1	2026-02-23 14:34:29	2026-02-23 14:34:29	Runs true to size. Bold, relaxed silhouette — if you prefer a more fitted look, size down. Drawstring trousers adjust easily. Measure your waist and hips for the best fit.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
3	Chocolate Knit Co-ord Set	chocolate-knit-coord-set	Luxuriously soft chocolate-brown knit co-ord set comprising an oversized drop-shoulder sweater with a cream contrast stripe hem and matching wide-leg knit trousers. The ultimate cosy-chic look.	5200	/images/products/chocolate-knit-coord-set.jpg	New	green	f	f	t	3	active	1	2026-02-23 14:34:29	2026-02-23 14:34:29	This oversized knit set runs generously. For a cosy relaxed fit, take your usual size. For a more structured look, size down one. The sweater has a deep drop-shoulder so measure your bust width.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
4	Sage Linen Co-ord Set	sage-linen-coord-set	Breezy sage-green linen co-ord set with a frilled-shoulder crop top and matching drawstring wide-leg trousers. Lightweight and effortlessly elegant for warm days.	4200	/images/products/sage-linen-coord-set.jpg	Featured	blue	t	f	f	4	active	1	2026-02-23 14:34:29	2026-02-23 14:34:29	Runs true to size. Linen has a natural relaxed drape. The frilled shoulder top suits a range of bust sizes and the drawstring trousers give flexibility. Model is 5'6" in a size M.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
5	Olive Linen Co-ord Set	olive-linen-coord-set	Relaxed olive-green linen co-ord featuring a V-neck button-front tunic top with pearl buttons and matching wide-leg trousers. Pairs beautifully with heeled sandals for a polished casual look.	4500	/images/products/olive-linen-coord-set.jpg	\N	\N	f	f	f	5	active	1	2026-02-23 14:34:29	2026-02-23 14:34:29	Runs true to size. The V-neck button-front top has a relaxed fit — measure your bust for the best button closure. Trousers have an elasticated drawstring waist for a comfortable, adjustable fit.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
6	Black Wide-Leg Palazzo Pants	black-wide-leg-palazzo-pants	Sleek high-waisted black palazzo pants with a structured belt and deep pleats for a dramatic silhouette. The statement piece in any wardrobe — style with a crop top or tucked-in blouse.	2800	/images/products/black-wide-leg-pants-floral-top.jpg	Bestseller	red	t	t	f	6	active	2	2026-02-23 14:34:29	2026-02-23 14:34:29	High-waisted fit — measure your natural waist. These run true to size with no stretch. The belt is included and fully adjustable. Model wears a size M. If between sizes, size up for the waist.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
7	Navy Wide-Leg Palazzo Pants	navy-wide-leg-palazzo-pants	Fluid navy high-waisted palazzo pants with a matching belt and front pleats. Versatile enough for day or evening wear — shown here with a tie-dye bandeau and a pop-colour mini bag.	2800	/images/products/navy-wide-leg-pants-bandeau.jpg	\N	\N	f	f	f	7	active	2	2026-02-23 14:34:29	2026-02-23 14:34:29	High-waisted structured fit — runs true to size. These do not have stretch, so measure your natural waist carefully. The front pleats add ease around the hips. Belt included and adjustable.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
8	Olive High-Waist Wide-Leg Trousers	olive-wide-leg-trousers	Tailored olive-green wide-leg trousers with a high waist and front button detail. A clean silhouette that pairs perfectly with a white crop shirt for an elevated smart-casual look.	2600	/images/products/olive-wide-leg-pants-white-crop.jpg	\N	\N	f	f	f	8	active	2	2026-02-23 14:34:29	2026-02-23 14:34:29	Tailored structured waist — no stretch, so measure your waist exactly. Runs true to size. The front button detail sits flat when the correct size is chosen. Size up if you're between sizes.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
9	Light-Wash Wide-Leg Jeans	light-wash-wide-leg-jeans	Relaxed-fit light-wash wide-leg jeans with a high rise and a clean, minimal finish. A wardrobe staple that grounds structured tops like a navy vest perfectly.	3200	/images/products/navy-vest-wide-leg-jeans.jpg	New	green	f	f	t	9	active	2	2026-02-23 14:34:29	2026-02-23 14:34:29	High-rise denim runs slightly small in the waist — size up if you're between sizes. Denim has minimal stretch. Measure your waist and hips. The wide leg gives a relaxed, flattering silhouette on most body types.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
10	Navy Pinstripe Wide-Leg Trousers	navy-pinstripe-wide-leg-trousers	Smart navy pinstripe wide-leg trousers from the matching blazer set. Power-dressing with an effortless twist — wear as a set or mix and match.	3000	/images/products/navy-pinstripe-blazer-set.jpg	Featured	blue	t	f	f	10	active	2	2026-02-23 14:34:29	2026-02-23 14:34:29	Part of a co-ord set — size up slightly for a tailored blazer-and-trouser look with room to layer. Waistband is structured with no stretch. We recommend ordering both pieces in the same size.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
11	Denim Maxi Skirt	denim-maxi-skirt	Voluminous mid-wash denim maxi skirt with a drawstring elasticated waist and sweeping panelled silhouette. Styled with a knotted graphic tee and a red crossbody for a relaxed street-style vibe.	3500	/images/products/denim-maxi-skirt-front.jpg	Bestseller	red	t	t	f	11	active	3	2026-02-23 14:34:29	2026-02-23 14:34:29	Elasticated drawstring waist means this fits a range of sizes. Runs true to size. Maxi length sits at the ankle — ideal for heights 5'3" and above. Pair with heels or flats.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
12	Burgundy Pleated Maxi Skirt	burgundy-pleated-maxi-skirt	Dramatic floor-length burgundy pleated maxi skirt with a front split for ease of movement. Styled with a white logo shirt tucked behind a wide leather belt and paired with black knee boots and a structured satchel.	3800	/images/products/burgundy-pleated-maxi-skirt.jpg	Featured	blue	t	f	f	12	active	3	2026-02-23 14:34:29	2026-02-23 14:34:29	Runs true to size with a structured waistband — measure your waist carefully. Full-length with a front split for ease of movement. Best for heights 5'4" and above. Size up if unsure.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
13	Sage Linen Jumpsuit	sage-linen-jumpsuit	Effortless sage-green linen jumpsuit with frilled shoulders, an elasticated drawstring waist and wide-leg trousers. A one-piece wonder that looks polished with minimal accessories.	4000	/images/products/sage-linen-jumpsuit.jpg	Featured	blue	t	f	f	13	active	4	2026-02-23 14:34:29	2026-02-23 14:34:29	Runs true to size. Drawstring waist is fully adjustable. For petite heights (under 5'3"), the leg length may be slightly long — easy to hem. Model is 5'6" wearing size M. Measure bust and waist.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
14	Grey Layered Knit Top	grey-layered-knit-top	Unique layered knit-over-shirt top in grey — a knitted sweater with button front detail sits over a woven shirt hem, creating a relaxed two-in-one look. Pairs effortlessly with shorts or jeans.	2500	/images/products/grey-layered-knit-set-front.jpg	\N	\N	f	f	f	14	active	5	2026-02-23 14:34:29	2026-02-23 14:34:29	Runs true to size. The layered knit-over-shirt effect is built into the design — no separate styling needed. Measure your bust for the best fit. Relaxed drop-shoulder cut.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
15	Black Layered Knit Top	black-layered-knit-top	Edgy black version of the layered knit-over-shirt top with contrast button detailing. Styled with a quilted black crossbody bag for a sleek, put-together look.	2500	/images/products/black-grey-layered-knit-set.jpg	\N	\N	f	f	f	15	active	5	2026-02-23 14:34:29	2026-02-23 14:34:29	Runs true to size. Same relaxed drop-shoulder construction as the grey version. Measure your bust for the best fit. The contrast button detailing is fixed — no adjustments needed.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
16	Navy Structured Vest Top	navy-structured-vest-top	Sharp navy structured vest top with mixed pearl and black button closures and a split hem. Tailored and modern — great over wide-leg jeans or as part of a smart-casual ensemble.	2200	/images/products/navy-vest-wide-leg-jeans.jpg	New	green	f	f	t	16	active	5	2026-02-23 14:34:29	2026-02-23 14:34:29	Structured cut runs slightly small — size up if between sizes. Best worn tucked into high-waisted bottoms. Measure your bust for the button fit. The split hem adds length in the back.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
17	Red Knit Cardigan	red-knit-cardigan	Classic cropped red knit cardigan with jewelled buttons and a layered white collared shirt underneath. A timeless preppy-chic piece that transitions from casual to smart effortlessly.	2800	/images/products/red-cardigan-black-wide-leg.jpg	Bestseller	red	t	t	f	17	active	5	2026-02-23 14:34:29	2026-02-23 14:34:29	Cropped fit runs true to size. Pearl jewelled buttons — measure your bust for the best closure. Pairs best with high-waisted trousers or skirts. Knit fabric has a gentle natural stretch.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
18	Navy Pinstripe Blazer	navy-pinstripe-blazer	Cropped navy pinstripe co-ord blazer with short sleeves and a relaxed open-front silhouette. Wear as a set with the matching wide-leg trousers or layer over a crop top.	3500	/images/products/navy-pinstripe-blazer-set.jpg	Featured	blue	t	f	f	18	active	5	2026-02-23 14:34:30	2026-02-23 14:34:30	Relaxed open-front blazer runs slightly oversized. Size down if you prefer a more fitted look. Great as part of the pinstripe co-ord set or layered solo. Measure your shoulders for the best fit.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
19	White Puff-Sleeve Crop Shirt	white-puff-sleeve-crop-shirt	Crisp white cropped shirt with voluminous puff sleeves and a gathered elastic hem. Pairs perfectly with high-waisted trousers for a polished yet playful look.	2000	/images/products/olive-wide-leg-pants-white-crop.jpg	\N	\N	f	f	f	19	active	5	2026-02-23 14:34:30	2026-02-23 14:34:30	Runs true to size. Puff sleeves are structured and fixed. Measure your bust — the elastic hem gives flexibility around the waist. Cropped length sits above the high waist for a flattering look.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
20	Floral Bandeau Crop Top	floral-bandeau-crop-top	Delicate black and white floral print bandeau crop top with a single shoulder strap. A versatile summer staple that looks stunning with wide-leg palazzo pants.	1500	/images/products/black-wide-leg-pants-floral-top.jpg	\N	\N	f	f	f	20	active	5	2026-02-23 14:34:30	2026-02-23 14:34:30	Runs true to size with a light stretch. Measure your bust for the best fit. The single adjustable shoulder strap gives flexibility. A versatile summer staple — pairs with anything high-waisted.	Nairobi delivery KES 200–300 (1–2 days). Countrywide KES 400–600 (2–4 days). Same-day available before 12 PM. Exchanges within 48 hours — unworn, tags on. WhatsApp 0796 770 862.
\.


--
-- Data for Name: promo_codes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promo_codes (id, code, description, influencer_name, discount_percent, is_active, usage_count, max_uses, expires_at, inserted_at, updated_at) FROM stdin;
1	6164003345002	Home Page	Grace	10	t	0	\N	\N	2026-02-23 19:21:18	2026-02-23 19:21:18
2	GLMPODCAST	GLM Podcast Discount	Mary	10	t	0	\N	\N	2026-02-23 19:33:54	2026-02-23 19:33:54
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (version, inserted_at) FROM stdin;
20260218042636	2026-02-23 14:34:29
20260221045341	2026-02-23 14:34:29
20260221051329	2026-02-23 14:34:29
20260221051746	2026-02-23 14:34:29
20260221052005	2026-02-23 14:34:29
20260221052106	2026-02-23 14:34:29
20260221052248	2026-02-23 14:34:29
20260221053555	2026-02-23 14:34:29
20260221120406	2026-02-23 14:34:29
20260222144930	2026-02-23 14:34:29
20260222160227	2026-02-23 14:34:29
20260223132605	2026-02-23 14:34:29
20260223200000	2026-02-23 14:34:29
20260223210000	2026-02-23 14:34:29
20260224080000	2026-02-25 13:08:12
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
1	Amina W.	5	/images/people/woman1.jpg	I ordered the Red & Denim Co-ord Set and I'm obsessed! The quality is incredible — the fabric feels premium and the fit is perfect. Got so many compliments on my first wear. Will definitely be ordering again!	t	1	1	2026-02-23 14:34:30	2026-02-23 14:34:30
2	Cynthia O.	5	/images/people/woman2.jpg	The Denim Maxi Skirt is everything I wanted. Beautifully structured, the waist fits perfectly and the length is just right. I styled it with a simple white tee and got so many compliments.	t	2	11	2026-02-23 14:34:30	2026-02-23 14:34:30
3	Grace M.	5	/images/people/woman3.jpg	The Sage Linen Jumpsuit is my new favourite piece. Light, breathable and so flattering. I wore it to a garden party and everyone kept asking where I got it from. Kulola never disappoints!	t	3	13	2026-02-23 14:34:30	2026-02-23 14:34:30
4	Fatuma K.	5	/images/people/woman4.jpg	Bought the Black Wide-Leg Palazzo Pants and they are absolutely stunning. The pleating is chef's kiss. Delivery was fast and the packaging was so elegant. This is my go-to shop now.	t	4	6	2026-02-23 14:34:30	2026-02-23 14:34:30
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, hashed_password, confirmed_at, inserted_at, updated_at, role, name, last_signed_in_at) FROM stdin;
1	michaelmunavu83@gmail.com	$2b$12$f2iXvbSeATOPPIA.uGHIsON2TpdZTRU5gTnazOZSCD2pRfdpilIaS	2026-02-23 15:34:18	2026-02-23 15:34:18	2026-02-23 15:34:18	super_admin	Michael Munavu	2026-02-25 14:56:21
\.


--
-- Data for Name: users_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_tokens (id, user_id, token, context, sent_to, inserted_at) FROM stdin;
2	1	\\xde08a61d415541b2bba68859fcc61e7f31d4d20696b5e471e16bf3b9dbdad79d	session	\N	2026-02-23 20:30:02
3	1	\\x867434ae7a1839d8ff3e09688baa8c7cd077838f615abdab18130215a4c66889	session	\N	2026-02-24 05:44:08
4	1	\\xaf317004c7e64bd3d64397bdb85ffb16ee8007a9025e2bebf632a7de3c297b7a	session	\N	2026-02-25 14:56:21
\.


--
-- Name: bundle_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bundle_items_id_seq', 5, true);


--
-- Name: bundles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bundles_id_seq', 1, true);


--
-- Name: collections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collections_id_seq', 5, true);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_id_seq', 4, true);


--
-- Name: info_pages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.info_pages_id_seq', 4, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 4, true);


--
-- Name: product_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_images_id_seq', 1, false);


--
-- Name: product_variants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_variants_id_seq', 195, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 20, true);


--
-- Name: promo_codes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.promo_codes_id_seq', 2, true);


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

SELECT pg_catalog.setval('public.users_tokens_id_seq', 4, true);


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

\unrestrict uT7BwFAWdoiNRJu0KhPOsGkhP9oQTihbJhkkdScOCZAiA5OwlR4blmnF3QYtWGU

