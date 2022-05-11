-- order detail
alter table public.order_detail rename column order_master_id to order_id;

alter table public.order_detail add column reason_text varchar;


alter table public.order_detail add column id_seller bigint;
ALTER TABLE public.order_detail ADD CONSTRAINT order_detail_fk FOREIGN KEY (id_seller) REFERENCES public.seller(id);
