create or replace function sp_list_products_by_order(orderid bigint)
    returns table(product_id character varying, quantity_products integer, quantity_products_return integer, quantity_products_return_real integer)
    language plpgsql
as
$$
begin 
 return query 
 select 
	od.product_id, 
	od.quantity_products, 
	od.quantity_products_return,
	(case when od.quantity_products_return_real is null then 0
		 else od.quantity_products_return_real
		 end ) as quantity_products_return_real
 from order_detail od
 where od.order_id = orderid;
end;
$$;


