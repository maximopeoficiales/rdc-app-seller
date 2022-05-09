CREATE FUNCTION public.sp_save_email_option(email_option_save character varying, id_order_master integer)
    RETURNS TABLE
            (
                state_email_option integer
            )
    LANGUAGE plpgsql
AS
$$

BEGIN

    update "order"
    set estado_request     = 2,
        email_option       = email_option_save,
        state_email_option = 1
    where order_id = id_order_master;

    RETURN QUERY
        SELECT o.state_email_option

        FROM "order" o
        WHERE o.order_id = id_order_master;

END;
$$;