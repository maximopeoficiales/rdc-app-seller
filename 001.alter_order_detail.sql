-- Order detail
ALTER TABLE public.order_detail RENAME COLUMN order_master_id TO order_id;
ALTER TABLE public.order_detail RENAME COLUMN monto TO amount;
ALTER TABLE public.order_detail RENAME COLUMN monto_affected TO amount_affected;
ALTER TABLE public.order_detail RENAME COLUMN monto_affected_real TO amount_affected_real;
