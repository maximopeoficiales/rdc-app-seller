CREATE FUNCTION public.sp_list_products_by_order(orderid bigint) RETURNS TABLE(product_id character varying, quantity_products integer, quantity_products_return integer, quantity_products_return_real integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
 RETURN QUERY
 select
	od.product_id,
	od.quantity_products,
	od.quantity_products_return,
	(case when od.quantity_products_return_real is null then 0
		 else od.quantity_products_return_real
		 end ) as quantity_products_return_real
 from order_detail od
 where od.order_id = orderid;
END;
$$;