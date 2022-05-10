-- order detail
alter table public.order_detail rename column order_master_id to order_id;

alter table public.order_detail add column reason_text varchar;