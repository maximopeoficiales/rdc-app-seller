CREATE FUNCTION public.sp_listar_order_detail_x_tikect(vi_tikect character varying)
    RETURNS TABLE
            (
                order_master_id          bigint,
                order_number             character varying,
                product_name             character varying,
                reason_name              character varying,
                quantity_products_return integer,
                price_by_unit            numeric,
                product_color            character varying,
                product_size             character varying
            )
    LANGUAGE plpgsql
AS
$$

BEGIN

    RETURN QUERY
        SELECT om.order_id as order_master_id,
               om.order_number,
               od.product as  product_name,
               ro.description reason_name,
               od.quantity_products_return,
               od.price_by_unit,
               od.color   as  product_color,
               od."size"  as  product_size

        from order om

                 join order_detail od on od.order_id = om.order_id

                 join reason_operation ro on ro.reason_operation_id = od.reason_operation_id

        where od.quantity_products_return > 0
          and om.order_number = vi_tikect;

END;

$$;