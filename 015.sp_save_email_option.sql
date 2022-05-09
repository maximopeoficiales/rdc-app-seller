create or replace function public.sp_save_email_option(email_option_save character varying, id_order_master integer)
    returns table
            (
                state_email_option integer
            )
    language plpgsql
as
$$

begin

    update "order"
    set estado_request     = 2,
        email_option       = email_option_save,
        state_email_option = 1
    where order_id = id_order_master;

    return query
        select o.state_email_option

        from "order" o
        where o.order_id = id_order_master;

end;
$$;