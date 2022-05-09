alter table public.order_master rename to "order";
alter table public."order" rename column order_master_id to order_id;
alter table public."order" rename column monto_total to amount_total;
alter table public."order" rename column monto_total_return to amount_total_return;
alter table public."order" rename column monto_total_change to amount_total_change;
