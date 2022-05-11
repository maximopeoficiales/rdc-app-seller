create function fnt_update_seller(_param jsonb) returns jsonb
    language plpgsql
as
$$
    -- ***********************************************************************************************
    -- Descripcion: < Función para actualizar un seller >
    --
    -- Input Parameters: < _param - parámetros de creacion del distrito >
    --  <name>                      :nombre del seller.
    --  <id>                        :identificador de la tabla seller.
    -- Output Parameters: < jsonb - objeto(Seller) >
    --   - <json>                              : objeto de  Seller.
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
    data    jsonb  = '{}';
    error   jsonb  = '{}';
    _id     bigint = cast(_param ->> 'id' as bigint);

begin
    if _param -> 'name' is not null then
        update seller
        set name       = _param ->> 'name',
            updated_at = current_timestamp
        where id = _id;
    end if;

    select fnt_retrieve_seller(jsonb_build_object('id', _id)) -> 'data' -> 0 into data;
    return jsonb_build_object('data', data, 'error', error);

exception
    when others then
        get stacked diagnostics context = pg_exception_context;
        select jsonb_build_object('code', sqlstate, 'name', sqlerrm, 'context', context) into error;
        return jsonb_build_object('data', data, 'error', error);

end;
$$;


