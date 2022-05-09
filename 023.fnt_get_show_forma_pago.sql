create or replace function fnt_get_show_forma_pago(order_number_p varchar)
    returns table(forma_pago varchar)
    language plpgsql
as
$$
begin
	return query
		select p.forma_pago from "order" om
    inner join purchase p
    on p.purchase_id = om.purchase_id
    where om.order_number = order_number_p;
end;
$$;
