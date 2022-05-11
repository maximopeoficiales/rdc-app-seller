create table public.seller (
	id bigserial not null,
	id_seller_mirakl varchar not null,
	name varchar not null,
	created_at timestamp null default now(),
	updated_at timestamp null,
	constraint seller_pk primary key (id)
);
create unique index seller_id_seller_mirakl_uindex on public.seller using btree (id_seller_mirakl);
create unique index seller_name_uindex on public.seller using btree (name);

comment on table public.seller is 'tabla de seller';

-- column comments

comment on column public.seller.id is 'id del seller';
comment on column public.seller.id_seller_mirakl is 'id del seller de mirakl';
comment on column public.seller.name is 'nombre del seller';
comment on column public.seller.created_at is 'fecha de creación del seller';
comment on column public.seller.updated_at is 'fecha de actualizacion del seller';

