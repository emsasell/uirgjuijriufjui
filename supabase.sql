-- Вставьте весь этот SQL в Supabase -> SQL Editor -> New query -> Run
create extension if not exists "uuid-ossp";
create table if not exists public.users(
 id uuid primary key default uuid_generate_v4(),
 email text unique not null, username text unique not null,
 password_hash text not null, avatar_url text, banned boolean default false,
 verified boolean default false, otp_code text, otp_expires timestamptz,
 last_seen timestamptz, created_at timestamptz default now()
);
create table if not exists public.products(
 id uuid primary key default uuid_generate_v4(), user_id uuid references public.users(id) on delete cascade not null,
 game text not null, place text, title text not null, description text not null,
 price numeric not null, currency text not null, image_url text, active boolean default true,
 created_at timestamptz default now()
);
create table if not exists public.chats(
 id uuid primary key default uuid_generate_v4(), product_id uuid references public.products(id) on delete cascade not null,
 buyer_id uuid references public.users(id) on delete cascade not null,
 seller_id uuid references public.users(id) on delete cascade not null, created_at timestamptz default now()
);
create table if not exists public.messages(
 id uuid primary key default uuid_generate_v4(), chat_id uuid references public.chats(id) on delete cascade not null,
 sender_id uuid references public.users(id) on delete cascade not null, text text not null,
 created_at timestamptz default now()
);
alter table public.users enable row level security;
alter table public.products enable row level security;
alter table public.chats enable row level security;
alter table public.messages enable row level security;
-- Сервер использует service_role, поэтому RLS остаётся включённым.
insert into storage.buckets(id,name,public) values ('emsell','emsell',true) on conflict (id) do update set public=true;
