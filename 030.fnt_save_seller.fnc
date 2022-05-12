create or replace function fnt_save_seller(id_seller_mirakl_p varchar, name_p varchar)
    returns jsonb
    language plpgsql
as
$$
    -- ***********************************************************************************************
    -- Descripcion: < Función para crear un seller >
    --
    -- Input Parameters: < _param - parámetros de creacion del distrito >
    --  <id_seller_mirakl_p>                   :id del seller mirakl.
    --  <name_p>                               :nombre del seller.
    -- Output Parameters: < jsonb - objeto (Seller) >
    --   - <json>                              : objeto de tipo Seller.
    -- * autor       : gianmarcos perez rojas.
    -- * proyecto    : rq 4707 - cambios y devoluciones –devuelve r
    -- * responsable : cesar jimenez.
    -- * rdc         : rq 4707
    -- * revisiones
    -- * fecha            autor       motivo del cambio            rdc
    -- ----------------------------------------------------------------------------
    -- - 10/05/22    maximo apaza  creación de la función     rq 4707
    -- ************

declare
    context text;
    data    jsonb = '{}';
    error   jsonb = '{}';
    next_id bigint;
begin
    select nextval(pg_get_serial_sequence('seller', 'id')) into next_id;
    insert into seller(id, id_seller_mirakl, name)
    values (next_id, id_seller_mirakl_p, name_p);
    select fnt_retrieve_seller(next_id) -> 'data' -> 0
    into data;
    return jsonb_build_object('data', data, 'error', error);

exception
    when others then
        get stacked diagnostics context = pg_exception_context;
        select jsonb_build_object('code', sqlstate, 'name', sqlerrm, 'context', context) into error;
        return jsonb_build_object('data', data, 'error', error);

end;
$$;
