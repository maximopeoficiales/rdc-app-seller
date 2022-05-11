-- order detail
alter table public.order_detail rename column order_master_id to order_id;

alter table public.order_detail add column reason_text varchar;


alter table public.order_detail add column id_seller bigint;
ALTER TABLE public.order_detail ADD CONSTRAINT order_detail_fk FOREIGN KEY (id_seller) REFERENCES public.seller(id);

comment on column public.order_detail.reason_text is 'razon de la operacion';
comment on column public.order_detail.id_seller is 'identificador de la tabla seller';
