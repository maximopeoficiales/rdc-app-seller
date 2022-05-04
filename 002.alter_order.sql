ALTER TABLE public.order_master RENAME TO "order";
ALTER TABLE public."order" RENAME COLUMN order_master_id TO order_id;
ALTER TABLE public."order" RENAME COLUMN monto_total TO amount_total;
ALTER TABLE public."order" RENAME COLUMN monto_total_return TO amount_total_return;
ALTER TABLE public."order" RENAME COLUMN monto_total_change TO amount_total_change;
