CREATE OR REPLACE FUNCTION fnt_get_find_price_by_product(order_id_p bigint,product_id_p varchar)
    returns TABLE(price_by_unit numeric,product varchar,product_url varchar,suborder varchar,type_product varchar,seller_name varchar,
    seller_id varchar)
    language plpgsql
as
$$
BEGIN
	RETURN QUERY
select pd.price_by_unit, pd.product, pd.product_url,
            pd.suborder, pd.type_product, pd.seller_name, pd.seller_id
            from "order" om inner join purchase_detail pd
            on om.purchase_id = pd.purchase_id where om.order_id =  order_id_p
            and pd.product_id = product_id_p order by om.order_id desc limit 1;
END;
$$;
