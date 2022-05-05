CREATE FUNCTION public.sp_listar_order_details_x_order(ni_order_id integer) RETURNS SETOF public."order_detail"
    LANGUAGE plpgsql
    AS $$
DECLARE
    r order_detail%rowtype;
BEGIN
    FOR r IN
        SELECT * FROM order_detail WHERE order_id = ni_order_id
    LOOP
        RETURN NEXT r;
    END LOOP;
    RETURN;
END;
$$;