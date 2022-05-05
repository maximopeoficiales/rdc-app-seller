CREATE FUNCTION public.sp_listar_order_x_tikect(vi_tikect character varying) RETURNS SETOF public."order"
    LANGUAGE plpgsql
AS
$$
DECLARE
    r order%rowtype;
BEGIN
    FOR r IN
        SELECT *,
               order_id            as order_master_id,
               amount_total        as monto_total,
               amount_total_return as monto_total_return,
               amount_total_change as monto_total_change
        FROM public."order"
        WHERE order_number = vi_tikect
        LOOP
            RETURN NEXT r;
        END LOOP;
    RETURN;
END;
$$;